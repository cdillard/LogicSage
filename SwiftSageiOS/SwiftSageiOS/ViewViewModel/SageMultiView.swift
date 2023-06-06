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
    @Binding var showAddView: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State var viewMode: ViewMode

    @ObservedObject var windowManager: WindowManager

    var window: WindowInfo

    @ObservedObject var sageMultiViewModel: SageMultiViewModel

    @State var isEditing = false
    @State var isLockToBottom = true
    @Binding var frame: CGRect
    @Binding var position: CGSize
    @State var isMoveGestureActivated = false
    @State var webViewURL: URL?
    @State var initialViewFrame = CGRect.zero
    @State var isDragDisabled = false
    @Binding var viewSize: CGRect
    @Binding var resizeOffset: CGSize
    @Binding var bumping: Bool
    @Binding var isResizeGestureActive: Bool

    @State private var lastDragTime = Date()

    let dragDelay = 0.333666
    let dragsPerSecond = 45.0
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
                                        dragsOnChange(value: value, geometrySafeAreaInsetLeading: geometry.safeAreaInsets.leading, geometrySafeAreaTop: geometry.safeAreaInsets.top)

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
                        let viewModel = SourceCodeTextEditorViewModel()

                        SourceCodeTextEditor(text: $sageMultiViewModel.sourceCode, isEditing: $isEditing, isLockToBottom: $isLockToBottom, customization:
                                                SourceCodeTextEditor.Customization(didChangeText:
                                                                                    { srcCodeTextEditor in
                            DispatchQueue.global(qos: .default).async {

                                let theNewtext = String(srcCodeTextEditor.text)
                                sageMultiViewModel.refreshChanges(newText: theNewtext)


                                if let fileURL = window.file?.url {
                                    // add or replace this files change entry from this arr

                                    var found = false

                                    for (index,fileChange) in settingsViewModel.unstagedFileChanges.enumerated() {
                                        if fileURL == fileChange.fileURL {
                                            DispatchQueue.main.async {
                                                settingsViewModel.changes = sageMultiViewModel.changes

                                                settingsViewModel.unstagedFileChanges.replaceSubrange(index...index, with: [FileChange(fileURL: fileURL, status: "Modified", lineChanges: sageMultiViewModel.changes, newFileContents: srcCodeTextEditor.text)])
                                            }
                                            found = true
                                            break
                                        }
                                    }
                                    if !found {
                                        DispatchQueue.main.async {
                                            settingsViewModel.changes = sageMultiViewModel.changes

                                            settingsViewModel.unstagedFileChanges += [FileChange(fileURL: fileURL, status: "Modified", lineChanges: sageMultiViewModel.changes, newFileContents: srcCodeTextEditor.text)]
                                        }
                                    }

                                }
                                else {
                                    logD("no file url, no file changes")
                                }
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
                        .environmentObject(viewModel)

                    case .chat:

                        ChatView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel, conversations: $settingsViewModel.conversations, window: window, isEditing: $isEditing, isLockToBottom: $isLockToBottom, windowManager: windowManager, isMoveGestureActive: $isMoveGestureActivated, isResizeGestureActive: $isResizeGestureActive)
                            .onTapGesture {
                                self.windowManager.bringWindowToFront(window: self.window)
                            }
                    case .project:
                        ProjectView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel)
                    case .webView:
                        let viewModel = WebViewViewModel()
                        WebView(url:getURL())
                            .onTapGesture {
                                self.windowManager.bringWindowToFront(window: self.window)
                            }
                            .environmentObject(viewModel)
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
//                    logD("SageMultiView viewSize update = \(geometry.size)")

                }
                .onAppear {
                    position = CGSize(width: initialViewFrame.origin.x, height: initialViewFrame.origin.y)
                }
                .background(
                    GeometryReader { viewGeometry in
                        Color.clear.onAppear {
                            let startFrame = viewGeometry.frame(in: .global)
                            self.initialViewFrame = CGRectMake(startFrame.origin.x, startFrame.origin.y, frame.width, frame.height)
//                            logD("initial view = \(initialViewFrame)")
                        }
                    }
                )
                // END SOURCE CODE WINDOW SETUP HANDLING *********************************************************

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    func recalculateWindowSize(size: CGSize) {
        if !isResizeGestureActive {
            //                    resizeOffset = .zero
            if frame.size.width > size.width {
                frame.size.width = size.width - size.width * 0.1 - 30
            }
            if frame.size.height > size.height {
                frame.size.height = size.height
            }
            var newPosX = position.width
            var newPosY = position.height
            if resizeOffset.width == 0 {

            }
            else if resizeOffset.width < 0 {
                newPosX = size.width * 0.025 + newPosX - abs(resizeOffset.width) / 2
            }
            else  {
                // the view got bigger , move it to top left
                newPosX = size.width * 0.025 + newPosX //+ resizeOffset.width / 2
            }
            if resizeOffset.height == 0 {

            }
            // The view got smaller, move
            else if resizeOffset.height < 0 {
                newPosY = newPosY - size.height * 0.075  //- abs(resizeOffset.height) / 2
            }
            else {
                newPosY = newPosY - size.height * 0.075 //+ resizeOffset.height / 2
            }

            position = CGSize(width: max(size.width * 0.025, newPosX), height: max(size.width * 0.075, newPosY))


  //          if !isMoveGestureActivated {
                dragsOnChange(value: nil, geometrySafeAreaInsetLeading: 20, geometrySafeAreaTop: 40)
//            }
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
class SourceCodeTextEditorViewModel: ObservableObject {
}
class WebViewViewModel: ObservableObject {
}
class PinchGestureHandler: ObservableObject {
    @Published var scale: CGFloat = 1.0
    var contentSize: CGSize = .zero
    var onContentSizeChange: ((CGSize) -> Void)?
    var isPinching: Bool = false
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
