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
    @EnvironmentObject var windowManager: WindowManager
    var window: WindowInfo
    @State private var position: CGSize = CGSize.zero


    @State var frame: CGRect
    @StateObject private var pinchHandler = PinchGestureHandler()
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var showAddView: Bool = false

    @State private var isMoveGestureActivated = false
    var body: some View {
            ZStack {
                VStack {
                    windowContent()
                        .modifier(ResizableViewModifier(frame: $frame, zoomScale: $pinchHandler.scale, window: window, boundPosition: $position))
                        .environmentObject(windowManager)
                }
                .cornerRadius(8)
                .shadow(color:settingsViewModel.appTextColor, radius: 10)
                .frame(width: window.frame.width, height: window.frame.height)
            }
            .offset(position)
    }
    private var shouldApplyTapGest: Bool {
        if window.windowType == .file || window.windowType == .webView {
            return true
        }

        return false
    }
    private func windowContent() -> some View {
        switch window.windowType {
        case .webView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .webView, window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position, webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(windowManager)
            )
        case .file:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .editor, window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(viewModel)
                    .environmentObject(windowManager)
            )
        case .chat:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .chat, window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(viewModel)
                    .environmentObject(windowManager)
            )
        case .simulator:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .simulator, window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(viewModel)
                    .environmentObject(windowManager)
            )
        case .repoTreeView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .repoTreeView, window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(viewModel)
                    .environmentObject(windowManager)
            )
        case .windowListView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .windowListView, window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(viewModel)
                    .environmentObject(windowManager)
            )
        case .changeView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .changeView, window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(viewModel)
                    .environmentObject(windowManager)
            )
        case .workingChangesView:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .workingChangesView, window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(viewModel)
                    .environmentObject(windowManager)
            )
        case .project:
            let viewModel = SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window)
            let url = URL(string:settingsViewModel.defaultURL)
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .project, window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(viewModel)
                    .environmentObject(windowManager)
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
