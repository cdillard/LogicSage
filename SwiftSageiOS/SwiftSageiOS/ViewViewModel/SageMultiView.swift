//
//  SageWebView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/26/23.
//
#if !os(macOS)

import Foundation
import SwiftUI
import UIKit
import WebKit
import Combine

enum ViewMode {
    case webView
    case editor
    case simulator
    case chat
    case project

    case repoTreeView
    case windowListView
    case changeView
    case workingChangesView
}

struct SageMultiView: View {

    let dragDelay = 0.333666
    let dragsPerSecond = 60.0

    @Binding var showAddView: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State var viewMode: ViewMode

    @ObservedObject var windowManager: WindowManager

    var window: WindowInfo

    @ObservedObject var sageMultiViewModel: SageMultiViewModel

    @State var isEditing = false
    @Binding var frame: CGRect
    @Binding var position: CGSize
    @Binding var isMoveGestureActivated: Bool
    @State var webViewURL: URL?
    @State var isDragDisabled = false
    @Binding var viewSize: CGRect
    @Binding var resizeOffset: CGSize
    @Binding var bumping: Bool
    @Binding var isResizeGestureActive: Bool

    @State  var lastDragTime = Date()
    @State  var lastBumpFeedbackTime = Date()
    @State var isLockToBottomEditor = false

    // START HANDLE WINDOW MOVEMENT GESTURE *********************************************************
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    TopBar(isEditing: $isEditing, onClose: {
                        windowManager.removeWindow(window: window)
                    }, windowInfo: window, webViewURL: getURL(), settingsViewModel: settingsViewModel)
                    .if(!isDragDisabled) { view in
                        view.gesture(
                            DragGesture(minimumDistance: 3)
                                .onChanged { value in
                                    let now = Date()
                                    if now.timeIntervalSince(self.lastDragTime) >= (1.0 / dragsPerSecond) { // throttle duration
                                        self.lastDragTime = now
                                        dragsOnChange(value: value)
                                    }
                                }
                                .onEnded { value in
                                    isMoveGestureActivated = false
                                }
                        ).onTapGesture {
                            self.windowManager.bringWindowToFront(window: self.window)
                        }
                    }

                    // START SOURCE CODE WINDOW SETUP HANDLING *******************************************************
                    switch viewMode {
                    case .editor:
                        SourceCodeTextEditor(text: $sageMultiViewModel.sourceCode, isEditing: $isEditing, isLockToBottom: $isLockToBottomEditor, customization:
                                                SourceCodeTextEditor.Customization(didChangeText:
                                                                                    { srcCodeTextEditor in
                            DispatchQueue.global(qos: .default).async {
                                doSrcCode(newText: srcCodeTextEditor.text)
                            }

                        }, insertionPointColor: {
                            Colorv(cgColor: settingsViewModel.buttonColor.cgColor!)
                        }, lexerForSource: { lexer in
                            SwiftLexer()
                        }, textViewDidBeginEditing: { srcEditor in
                            //                            print("srcEditor textViewDidBeginEditing")
                        }, theme: {
                            DefaultSourceCodeTheme(settingsViewModel: settingsViewModel)
                        }, overrideText: { nil }), isMoveGestureActive: $isMoveGestureActivated, isResizeGestureActive: $isResizeGestureActive)
                        .onTapGesture {
                            self.windowManager.bringWindowToFront(window: self.window)
                        }

                    case .chat:
                        ChatView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel, isEditing: $isEditing, windowManager: windowManager, isMoveGestureActive: $isMoveGestureActivated, isResizeGestureActive: $isResizeGestureActive)
                            .onTapGesture {
                                self.windowManager.bringWindowToFront(window: self.window)
                            }
                    case .project:
                        ProjectView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel)
                    case .webView:
                        WebView(url:getURL())
                            .onTapGesture {
                                self.windowManager.bringWindowToFront(window: self.window)
                            }
                    case .simulator:
                        ZStack {
                            Image(uiImage: settingsViewModel.actualReceivedSimulatorFrame ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .ignoresSafeArea()
                        }
                    case .repoTreeView:
                        NavigationView {
                            if let root = settingsViewModel.root {
                                RepositoryTreeView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel, directory: root, window: window, windowManager: windowManager)
                            }
                            else {
                                Text("No root")
                            }
                        }
                        .navigationViewStyle(StackNavigationViewStyle())

                    case .windowListView:
                        NavigationView {
                            WindowList(windowManager: windowManager, showAddView: $showAddView)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    case .changeView:
                        NavigationView {
                            ChangeList(showAddView: $showAddView, sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())

                    case .workingChangesView:
                        NavigationView {
                            WorkingChangesView(showAddView: $showAddView, sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    }
                    Spacer()
                }
                .onChange(of: viewSize) { newViewSize in
                    recalculateWindowSize(size: newViewSize.size)
                }
                .onChange(of: geometry.size) { size in 
                    recalculateWindowSize(size: geometry.size)
                }
// END SOURCE CODE WINDOW SETUP HANDLING *********************************************************
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

    }
    
    func doSrcCode(newText: String) {
        let theNewtext = String(newText)
        sageMultiViewModel.refreshChanges(newText: theNewtext)

        guard let fileURL = window.file?.url else {
            logD("no file url, no file changes")
            return
        }
        var found = false

        for (index,fileChange) in settingsViewModel.unstagedFileChanges.enumerated() {
            if fileURL == fileChange.fileURL {
                DispatchQueue.main.async {
                    settingsViewModel.changes = sageMultiViewModel.changes

                    settingsViewModel.unstagedFileChanges.replaceSubrange(index...index, with: [FileChange(fileURL: fileURL, status: "Modified", lineChanges: sageMultiViewModel.changes, newFileContents: newText)])
                }
                found = true
                break
            }
        }
        if !found {
            DispatchQueue.main.async {
                settingsViewModel.changes = sageMultiViewModel.changes

                settingsViewModel.unstagedFileChanges += [FileChange(fileURL: fileURL, status: "Modified", lineChanges: sageMultiViewModel.changes, newFileContents: newText)]
            }
        }
    }
    func recalculateWindowSize(size: CGSize) {
        if !isResizeGestureActive {
            if frame.size.width > size.width {
                frame.size.width = size.width
            }
            if frame.size.height > size.height {
                let hackedHeight = frame.size.height - size.height
                // print("Hacked height == \(hackedHeight)")
                position.height = max(40, position.height - hackedHeight)
                frame.size.height = size.height
            }

            dragsOnChange(value: nil, false)
        }
    }
    func getURL() -> URL {
        let webURL: URL
        if let webViewURL = webViewURL {
            webURL = webViewURL
        }
        else {
            webURL = URL(string: "http://www.google.com")!
        }
        
        return webURL
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    var webViewInstance: WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: self.url)
        webView.load(request)
        return webView
    }
    func makeUIView(context: Context) -> WKWebView {
        return webViewInstance
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {

    }
    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }
    }
}
struct HandleView: View {
    var body: some View {
        Circle()
            .frame(width: SettingsViewModel.shared.cornerHandleSize, height: SettingsViewModel.shared.cornerHandleSize)
            .foregroundColor(Color.white.opacity(0.666))
    }
}
// END HANDLE WINDOW MOVEMENT GESTURE *************************************************

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    var keyboardShow: AnyCancellable?
    var keyboardHide: AnyCancellable?

    init() {
        keyboardShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
            .assign(to: \.currentHeight, on: self)

        keyboardHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .assign(to: \.currentHeight, on: self)
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
#endif
