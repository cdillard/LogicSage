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

struct WindowView: View {
    var window: WindowInfo
    @State private var position: CGSize = CGSize.zero

    @State var frame: CGRect
    @StateObject private var pinchHandler = PinchGestureHandler()
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var windowManager: WindowManager
    @ObservedObject var viewModel: SageMultiViewModel
    @State private var showAddView: Bool = false

    @State private var isMoveGestureActivated = false
    @State private var isResizeGestureActive = false

    @State var viewSize: CGRect = .zero
    @State var resizeOffset: CGSize = .zero
    @State var bumping: Bool = false
    @Binding var parentViewSize: CGRect

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    windowContent()
                        .modifier(ResizableViewModifier(frame: $frame, window: window, boundPosition: $position, windowManager: windowManager, initialViewFrame: $viewSize, resizeOffset: $resizeOffset, isResizeGestureActive: $isResizeGestureActive))
                }
                .border(.red, width: bumping ? 2.666 : 0)
                .cornerRadius(8)
                .shadow(color:settingsViewModel.appTextColor, radius: 3)
                .frame(width: window.frame.width, height: window.frame.height)
            }
            .offset(position)
            .onAppear() {

                DispatchQueue.main.async {
                    recalculateWindowSize(size: geometry.size)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                DispatchQueue.main.async {
                    recalculateWindowSize(size: geometry.size)
                }
            }
            .onChange(of: geometry.size) { size in
                recalculateWindowSize(size: geometry.size)
                //                        logD("contentView viewSize update = \(viewSize)")
            }
            .onChange(of: horizontalSizeClass) { newSizeClass in
                print("Size class changed to \(String(describing: newSizeClass))")
                recalculateWindowSize(size: geometry.size)
            }
            .onChange(of: verticalSizeClass) { newSizeClass in
                print("Size class changed to \(String(describing: newSizeClass))")
                recalculateWindowSize(size: geometry.size)
            }
        }
    }

    private func recalculateWindowSize(size: CGSize) {
        if !isResizeGestureActive {

            viewSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)

            // OG position
            position = CGSize(width: size.width * 0.05, height: size.height * 0.1)
        }
    }
    private func windowContent() -> some View {
        let url = URL(string:settingsViewModel.defaultURL)

        switch window.windowType {
        case .webView:
            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .webView, windowManager: windowManager,  window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position, webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .file:

            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .editor, windowManager: windowManager, window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .chat:

            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .chat, windowManager: windowManager,  window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .simulator:

            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .simulator, windowManager: windowManager,  window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .repoTreeView:

            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .repoTreeView, windowManager: windowManager,  window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .windowListView:

            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .windowListView, windowManager: windowManager,  window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .changeView:

            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .changeView, windowManager: windowManager,  window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .workingChangesView:

            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .workingChangesView,  windowManager: windowManager, window: window,sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
        case .project:

            return AnyView(
                SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: .project,  windowManager: windowManager,  window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position,webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
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
