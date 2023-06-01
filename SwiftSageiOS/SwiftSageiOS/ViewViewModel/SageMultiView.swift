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
    @State private var isMoveGestureActivated = false
    @State var webViewURL: URL?

    @ObservedObject private var keyboardResponder = KeyboardResponder()

// START HANDLE WINDOW MOVEMENT GESTURE *********************************************************
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    TopBar(isEditing: $isEditing, onClose: {
                        windowManager.removeWindow(window: window)
                    }, windowInfo: window, webViewURL: getURL(), settingsViewModel: settingsViewModel)
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                if !isMoveGestureActivated {
                                    self.windowManager.bringWindowToFront(window: self.window)
                                    isMoveGestureActivated = true
                                }

                                // TODO: MORE CONSTRAINTS
                                // Keep windows from going to close top top

                                position = CGSize(width: position.width + value.translation.width, height: position.height + value.translation.height)
                            }
                            .onEnded { value in
                                isMoveGestureActivated = false
                            }
                    ).onTapGesture {
                        self.windowManager.bringWindowToFront(window: self.window)

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
                        }, overrideText: { nil }))
                        .onTapGesture {
                            self.windowManager.bringWindowToFront(window: self.window)
                        }
                        .environmentObject(viewModel)

                    case .chat:
                        ChatView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel, conversations: $settingsViewModel.conversations, window: window, isEditing: $isEditing, isLockToBottom: $isLockToBottom)
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
// END SOURCE CODE WINDOW SETUP HANDLING *********************************************************
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

// START WINDOW RESIZING GESTURE ************************************************************************************
struct ResizableViewModifier: ViewModifier {
    @Binding var frame: CGRect
    @Binding var zoomScale: CGFloat
    var window: WindowInfo

    var handleSize: CGFloat = SettingsViewModel.shared.cornerHandleSize

    @Binding var boundPosition: CGSize

    @ObservedObject var windowManager: WindowManager

    func body(content: Content) -> some View {
        content
            .frame(width: frame.width, height: frame.height)
            .overlay(
                ResizingHandle(positionLocation: .topLeading, frame: $frame, handleSize: handleSize, zoomScale: $zoomScale, windowManager: windowManager, window: window, boundPosition: $boundPosition)
            )
    }
}

struct ResizingHandle: View {
    enum Position {
        case topLeading
    }

    var positionLocation: Position
    @Binding var frame: CGRect
    var handleSize: CGFloat
    @Binding var zoomScale: CGFloat
    @GestureState private var dragOffset: CGSize = .zero
    @State private var activeDragOffset: CGSize = .zero
    @State private var isResizeGestureActive = false
    @ObservedObject var windowManager: WindowManager
    var window: WindowInfo
    @Binding var boundPosition: CGSize

    var body: some View {
        GeometryReader { reader in
            Circle()
                .fill(SettingsViewModel.shared.buttonColor)
                .frame(width: handleSize, height: handleSize)
                .position(positionPoint(for: positionLocation))
                .opacity(0.666)
            // TODO: Add resizing contraints so users don't resize to a place they can't return from.
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onChanged { value in
                            activeDragOffset = value.translation

                            if !isResizeGestureActive {
                                isResizeGestureActive = true
                                self.windowManager.bringWindowToFront(window: self.window)
                            }
                        }
                        .onEnded { value in
                            updateFrame(with: value.translation, reader.size.width, reader.size.height)
                            activeDragOffset = .zero
                            isResizeGestureActive = false
                        }
                )
                .onChange(of: activeDragOffset) { newValue in
                    withAnimation(.interactiveSpring()) {
                        updateFrame(with: newValue, reader.size.width, reader.size.height)
                    }
                }
                .animation(.interactiveSpring(), value: activeDragOffset)
                .offset(CGSize(width: handleSize / 2, height: handleSize / 2))
        }
    }
    private func positionPoint(for position: Position) -> CGPoint {
        switch position {
        case .topLeading:
            return CGPoint(x: frame.minX, y: frame.minY)
        }
    }

    private func updateFrame(with translation: CGSize, _ screenWidth: CGFloat, _ screenHeight: CGFloat) {
        let newWidth: CGFloat
        let newHeight: CGFloat
        let minSize: CGFloat = 7.0
        switch positionLocation {
        case .topLeading:
            // Compute new width and height based on the direction of the drag gesture
            newWidth = translation.width < 0 ? max(minSize, frame.width + abs(translation.width)) : max(minSize, frame.width - translation.width)
            newHeight = translation.height < 0 ? max(minSize, frame.height + abs(translation.height)) : max(minSize, frame.height - translation.height)
        }
        // TODO: MORE CONSTRAINTS
        // Keep windows from going to close top top

        // Smoothly interpolate towards the new size
         let lerpFactor: CGFloat = 0.25
         frame.size.width += (newWidth - frame.size.width) * lerpFactor
         frame.size.height += (newHeight - frame.size.height) * lerpFactor
    }
}
// END WINDOW RESIZING GESTURE HANDLING ****************************************************************************


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
