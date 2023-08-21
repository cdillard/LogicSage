//
//  ResizingHandle.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/2/23.
//

import Foundation
import SwiftUI
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
    @Binding var dragCursorPoint: CGPoint

    func body(content: Content) -> some View {
        content
            .frame(width: frame.width, height: frame.height)
            .overlay(
                ZStack {
                    ResizingHandle(positionLocation: .topTrailing, frame: $frame, handleSize: handleSize, windowManager: windowManager, window: window, resizeOffset: $resizeOffset, isResizeGestureActive: $isResizeGestureActive, viewSize: $viewSize, position: $position, keyboardHeight: $keyboardHeight, dragCursorPoint: $dragCursorPoint)
                    ResizingHandle(positionLocation: .topLeading, frame: $frame, handleSize: handleSize, windowManager: windowManager, window: window, resizeOffset: $resizeOffset, isResizeGestureActive: $isResizeGestureActive, viewSize: $viewSize, position: $position,  keyboardHeight: $keyboardHeight, dragCursorPoint: $dragCursorPoint)
                    ResizingHandle(positionLocation: .bottomTrailing, frame: $frame, handleSize: handleSize, windowManager: windowManager, window: window, resizeOffset: $resizeOffset, isResizeGestureActive: $isResizeGestureActive, viewSize: $viewSize, position: $position,  keyboardHeight: $keyboardHeight, dragCursorPoint: $dragCursorPoint)
                        .offset(y: window.windowType == .chat ?  -keyboardHeight : 0)
                }
                
            )
//#if os(xrOS)
//        .glassBackgroundEffect()
//        #endif
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
    @Binding var dragCursorPoint: CGPoint

    var body: some View {
        GeometryReader { reader in
            let point = positionPoint(for: positionLocation)
            ZStack {
//                if activeDragLocation == .zero {

                    Circle()
                        .fill(SettingsViewModel.shared.buttonColor)
                        .frame(width: handleSize, height: handleSize)
                        .offset(CGSize(width: point.x, height: point.y))
                        .opacity(0.06)
#if !os(macOS)
                        .hoverEffect(.lift)
#endif
//                }

#if !os(macOS)
#if !os(tvOS)

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
#endif

            }
#if !os(tvOS)

            .gesture(

                DragGesture(minimumDistance: 3)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onChanged { value in
                        if keyboardHeight != 0 {
#if !os(macOS)
                            hideKeyboard()
#endif
                            return
                        }

                        if activeDragOffset == .zero {
                            if gestureDebugLogs {
                                print("STARTED RESIZE GESTURE")
                                print("start pos = \(position)")
                            }
                        }
                        activeDragOffset = value.translation
                        activeDragLocation = value.location

                        dragCursorPoint = CGPointMake(value.location.x  + position.width, value.location.y + position.height)

                        if gestureDebugLogs {

                            print("resize offset = \(resizeOffset)")
                        }
                        if !isResizeGestureActive {
                            isResizeGestureActive = true
                            self.windowManager.bringWindowToFront(window: self.window)
                        }
                    }
                    .onEnded { value in
                        if gestureDebugLogs {

                            print("ENDED RESIZE GESTURE")
                        }
                        updateFrame(with: value.translation, reader.size.width, reader.size.height, reader.safeAreaInsets)
                        activeDragOffset = .zero
                        activeDragLocation = .zero
                        dragCursorPoint = .zero

                        isResizeGestureActive = false
                    }
            )
#endif
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
        let minSize: CGFloat = 269.666
        let minSizeHeight: CGFloat = 299.666


        // Smoothly interpolate towards the new size
        let newOffsetX: CGFloat
        let newOffsetY: CGFloat

        switch positionLocation {
        case .topLeading:
            let lerpFactor: CGFloat = 0.09

            newWidth = translation.width < 0 ? max(minSize, frame.width + abs(translation.width)) : max(minSize, frame.width - translation.width)
            newHeight = translation.height < 0 ? max(minSizeHeight, frame.height + abs(translation.height)) : max(minSizeHeight, frame.height - translation.height)

            newOffsetX = (newWidth - frame.size.width) * lerpFactor
            newOffsetY = (newHeight - frame.size.height) * lerpFactor

        case .topTrailing:
            let lerpFactor: CGFloat = 0.02222

            newWidth = translation.width < 0 ? max(minSize, frame.width - abs(translation.width)) : max(minSize, frame.width + translation.width)
            newHeight = translation.height < 0 ? max(minSizeHeight, frame.height + abs(translation.height)) : max(minSizeHeight, frame.height - translation.height)

            newOffsetX = (newWidth - frame.size.width) * lerpFactor
            newOffsetY = (newHeight - frame.size.height) * lerpFactor

        case .bottomTrailing:
            let lerpFactor: CGFloat = 0.0222

            newWidth = max(minSize, frame.width + translation.width)
            newHeight = max(minSizeHeight, frame.height + translation.height)

            newOffsetX = (newWidth - frame.size.width) * lerpFactor
            newOffsetY = (newHeight - frame.size.height) * lerpFactor
        }

        // Check global X postion
        //  print("rez globPos = \(position.width - resizeOffset.width + newOffsetX)")

        if frame.size.width + newOffsetX > viewSize.width - 3.5 {
        }
        else {
            resizeOffset.width += newOffsetX
            frame.size.width += newOffsetX

            switch positionLocation {
            case .topLeading:
                break
            case .topTrailing:
                position.width += newOffsetX / 2

            case .bottomTrailing:
                position.width += newOffsetX / 2

            }
        }
        if frame.size.height + newOffsetY > viewSize.height - screenHeight * 0.075666 {
        }
        else {
            resizeOffset.height += newOffsetY
            frame.size.height += newOffsetY

            switch positionLocation {
            case .topLeading:
                break
            case .topTrailing:
                position.height += newOffsetY / 2

            case .bottomTrailing:
                position.height += newOffsetY / 2

            }

        }
        //        print("resizeOffset = \(resizeOffset)")
    }
}
#if !os(macOS)
struct BezierShape: Shape {
    var bezierPath: UIBezierPath

    func path(in rect: CGRect) -> Path {
        return Path(bezierPath.cgPath)
    }
}
#endif
