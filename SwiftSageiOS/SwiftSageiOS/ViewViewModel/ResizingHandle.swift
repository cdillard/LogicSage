//
//  ResizingHandle.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 6/2/23.
//

import Foundation
import SwiftUI
import WebKit
import Combine
#if !os(macOS)
import UIKit
#endif

struct ResizableViewModifier: ViewModifier {
    @Binding var frame: CGRect
    var window: WindowInfo
    var handleSize: CGFloat = SettingsViewModel.shared.cornerHandleSize
    @Binding var boundPosition: CGSize
    @ObservedObject var windowManager: WindowManager
    @Binding var initialViewFrame: CGRect
    @Binding var resizeOffset: CGSize
    @Binding var isResizeGestureActive: Bool

    func body(content: Content) -> some View {
        content
            .frame(width: frame.width, height: frame.height)
            .overlay(
                ResizingHandle(positionLocation: .topLeading, frame: $frame, handleSize: handleSize, windowManager: windowManager, window: window, boundPosition: $boundPosition, initialViewFrame: $initialViewFrame, resizeOffset: $resizeOffset, isResizeGestureActive: $isResizeGestureActive)
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
    @GestureState private var dragOffset: CGSize = .zero
    @State private var activeDragOffset: CGSize = .zero
    @ObservedObject var windowManager: WindowManager
    var window: WindowInfo
    @Binding var boundPosition: CGSize
    @Binding var initialViewFrame: CGRect
    @Binding var resizeOffset: CGSize
    @Binding var isResizeGestureActive: Bool

// Throttling not required on resizing gesture, for now.
//    @State private var lastDragTime = Date()

    var body: some View {
        GeometryReader { reader in
            Circle()
                .fill(SettingsViewModel.shared.buttonColor)
                .frame(width: handleSize, height: handleSize)
                .position(positionPoint(for: positionLocation))
                .opacity(0.666)
            // TODO: Add resizing contraints so users don't resize to a place they can't return from.
                .gesture(
                    DragGesture(minimumDistance: 3)
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onChanged { value in
//                            let now = Date()
//                            if now.timeIntervalSince(self.lastDragTime) >= (1.0 / 30.0) { // throttle duration
//                                self.lastDragTime = now
                                activeDragOffset = value.translation
                                
                                if !isResizeGestureActive {
                                    isResizeGestureActive = true
                                    self.windowManager.bringWindowToFront(window: self.window)
                                }
                           // }
                        }
                        .onEnded { value in
                            updateFrame(with: value.translation, reader.size.width, reader.size.height, reader.safeAreaInsets)
                            activeDragOffset = .zero
                            isResizeGestureActive = false
                        }
                )
                .onChange(of: activeDragOffset) { newValue in
                    withAnimation(.interactiveSpring()) {
                        updateFrame(with: newValue, reader.size.width, reader.size.height, reader.safeAreaInsets)
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

    private func updateFrame(with translation: CGSize, _ screenWidth: CGFloat, _ screenHeight: CGFloat, _  safeAreaInsets: EdgeInsets) {
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
        let newOffsetX = (newWidth - frame.size.width) * lerpFactor
        let newOffsetY = (newHeight - frame.size.height) * lerpFactor

        if frame.size.width + newOffsetX > initialViewFrame.width {
        }
        else {
            resizeOffset.width += newOffsetX
            frame.size.width += newOffsetX
        }
        if frame.size.height + newOffsetY > initialViewFrame.height {
        }
        else {
            resizeOffset.height += newOffsetY
            frame.size.height += newOffsetY
        }

        print("resizeOffset = \(resizeOffset)")
    }
}
