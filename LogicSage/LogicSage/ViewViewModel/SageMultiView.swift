//
//  SageWebView.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/26/23.
//

import Foundation
import SwiftUI
#if !os(macOS)
import UIKit
#endif
#if !os(tvOS)
import WebKit
#endif

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

// TURN OFF BEFORE RELEASE
let gestureDebugLogs = false

struct SageMultiView: View {

    let dragDelay = 0.333666
    let dragsPerSecond = 60.0
    let lineWidth: CGFloat = 3
    let curveSize: CGFloat = 17.666
    let cornerRadius: CGFloat = 26.666
    let handleOpacity: CGFloat = 0.333

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
    @Binding var bumpingVertically: Bool

    @Binding var isResizeGestureActive: Bool
    @Binding var keyboardHeight: CGFloat

    @State  var lastDragTime = Date()
    @State  var lastBumpFeedbackTime = Date()
    @State var isLockToBottomEditor = false
    @State var currentURL = URL(string: "https:/www.google.com/")!

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {

                    topArea()
                    VStack {

                        switch viewMode {
                        case .editor:
                            editorArea()
                        case .chat:
                            ChatView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel, isEditing: $isEditing, windowManager: windowManager, isMoveGestureActive: $isMoveGestureActivated, isResizeGestureActive: $isResizeGestureActive, keyboardHeight: $keyboardHeight, frame: $frame, position: $position, resizeOffset: $resizeOffset)
                                .simultaneousGesture(TapGesture().onEnded { value in
                                    self.windowManager.bringWindowToFront(window: self.window)
                                })
                        case .project:
                            ProjectView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel)
                        case .webView:
                            webViewArea()
                        case .simulator:
                            ZStack {
#if !os(macOS)
                                Image(uiImage: settingsViewModel.actualReceivedSimulatorFrame ?? UIImage())
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .ignoresSafeArea()
#endif
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                self.windowManager.bringWindowToFront(window: self.window)
                            })
                        case .repoTreeView:
                            NavigationView {
                                if let root = settingsViewModel.root {
                                    RepositoryTreeView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel, directory: root, window: window, windowManager: windowManager)
                                }
                                else {
                                    Text("No root")
                                }
                            }
#if !os(macOS)
                            .navigationViewStyle(StackNavigationViewStyle())
#endif

                        case .windowListView:
                            NavigationView {
                                WindowList(windowManager: windowManager, showAddView: $showAddView)
                            }
#if !os(macOS)
                            .navigationViewStyle(StackNavigationViewStyle())
#endif

                        case .changeView:
                            NavigationView {
                                ChangeList(showAddView: $showAddView, sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel)
                            }
#if !os(macOS)
                            .navigationViewStyle(StackNavigationViewStyle())
#endif

                        case .workingChangesView:
                            NavigationView {
                                WorkingChangesView(showAddView: $showAddView, sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel)
                            }
#if !os(macOS)
                            .navigationViewStyle(StackNavigationViewStyle())
#endif

                        }
                        Spacer()
                    }
#if !os(tvOS)
                    .onChange(of: viewSize) { newViewSize in
                        recalculateWindowSize(size: newViewSize.size)
                    }
                    .onChange(of: geometry.size) { size in
                        recalculateWindowSize(size: geometry.size)
                    }
#endif


                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Capsule()
                    .fill(.white.opacity(0.4))
                    .frame(width: 200, height: 14)
#if !os(macOS)
                    .hoverEffect(.automatic)
#endif
                    .offset(y: geometry.size.height / 2  - 10 - (sageMultiViewModel.windowInfo.windowType == .chat ? keyboardHeight : 0))
#if !os(tvOS)


                    .if(!isDragDisabled) { view in

                        view.gesture(
                            DragGesture(minimumDistance: 3)
                                .onChanged { value in
                                    if keyboardHeight != 0 {
#if !os(macOS)
                                        hideKeyboard()
#endif
                                    }
                                    if gestureDebugLogs {

                                        if isMoveGestureActivated == false {

                                            print("MOVE gesture START = \(position)")
                                        }
                                        else {
                                            print("MOVE gesture update = \(position)")
                                        }
                                    }
                                    let now = Date()
                                    if now.timeIntervalSince(self.lastDragTime) >= (1.0 / dragsPerSecond) {
                                        self.lastDragTime = now

                                        dragsOnChange(value: value)
                                    }
                                }
                                .onEnded { value in
                                    if gestureDebugLogs {

                                        print("MOVE gesture ended new Pos = \(position)")
                                    }
                                    isMoveGestureActivated = false
                                }
                        )
                        .simultaneousGesture(TapGesture().onEnded {
                            self.windowManager.bringWindowToFront(window: self.window)
                        })

                    }
#endif
            }
            curvedEdgeArcZone(size: geometry.size)

        }

    }
    func editorArea() -> some View {
#if !os(tvOS)

        SourceCodeTextEditor(text: $sageMultiViewModel.sourceCode, isEditing: $isEditing, isLockToBottom: $isLockToBottomEditor, customization:
                                SourceCodeTextEditor.Customization(didChangeText:
                                                                    { srcCodeTextEditor in
            DispatchQueue.global(qos: .default).async {
                doSrcCode(newText: srcCodeTextEditor.text)
            }

        }, insertionPointColor: {
#if !os(macOS)
            Colorv(cgColor: settingsViewModel.buttonColor.cgColor!)
#else
            Colorv(.darkGreen)
#endif
        }, lexerForSource: { lexer in
            SwiftLexer()
        }, textViewDidBeginEditing: { srcEditor in
            //                                        print("srcEditor textViewDidBeginEditing")
        }, theme: {
            DefaultSourceCodeTheme(settingsViewModel: settingsViewModel)
        }, overrideText: { nil }, codeDidCopy: { }, windowType: { .file }), isMoveGestureActive: $isMoveGestureActivated, isResizeGestureActive: $isResizeGestureActive)
        .simultaneousGesture(TapGesture().onEnded {
            self.windowManager.bringWindowToFront(window: self.window)
        })
#else
        VStack { }
#endif
    }
    func webViewArea() -> some View {
        VStack(spacing:0) {
            HStack(alignment: VerticalAlignment.firstTextBaseline) {
                Button(action: {
                    logD("on Back tap")
#if !os(tvOS)
                    goBackward()
#endif
                }) {
                    Image(systemName: "backward.circle.fill")
                        .font(.title)
                        .minimumScaleFactor(0.75)
#if !os(macOS)
                        .hoverEffect(.lift)
#endif
                }
                .foregroundColor(settingsViewModel.buttonColor)

                Button(action: {
                    logD("on FWD tap")
#if !os(tvOS)
                    goForward()
#endif
                }) {
                    Image(systemName: "forward.circle.fill")
                        .font(.title)
                        .minimumScaleFactor(0.75)
#if !os(macOS)
                        .hoverEffect(.lift)
#endif
                }
                .foregroundColor(settingsViewModel.buttonColor)


                Button(action: {
                    logD("on REFRESH tap")
#if !os(tvOS)
                    reload()
#endif
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                        .font(.title)
                        .minimumScaleFactor(0.75)
#if !os(macOS)
                        .hoverEffect(.lift)
#endif
                }
                .foregroundColor(settingsViewModel.buttonColor)
            }
            .frame(maxWidth: .infinity)

            .background(settingsViewModel.backgroundColor)
#if !os(macOS)
#if !os(tvOS)
            WebView(url: getURL(), currentURL: $currentURL, webViewStore: sageMultiViewModel.webViewStore, request:URLRequest(url: getURL()) )
                .simultaneousGesture(TapGesture().onEnded {
                    self.windowManager.bringWindowToFront(window: self.window)
                })
#endif
#endif

        }
    }

    func curvedEdgeArcZone(size: CGSize) -> some View {
        Group {
            // TOP LEFT
            ZStack {
                ZStack {
                    CurvedEdgeArc(cornerRadius: cornerRadius, curveSize: curveSize, position: .bottomLeft)
                        .stroke(Color.primary, lineWidth: lineWidth)
                        .offset(x: -22.5, y: -22.5)
                        .opacity(handleOpacity)
                        .allowsHitTesting(false)
#if !os(macOS)
#if !os(tvOS)
                    CustomPointerRepresentableView(mode: .topLeft)
#endif
#endif
                }
                .frame( maxWidth: settingsViewModel.cornerHandleSize, maxHeight: settingsViewModel.cornerHandleSize)
            }
            // TOP RIGHT
            ZStack {
                ZStack {
                    CurvedEdgeArc(cornerRadius: cornerRadius, curveSize: curveSize, position: .bottomRight)
                        .stroke(Color.primary, lineWidth: lineWidth)
                        .offset(x: 22.5, y: -24.25)
                        .opacity(handleOpacity)
                        .allowsHitTesting(false)
                }
                .offset(x: size.width - settingsViewModel.cornerHandleSize)
                .frame( maxWidth: settingsViewModel.cornerHandleSize, maxHeight: settingsViewModel.cornerHandleSize)
            }
            // BOTTOM RIGHT
            ZStack {
                ZStack {
                    CurvedEdgeArc(cornerRadius: cornerRadius, curveSize: curveSize, position: .topRight)
                        .stroke(settingsViewModel.appTextColor, lineWidth: lineWidth)
                        .offset(x: 22.5, y: 17.75)
                        .opacity(handleOpacity)
                        .allowsHitTesting(false)
                }
                .offset(x: size.width - settingsViewModel.cornerHandleSize,
                        y: size.height - settingsViewModel.cornerHandleSize - 5 -  (sageMultiViewModel.windowInfo.windowType == .chat ? keyboardHeight : 0))
                .frame( maxWidth: settingsViewModel.cornerHandleSize, maxHeight: settingsViewModel.cornerHandleSize)
            }
        }
    }
    func topArea() -> some View {
#if !os(tvOS)

        TopBar(isEditing: $isEditing, onClose: {
            windowManager.removeWindow(window: window)
        }, windowInfo: window, webViewURL: getURL(), settingsViewModel: settingsViewModel, keyboardHeight: $keyboardHeight)

        .if(!isDragDisabled) { view in

            view.simultaneousGesture(
                DragGesture(minimumDistance: 3)
                    .onChanged { value in
                        if keyboardHeight != 0 {
#if !os(macOS)
                            hideKeyboard()
#endif
                        }
                        if gestureDebugLogs {

                            if isMoveGestureActivated == false {

                                print("MOVE gesture START = \(position)")
                            }
                            else {
                                print("MOVE gesture update = \(position)")
                            }
                        }
                        let now = Date()
                        if now.timeIntervalSince(self.lastDragTime) >= (1.0 / dragsPerSecond) {
                            self.lastDragTime = now

                            dragsOnChange(value: value)
                        }
                    }
                    .onEnded { value in
                        if gestureDebugLogs {

                            print("MOVE gesture ended new Pos = \(position)")
                        }
                        isMoveGestureActivated = false
                    }
            )
            .simultaneousGesture(TapGesture().onEnded {
                self.windowManager.bringWindowToFront(window: self.window)
            })

        }
#else
        VStack {}
#endif

    }
#if !os(tvOS)
    private func goBackward() {
        sageMultiViewModel.webViewStore.webView.goBack()
    }
    private func goForward() {
        sageMultiViewModel.webViewStore.webView.goForward()
    }
    private func reload() {
        sageMultiViewModel.webViewStore.webView.reload()
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
                if keyboardHeight == 0 {
                    let hackedHeight = frame.size.height - size.height
                    print("Hacked height == \(hackedHeight)")
                    position.height = max(60, position.height - hackedHeight)
                    frame.size.height = size.height
                }
            }

            // TODO: Decide when this should be done. right now we'll potetially lose window?
            // dragsOnChange(value: nil, false)
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
#endif

}
#if !os(tvOS)

class WebViewStore: ObservableObject {
    @Published var webView: WKWebView = WKWebView()
}
#if !os(macOS)
#if !os(tvOS)

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var currentURL: URL

    @ObservedObject var webViewStore: WebViewStore

    let request: URLRequest

    func makeUIView(context: Context) -> WKWebView {
        webViewStore.webView.navigationDelegate = context.coordinator
        return webViewStore.webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                parent.currentURL = url // Intercept URL
            }
            decisionHandler(.allow)
        }
    }
}

#endif
#endif
#endif
