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
#if !os(xrOS)

struct WindowView: View {

     var window: WindowInfo

    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var windowManager: WindowManager
    @ObservedObject var viewModel: SageMultiViewModel
    @State private var showAddView: Bool = false

    @State private var isMoveGestureActivated = false
    @State private var isResizeGestureActive = false
    
    @State var bumping: Bool = false
    @Binding var parentViewSize: CGRect
    @Binding var keyboardHeight: CGFloat

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let url = URL(string:SettingsViewModel.shared.defaultURL)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    windowContent()
                        .modifier(ResizableViewModifier(frame: $viewModel.frame, window: viewModel.windowInfo, windowManager: windowManager, resizeOffset: $viewModel.resizeOffset, isResizeGestureActive: $isResizeGestureActive, viewSize: $viewModel.viewSize, position: $viewModel.position, keyboardHeight: $keyboardHeight))
                }
                .border(.red, width: bumping ? 2.666 : 0)

//                .modify { view in
//                    if bumping {
//                        view.border(.red, width: 2.666 )
//                    }
//                }
                .cornerRadius(16)
                .shadow(color:settingsViewModel.appTextColor, radius: 1)
                .frame(width: viewModel.windowInfo.frame.width, height: viewModel.windowInfo.frame.height)
                .edgesIgnoringSafeArea(.bottom)
            }
            .offset(viewModel.position)
            .onAppear() {
                recalculateWindowSize(size: geometry.size)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                recalculateWindowSize(size: geometry.size)
            }
            .onChange(of: geometry.size) { size in
                recalculateWindowSize(size: geometry.size)
            }
            .onChange(of: horizontalSizeClass) { newSizeClass in
                recalculateWindowSize(size: geometry.size)
            }
            .onChange(of: verticalSizeClass) { newSizeClass in
                recalculateWindowSize(size: geometry.size)
            }
        }
    }

    private func recalculateWindowSize(size: CGSize) {
        if !isResizeGestureActive {
            viewModel.viewSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
    }
    private func windowContent() -> some View {
        return AnyView(
            SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: windowTypeToViewMode(windowType: viewModel.windowInfo.windowType), windowManager: windowManager,  window: viewModel.windowInfo, sageMultiViewModel: viewModel, frame: $viewModel.frame, position: $viewModel.position,  isMoveGestureActivated: $isMoveGestureActivated, webViewURL: url, viewSize: $parentViewSize, resizeOffset: $viewModel.resizeOffset, bumping: $bumping, isResizeGestureActive: $isResizeGestureActive, keyboardHeight: $keyboardHeight)
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
