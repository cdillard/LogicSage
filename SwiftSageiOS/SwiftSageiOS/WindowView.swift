//
//  WindowView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/6/23.
//

import Foundation
import SwiftUI

struct WindowView: View {
    @EnvironmentObject var windowManager: WindowManager
    var window: WindowInfo
    @State private var position: CGSize = CGSize.zero
    @State var isEditing = false
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

            VStack {
                TopBar(isEditing: $isEditing, onClose: {
                    // Add close action here
                    windowManager.removeWindow(window: window)
                }, windowInfo: window)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                windowContent()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        // Add more window types as needed
        }
    }
}
