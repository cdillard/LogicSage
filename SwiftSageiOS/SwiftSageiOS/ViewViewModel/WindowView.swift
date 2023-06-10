//
//  WindowView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/6/23.
//

import Foundation
import SwiftUI

var defSize = CGRect(x: 0, y: 0, width: 300, height: 300)
var defChatSize = CGRect(x: 0, y: 0, width: 300, height: 300)


#if !os(macOS)

// Placeholder replaced by geometry reader.

struct WindowView: View {
     var window: WindowInfo
    @State private var position: CGSize = .zero

    @State var frame: CGRect
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
    let url = URL(string:SettingsViewModel.shared.defaultURL)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    windowContent()
                        .modifier(ResizableViewModifier(frame: $frame, window: window, windowManager: windowManager, resizeOffset: $resizeOffset, isResizeGestureActive: $isResizeGestureActive, viewSize: $viewSize, position: $position))
                }
                .border(.red, width: bumping ? 2.666 : 0)
                .cornerRadius(8)
                .shadow(color:settingsViewModel.appTextColor, radius: 3)
                .frame(width: window.frame.width, height: window.frame.height)
                .edgesIgnoringSafeArea(.bottom)
            }
            .offset(position)
            .onAppear() {
                recalculateWindowSize(size: geometry.size)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                recalculateWindowSize(size: geometry.size)
            }
            .onChange(of: geometry.size) { size in
                recalculateWindowSize(size: geometry.size)
                //                        logD("contentView viewSize update = \(viewSize)")
            }
            .onChange(of: horizontalSizeClass) { newSizeClass in
               // print("Size class changed to \(String(describing: newSizeClass))")
                recalculateWindowSize(size: geometry.size)
            }
            .onChange(of: verticalSizeClass) { newSizeClass in
               // print("Size class changed to \(String(describing: newSizeClass))")
                recalculateWindowSize(size: geometry.size)
            }
        }
    }

    private func recalculateWindowSize(size: CGSize) {
        if !isResizeGestureActive {
            viewSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
    }
    private func windowContent() -> some View {
        return AnyView(
            SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: windowTypeToViewMode(windowType: window.windowType), windowManager: windowManager,  window: window, sageMultiViewModel: viewModel, frame: $frame, position: $position, webViewURL: url, viewSize: $parentViewSize, resizeOffset: $resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
}

func windowTypeToViewMode(windowType: WindowInfo.WindowType) -> ViewMode {
    switch windowType {
    case .webView:
        return .webView
    case .file:
        return .editor
    case .chat:
        return .chat
    case .simulator:
        return .simulator
    case .repoTreeView:
        return .repoTreeView
    case .windowListView:
        return .windowListView
    case .changeView:
        return .changeView
    case .workingChangesView:
        return .workingChangesView
    case .project:
        return .project
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
