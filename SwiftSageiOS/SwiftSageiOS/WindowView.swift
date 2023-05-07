//
//  WindowView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/6/23.
//

import Foundation
import SwiftUI
#if !os(macOS)

let defSize = CGRect(x: 0, y: 0, width: 300, height: 300)

struct WindowView: View {
    @EnvironmentObject var windowManager: WindowManager
    var window: WindowInfo
    @State private var position: CGSize = CGSize.zero
    @State var isEditing = false


    @State private var frame: CGRect = defSize
    @StateObject private var pinchHandler = PinchGestureHandler()

    @State private var isMoveGestureActivated = false
    var body: some View {
        ZStack {
            HandleView()
                  .zIndex(2)
                  .offset(x: -12, y: -12)
                  .gesture(
                      DragGesture()
                          .onChanged { value in
                              if !isMoveGestureActivated {
                                  self.windowManager.bringWindowToFront(window: self.window)
                                  isMoveGestureActivated = true
                              }

                              position = CGSize(width: position.width + value.translation.width, height: position.height + value.translation.height)
                          }
                          .onEnded { value in
                              isMoveGestureActivated = false
                          }
                  )

            VStack {
                TopBar(isEditing: $isEditing, onClose: {
                    windowManager.removeWindow(window: window)
                }, windowInfo: window)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                windowContent()
                    .modifier(ResizableViewModifier(frame: $frame, zoomScale: $pinchHandler.scale, window: window))
                    .environmentObject(windowManager)
            }
            .cornerRadius(8)
            .shadow(radius: 10)
            .frame(width: window.frame.width, height: window.frame.height)
            .onTapGesture {
                 self.windowManager.bringWindowToFront(window: self.window)
             }

        }
        .offset(position)

    }

    private func windowContent() -> some View {
        switch window.windowType {
        case .webView:
            let viewModel = SageMultiViewModel(windowInfo: window, isEditing: isEditing)
            return AnyView(SageMultiView(settingsViewModel: SettingsViewModel.shared, viewMode: .webView).environmentObject(viewModel))
        case .file:
            let viewModel = SageMultiViewModel(windowInfo: window, isEditing: isEditing)
            return AnyView(SageMultiView(settingsViewModel: SettingsViewModel.shared, viewMode: .editor).environmentObject(viewModel))
        }
    }
}
#endif
