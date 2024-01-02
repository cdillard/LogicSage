//
//  WindowView.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/6/23.
//

import Foundation
import SwiftUI

var defSize = CGRect(x: 0, y: 0, width: 300, height: 300)
var defChatSize = CGRect(x: 0, y: 0, width: 300, height: 300)

struct WindowView: View {

     var window: WindowInfo

    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var windowManager: WindowManager
    @ObservedObject var viewModel: SageMultiViewModel
    @State private var showAddView: Bool = false

    @State private var isMoveGestureActivated = false
    @State private var isResizeGestureActive = false
    
    @State var bumping: Bool = false
    @State var bumpingVertically: Bool = false

    @Binding var parentViewSize: CGRect
    @Binding var keyboardHeight: CGFloat
    @Binding var dragCursorPoint: CGPoint

#if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
#endif
    @State var focused = false

    let url = URL(string:SettingsViewModel.shared.defaultURL)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    windowContent()
                        .modifier(ResizableViewModifier(frame: $viewModel.frame, window: viewModel.windowInfo, windowManager: windowManager, resizeOffset: $viewModel.resizeOffset, isResizeGestureActive: $isResizeGestureActive, viewSize: $viewModel.viewSize, position: $viewModel.position, keyboardHeight: $keyboardHeight, dragCursorPoint: $dragCursorPoint, focused: $focused))
#if os(visionOS)
                        .background(settingsViewModel.backgroundColorSrcEditor)
#endif
                }
                
#if !os(macOS)
                .border(.red, width: bumping ? 2.666 : 0)
                .border(.blue, width: bumpingVertically ? 2.666 : 0)
#endif
                .cornerRadius(16)
                .shadow(color:settingsViewModel.appTextColor, radius: 1)
                .frame(width: viewModel.windowInfo.frame.width, height: viewModel.windowInfo.frame.height)
                .edgesIgnoringSafeArea(.bottom)

            }
            .offset(viewModel.position)
            .onAppear() {
                recalculateWindowSize(size: geometry.size)
            }
#if !os(visionOS)
#if !os(macOS)
#if !os(tvOS)
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
#endif
#endif
#endif
#if os(visionOS)
            .onChange(of: parentViewSize) {
                recalculateWindowSize(size: parentViewSize.size)
            }
#endif
        }
    }

    private func recalculateWindowSize(size: CGSize) {
        if !isResizeGestureActive {
            viewModel.viewSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
    }
    private func windowContent() -> some View {
        return AnyView(
            SageMultiView(showAddView: $showAddView, settingsViewModel: settingsViewModel, viewMode: windowTypeToViewMode(windowType: viewModel.windowInfo.windowType), windowManager: windowManager,  window: viewModel.windowInfo, sageMultiViewModel: viewModel, frame: $viewModel.frame, position: $viewModel.position,  isMoveGestureActivated: $isMoveGestureActivated, webViewURL: url, viewSize: $parentViewSize, resizeOffset: $viewModel.resizeOffset, bumping: $bumping,bumpingVertically: $bumpingVertically, isResizeGestureActive: $isResizeGestureActive, keyboardHeight: $keyboardHeight, focused: $focused)
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

