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
    @ObservedObject var windowManager: WindowManager
    @Binding var resizeOffset: CGSize
    @Binding var isResizeGestureActive: Bool
    @Binding var viewSize: CGRect
    @Binding var position: CGSize
    @Binding var keyboardHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(width: frame.width, height: frame.height)
            .overlay(
                ZStack {
                    ResizingHandle(positionLocation: .topTrailing, frame: $frame, handleSize: handleSize, windowManager: windowManager, window: window, resizeOffset: $resizeOffset, isResizeGestureActive: $isResizeGestureActive, viewSize: $viewSize, position: $position, keyboardHeight: $keyboardHeight)
                    ResizingHandle(positionLocation: .topLeading, frame: $frame, handleSize: handleSize, windowManager: windowManager, window: window, resizeOffset: $resizeOffset, isResizeGestureActive: $isResizeGestureActive, viewSize: $viewSize, position: $position,  keyboardHeight: $keyboardHeight)
                    ResizingHandle(positionLocation: .bottomTrailing, frame: $frame, handleSize: handleSize, windowManager: windowManager, window: window, resizeOffset: $resizeOffset, isResizeGestureActive: $isResizeGestureActive, viewSize: $viewSize, position: $position,  keyboardHeight: $keyboardHeight)
                }
            )
    }
}

struct ResizingHandle: View {
    enum Position {
        case topLeading
        case topTrailing
        case bottomTrailing

    }

    var positionLocation: Position
    @Binding var frame: CGRect
    var handleSize: CGFloat
    @GestureState private var dragOffset: CGSize = .zero
    @State private var activeDragOffset: CGSize = .zero
    @State private var activeDragLocation: CGPoint = .zero

    @ObservedObject var windowManager: WindowManager
    var window: WindowInfo
    @Binding var resizeOffset: CGSize
    @Binding var isResizeGestureActive: Bool
    @Binding var viewSize: CGRect
    @Binding var position: CGSize
    @Binding var keyboardHeight: CGFloat

    var body: some View {
        GeometryReader { reader in
            let point = positionPoint(for: positionLocation)
            ZStack {
                if activeDragLocation == .zero {

                    Circle()
                        .fill(SettingsViewModel.shared.buttonColor)
                        .frame(width: handleSize, height: handleSize)
                        .offset(CGSize(width: point.x, height: point.y))
                        .opacity(0.06)
#if !os(macOS)
                        .hoverEffect(.lift)
#endif
                }

#if !os(macOS)

                if positionLocation == .topTrailing {
                    CustomPointerRepresentableView(mode: .topRight)
                        .frame(width: handleSize, height: handleSize)
                        .offset(x: reader.size.width - handleSize)
                }
                else if positionLocation == .bottomTrailing {
                    CustomPointerRepresentableView(mode: .topLeft)
                        .frame(width: handleSize, height: handleSize)
                        .offset(x: reader.size.width - handleSize, y: reader.size.height - handleSize - 10)
                }
#endif
                if activeDragLocation != .zero {
#if !os(macOS)
                    let bezPath: UIBezierPath = positionLocation != .topTrailing ? Beziers.createTopLeft() : Beziers.createTopRight()
                    BezierShape(bezierPath: bezPath)
                        .stroke(Color.white.opacity(0.5), lineWidth: 4)
                        .offset(x: activeDragLocation.x - 7.5, y: activeDragLocation.y - 15.5)
                        .allowsTightening(false)
#endif
                }
            }
            .gesture(
                DragGesture(minimumDistance: 3)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onChanged { value in
                        // Disable move gesture while keyboard is shown, its dangerous, I like it.
                        if keyboardHeight != 0 {
#if !os(macOS)
                            hideKeyboard()
#endif
                            return
                        }

                        if activeDragOffset == .zero {
                            print("STARTED RESIZE GESTURE")
                           // print("start pos = \(position)")
                        }
                        activeDragOffset = value.translation
                        activeDragLocation = value.location
                       // print("move pos = \(position)")

                        if !isResizeGestureActive {
                            isResizeGestureActive = true
                            self.windowManager.bringWindowToFront(window: self.window)
                        }
                    }
                    .onEnded { value in

                        print("ENDED RESIZE GESTURE")

                        updateFrame(with: value.translation, reader.size.width, reader.size.height, reader.safeAreaInsets)
                        activeDragOffset = .zero
                        activeDragLocation = .zero
                        isResizeGestureActive = false
                    }
            )
            .onChange(of: activeDragOffset) { newValue in
                withAnimation(.interactiveSpring()) {
                    updateFrame(with: newValue, reader.size.width, reader.size.height, reader.safeAreaInsets)
                }
            }
            .animation(.interactiveSpring(), value: activeDragOffset)

        }
    }
    private func positionPoint(for position: Position) -> CGPoint {
        switch position {
        case .topLeading:
            return CGPoint(x: frame.minX, y: 0)
        case .topTrailing:
            return CGPoint(x: frame.minX + frame.width - handleSize, y: 0)
        case .bottomTrailing:
            return CGPoint(x: frame.width - handleSize, y: frame.height - handleSize - 10)
        }
    }

    private func updateFrame(with translation: CGSize, _ screenWidth: CGFloat, _ screenHeight: CGFloat, _  safeAreaInsets: EdgeInsets) {
        let newWidth: CGFloat
        let newHeight: CGFloat
        let minSize: CGFloat = 121.666


        // Smoothly interpolate towards the new size
        let newOffsetX: CGFloat
        let newOffsetY: CGFloat

        switch positionLocation {
        case .topLeading:
            let lerpFactor: CGFloat = 0.09

            newWidth = translation.width < 0 ? max(minSize, frame.width + abs(translation.width)) : max(minSize, frame.width - translation.width)
            newHeight = translation.height < 0 ? max(minSize, frame.height + abs(translation.height)) : max(minSize, frame.height - translation.height)

            newOffsetX = (newWidth - frame.size.width) * lerpFactor
            newOffsetY = (newHeight - frame.size.height) * lerpFactor

        case .topTrailing:
            let lerpFactor: CGFloat = 0.02222

            newWidth = translation.width < 0 ? max(minSize, frame.width - abs(translation.width)) : max(minSize, frame.width + translation.width)
            newHeight = translation.height < 0 ? max(minSize, frame.height + abs(translation.height)) : max(minSize, frame.height - translation.height)

            newOffsetX = (newWidth - frame.size.width) * lerpFactor
            newOffsetY = (newHeight - frame.size.height) * lerpFactor

        case .bottomTrailing:
            // Fix calc
            let lerpFactor: CGFloat = 0.0122

            newWidth = max(minSize, frame.width + translation.width)
            newHeight = max(minSize, frame.height + translation.height)

            newOffsetX = (newWidth - frame.size.width) * lerpFactor
            newOffsetY = (newHeight - frame.size.height) * lerpFactor
        }

        // Check global X postion
        //  print("rez globPos = \(position.width - resizeOffset.width + newOffsetX)")

        if frame.size.width + newOffsetX > viewSize.width - 4.5 {
        }
        else {
            resizeOffset.width += newOffsetX
            frame.size.width += newOffsetX
        }
        if frame.size.height + newOffsetY > viewSize.height - screenHeight * 0.08 {
        }
        else {
            resizeOffset.height += newOffsetY
            frame.size.height += newOffsetY
        }
        //        print("resizeOffset = \(resizeOffset)")
    }
}
struct BezierShape: Shape {
    var bezierPath: UIBezierPath

    func path(in rect: CGRect) -> Path {
        return Path(bezierPath.cgPath)
    }
}
