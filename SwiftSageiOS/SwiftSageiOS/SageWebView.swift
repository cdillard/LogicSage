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

struct SageWebView: View {
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var position: CGSize = CGSize.zero

    public var webViewURL = URL(string: "https://chat.openai.com")!

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
  
            WebView(url: webViewURL)
                .ignoresSafeArea()

                .scaleEffect(currentScale)
                .offset(position)
                .gesture(
                    MagnificationGesture()
                                     .onChanged { scaleValue in
                                         // Update the current scale based on the gesture's scale value
                                         currentScale = lastScaleValue * scaleValue
                                     }
                                     .onEnded { scaleValue in
                                         // Save the scale value when the gesture ends
                                         lastScaleValue = currentScale
                                     }
                             )
                .zIndex(1) // Add zIndex to ensure it's above the handle
                             .gesture(
                                 DragGesture()
                                     .onChanged { value in
                                         position = CGSize(width: position.width + value.translation.width, height: position.height + value.translation.height)
                                     }

                             )

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
