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
}
struct SageMultiView: View {

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
    // START HANDLE WINDOW MOVEMENT GESTURE *************************************

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    TopBar(isEditing: $isEditing, onClose: {
                        windowManager.removeWindow(window: window)
                    }, windowInfo: window, webViewURL: getURL())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isMoveGestureActivated {
                                    self.windowManager.bringWindowToFront(window: self.window)
                                    isMoveGestureActivated = true
                                }
                                let minY = geometry.safeAreaInsets.top
                                // Keep windows from going to close top top
                                var newY = max(position.height + value.translation.height, minY)

                                var newWidth = position.width + value.translation.width
                                if newWidth < 4 {
                                    newWidth = 4
                                }
                                // TODO: MORE CONSTRAINTS
//                                var newHeight = newY
//
//                                if newHeight > geometry.size.height - frame.height {
//                                    newHeight = geometry.size.height - frame.height
//                                }

                                position = CGSize(width: newWidth, height: newY)
                                
                                print(position)
                            }
                            .onEnded { value in
                                isMoveGestureActivated = false
                            }
                    )

                    // START SOURCE CODE WINDOW SETUP HANDLING *************************************

                    if viewMode == .editor {
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
                        .environmentObject(viewModel)
#endif
                    }
                    else {
                        let viewModel = WebViewViewModel()
                        WebView(url:getURL())
                            .environmentObject(viewModel)
                    }
                }
                // END SOURCE CODE WINDOW SETUP HANDLING *************************************

                Spacer()
            }
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
// END HANDLE WINDOW MOVEMENT GESTURE *************************************

// START WINDOW RESIZING GESTURE ****************************************************************************
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
        // TOP LEFT CONSTRAINT

//        if position.width < 5 {
//            position.width = 5
//        }
//        if position.height < 5 {
//            position.height = 5
//        }
        frame.size.width = newWidth
        frame.size.height = newHeight
        print(frame)
        print(boundPosition)
//        if newWidth > 4 && newHeight > 4 {
//            if newWidth > screenWidth {
//
//                frame.size.width = newWidth
//            }
//            else {
//                print("resize too wide, preventing")
//
//            }
//            if newHeight > screenHeight {
//
//                frame.size.height = newHeight
//            }
//            else {
//                print("resize too tall, preventing")
//            }
//
//        }
//        else {
//            print("resize too wide, preventing")
//
//        }
    }
}
// END WINDOW RESIZING GESTURE HANDLING ****************************************************************************

class SageMultiViewModel: ObservableObject {
    @Published var windowInfo: WindowInfo
    @Published var sourceCode: String

    init(windowInfo: WindowInfo) {
        self.windowInfo = windowInfo
        self.sourceCode = windowInfo.fileContents
    }
}

#endif
