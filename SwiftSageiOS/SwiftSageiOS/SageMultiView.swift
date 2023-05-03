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

    public var webViewURL = URL(string: "https://chat.openai.com")!
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State var theCode: String
    @State var viewMode: ViewMode

    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var position: CGSize = CGSize.zero
    @State private var frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)

//
//    @State private var currentEditorScale: CGFloat = 1.0
//    @State private var lastEditorScaleValue: CGFloat = 1.0
//    @State private var positionEditor: CGSize = CGSize.zero

    
    var body: some View {
        ZStack {
            HandleView()
                  .zIndex(2) // Add zIndex to ensure it's above the SageWebView
                  .offset(x: -12, y: -12) // Adjust the offset values
                  .gesture(
                      DragGesture()
                          .onChanged { value in
                              position = CGSize(width: position.width + value.translation.width, height: position.height + value.translation.height)
                          }
                          .onEnded { value in
                              // No need to reset the translation value, as it's read-only
                          }
                  )

            if viewMode == .editor && settingsViewModel.isEditorVisible {

#if !os(macOS)
                VStack {
                    SourceCodeTextEditor(text: $theCode)
                        .ignoresSafeArea()
                        .modifier(ResizableViewModifier(frame: $frame))
                        .scaleEffect(currentScale)
//                        .gesture(
//                            MagnificationGesture()
//                                .onChanged { scaleValue in
//                                    // Update the current scale based on the gesture's scale value
//                                    currentScale = lastScaleValue * scaleValue
//                                }
//                                .onEnded { scaleValue in
//                                    // Save the scale value when the gesture ends
//                                    lastScaleValue = currentScale
//                                }
//                        )
                }

#endif
            }
            else {
                WebView(url: webViewURL)
                    .ignoresSafeArea()
                    .modifier(ResizableViewModifier(frame: $frame))
                    .scaleEffect(currentScale)
//                    .gesture(
//                        MagnificationGesture()
//                            .onChanged { scaleValue in
//                                // Update the current scale based on the gesture's scale value
//                                currentScale = lastScaleValue * scaleValue
//                            }
//                            .onEnded { scaleValue in
//                                // Save the scale value when the gesture ends
//                                lastScaleValue = currentScale
//                            }
//                    )
            }

        }
        .offset(position)
    }
}

struct WebView: UIViewRepresentable {

    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the UIView (WKWebView) as needed
    }
}
struct HandleView: View {
    var body: some View {
        Circle()
            .frame(width: 28, height: 28)
            .foregroundColor(Color.white.opacity(0.75))
    }
}
#endif

#if !os(macOS)

struct ResizableViewModifier: ViewModifier {
    @Binding var frame: CGRect
    var handleSize: CGFloat = 20.0

    func body(content: Content) -> some View {
        content
            .frame(width: frame.width, height: frame.height)
            .overlay(ResizingHandle(position: .topLeading, frame: $frame, handleSize: handleSize))
            .overlay(ResizingHandle(position: .topTrailing, frame: $frame, handleSize: handleSize))
            .overlay(ResizingHandle(position: .bottomLeading, frame: $frame, handleSize: handleSize))
            .overlay(ResizingHandle(position: .bottomTrailing, frame: $frame, handleSize: handleSize))
    }
}


struct ResizingHandle: View {
    enum Position {
        case topLeading, topTrailing, bottomLeading, bottomTrailing
    }

    var position: Position
    @Binding var frame: CGRect
    var handleSize: CGFloat
    @State private var translation: CGSize = .zero

    var body: some View {
        Circle()
            .fill(SettingsViewModel.shared.buttonColor)
            .frame(width: handleSize, height: handleSize)
            .position(positionPoint(for: position))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        translation = value.translation
                    }
                    .onEnded { _ in
                        updateFrame(with: translation)
                        translation = .zero
                    }
            )
    }

    private func positionPoint(for position: Position) -> CGPoint {
        switch position {
        case .topLeading:
            return CGPoint(x: frame.minX + translation.width / 2, y: frame.minY + translation.height / 2)
        case .topTrailing:
            return CGPoint(x: frame.maxX + translation.width / 2, y: frame.minY + translation.height / 2)
        case .bottomLeading:
            return CGPoint(x: frame.minX + translation.width / 2, y: frame.maxY + translation.height / 2)
        case .bottomTrailing:
            return CGPoint(x: frame.maxX + translation.width / 2, y: frame.maxY + translation.height / 2)
        }
    }

    private func updateFrame(with translation: CGSize) {
        let newWidth: CGFloat
        let newHeight: CGFloat

        switch position {
        case .topLeading:
            newWidth = frame.width - translation.width
            newHeight = frame.height - translation.height
        case .topTrailing:
            newWidth = frame.width + translation.width
            newHeight = frame.height - translation.height
        case .bottomLeading:
            newWidth = frame.width - translation.width
            newHeight = frame.height + translation.height
        case .bottomTrailing:
            newWidth = frame.width + translation.width
            newHeight = frame.height + translation.height
        }

        // Set minimum size constraints to avoid negative size values
        frame.size.width = max(newWidth, handleSize * 2)
        frame.size.height = max(newHeight, handleSize * 2)
    }
}
#endif
