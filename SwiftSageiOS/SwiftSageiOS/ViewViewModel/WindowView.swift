//
//  WindowView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/6/23.
//

import Foundation
import SwiftUI
#if !os(macOS)

// Placeholder replaced by geometry reader.
var defSize = CGRect(x: 0, y: 0, width: 300, height: 300)
var defChatSize = CGRect(x: 0, y: 0, width: 300, height: 300)

let offsetPoint = CGPoint(x: 50, y: 50)
var originPoint = CGPoint(x: 0, y: 0)

struct WindowView: View {
//    @EnvironmentObject var windowManager: WindowManager
    var window: WindowInfo
    @State private var position: CGSize = CGSize.zero


    @State var frame: CGRect
    @StateObject private var pinchHandler = PinchGestureHandler()
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var windowManager: WindowManager

    @State private var showAddView: Bool = false

    @State private var isMoveGestureActivated = false
    var body: some View {
            ZStack {
                VStack {
                    windowContent()
                        .modifier(ResizableViewModifier(frame: $frame, zoomScale: $pinchHandler.scale, window: window, boundPosition: $position, windowManager: windowManager))
                }
                .cornerRadius(8)
                .shadow(color:settingsViewModel.appTextColor, radius: 10)
                .frame(width: window.frame.width, height: window.frame.height)
            }
            .offset(position)
    }
    private func windowContent() -> some View {
        switch window.windowType {
        case .webView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .webView, windowManager: windowManager,  window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position, webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .file:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .editor, windowManager: windowManager, window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .chat:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .chat, windowManager: windowManager,  window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .simulator:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .simulator, windowManager: windowManager,  window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .repoTreeView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .repoTreeView, windowManager: windowManager,  window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .windowListView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .windowListView, windowManager: windowManager,  window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .changeView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .changeView, windowManager: windowManager,  window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .workingChangesView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .workingChangesView,  windowManager: windowManager, window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .project:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .project,  windowManager: windowManager,  window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        }
    }
}
#endif
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
