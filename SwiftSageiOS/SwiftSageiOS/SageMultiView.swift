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
enum ViewMode {
    case webView
    case editor
    case repoTreeView
    case windowListView
}

struct SageMultiView: View {
    @Binding var showAddView: Bool

    @ObservedObject var settingsViewModel: SettingsViewModel
    @State var viewMode: ViewMode
    @EnvironmentObject var windowManager: WindowManager
    var window: WindowInfo

    @EnvironmentObject var sageMultiViewModel: SageMultiViewModel
    @State var sourceEditorCode = """
    """
    @State var isEditing = false

    @Binding var frame: CGRect
    @Binding var position: CGSize
    @State private var isMoveGestureActivated = false
    @State var webViewURL: URL?
// START HANDLE WINDOW MOVEMENT GESTURE *********************************************************
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    TopBar(isEditing: $isEditing, onClose: {
                        windowManager.removeWindow(window: window)
                    }, windowInfo: window, webViewURL: getURL())
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
                                
                                //print(position)
                            }
                            .onEnded { value in
                                isMoveGestureActivated = false
                            }
                    )
                    .if(window.windowType == .repoTreeView || window.windowType == .windowListView ) { view in
                        view.simultaneousGesture(
                            TapGesture().onEnded {
                                self.windowManager.bringWindowToFront(window: self.window)
                            }
                        )
                    }
                    .environmentObject(windowManager)

// START SOURCE CODE WINDOW SETUP HANDLING *******************************************************
                    switch viewMode {

                    case .editor:
#if !os(macOS)
                        let viewModel = SourceCodeTextEditorViewModel()

                        SourceCodeTextEditor(text: $sageMultiViewModel.sourceCode, isEditing: $isEditing, customization:
                                                SourceCodeTextEditor.Customization(didChangeText:
                                                                                    { srcCodeTextEditor in
                            print("srcEditor didChangeText")

                        }, insertionPointColor: {
                            Colorv(cgColor: settingsViewModel.buttonColor.cgColor!)
                        }, lexerForSource: { lexer in
                            SwiftLexer()
                        }, textViewDidBeginEditing: { srcEditor in
                            print("srcEditor textViewDidBeginEditing")
                        }, theme: {
                            DefaultSourceCodeTheme(settingsViewModel: settingsViewModel)
                        }))
                        .onTapGesture {
                            self.windowManager.bringWindowToFront(window: self.window)
                        }
                        .environmentObject(viewModel)
#endif
                    case .webView:
                        let viewModel = WebViewViewModel()
                        WebView(url:getURL())
                            .onTapGesture {
                                self.windowManager.bringWindowToFront(window: self.window)
                            }
                            .environmentObject(viewModel)

                    case .repoTreeView:
                        NavigationView {
                            if let root = settingsViewModel.root {
                                RepositoryTreeView(settingsViewModel: settingsViewModel, directory: root, window: window)
                                    .environmentObject(windowManager)
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
                            WindowList(showAddView: $showAddView)
                                .environmentObject(windowManager)
                        }
#if !os(macOS)
                        .navigationViewStyle(StackNavigationViewStyle())
#endif
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
            .frame(width: SettingsViewModel.shared.middleHandleSize, height: SettingsViewModel.shared.middleHandleSize)
            .foregroundColor(Color.white.opacity(0.666))
    }
}
#endif
// END HANDLE WINDOW MOVEMENT GESTURE *************************************************

// START WINDOW RESIZING GESTURE ************************************************************************************
#if !os(macOS)
struct ResizableViewModifier: ViewModifier {
    @Binding var frame: CGRect
    @Binding var zoomScale: CGFloat
    var window: WindowInfo

    var handleSize: CGFloat = SettingsViewModel.shared.cornerHandleSize
    @EnvironmentObject var windowManager: WindowManager
    @Binding var boundPosition: CGSize

    func body(content: Content) -> some View {
        content
            .frame(width: frame.width, height: frame.height)
            .overlay(
                ResizingHandle(positionLocation: .topLeading, frame: $frame, handleSize: handleSize, zoomScale: $zoomScale, window: window, boundPosition: $boundPosition)
                    .environmentObject(windowManager)
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
    @EnvironmentObject var windowManager: WindowManager
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

        switch positionLocation {
        case .topLeading:
            newWidth = frame.width - translation.width
            newHeight = frame.height - translation.height
        }
        // TODO: MORE CONSTRAINTS
        // Keep windows from going to close top top

        frame.size.width = newWidth
        frame.size.height = newHeight
    }
}
// END WINDOW RESIZING GESTURE HANDLING ****************************************************************************

#endif
