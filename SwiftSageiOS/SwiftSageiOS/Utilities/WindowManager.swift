//
//  WindowManager.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/6/23.
//

import Foundation
import Combine
import SwiftUI

class WindowManager: ObservableObject {
    @Published var windows: [WindowInfo] = []
    @Published var windowViewModels: [SageMultiViewModel] = []
    @Published var topWindow: WindowInfo?

    func addWindow(windowType: WindowInfo.WindowType, frame: CGRect, zIndex: Int, file: RepoFile? = nil, fileContents: String = "", url: String = "", convoId: Conversation.ID? = nil) {
        // TODO: OFFSET NEW WINDOWS
        let newWindow = WindowInfo(frame: frame, zIndex: zIndex, windowType: windowType, fileContents: fileContents, file: file, url: url, convoId: convoId)
        windows.append(newWindow)

        let sageViewModel = SageMultiViewModel(settingsViewModel: SettingsViewModel.shared, windowId: newWindow.id, windowManager: self, windowInfo: newWindow, frame: frame, conversation: SettingsViewModel.shared.getConvo(convoId ?? Conversation.ID(-1)))

        sageViewModel.position = CGSize(width: 8, height: 40)
        windowViewModels.append(sageViewModel)

        sortWindowsByZIndex()
        bringWindowToFront(window: newWindow)
    }
    func removeWindow(window: WindowInfo) {
        if let index = windows.firstIndex(of: window) {
            windows.remove(at: index)
        }
        if let index = windowViewModels.firstIndex(where: { $0.windowInfo.id == window.id } ) {
            windowViewModels.remove(at: index)
        }

    }
    func updateWindow(window: WindowInfo, frame: CGRect, zIndex: Int? = nil) {
        if let index = windows.firstIndex(of: window) {
            windows[index].frame = frame
            if let zIndex = zIndex {
                windows[index].zIndex = zIndex
            }
            sortWindowsByZIndex()
        }
    }
    func bringWindowToFront(window: WindowInfo) {
        if let index = windowViewModels.firstIndex(where: { $0.windowInfo.id == window.id } ) {
            let maxZIndex = windowViewModels.map({ $0.windowInfo.zIndex }).max() ?? 0
            windowViewModels[index].windowInfo.zIndex = maxZIndex + 1
            sortWindowsByZIndex()
        }

        print("zIndex of window \(window.id) brought to front")
        guard let index = windows.firstIndex(of: window) else { return }
        let maxZIndex = windows.map({ $0.zIndex }).max() ?? 0
        windows[index].zIndex = maxZIndex + 1

        setTopWindow()


    }
    private func sortWindowsByZIndex() {
        windows.sort(by: { $0.zIndex < $1.zIndex })
        windowViewModels.sort { lhs, rhs in
            lhs.windowInfo.zIndex < rhs.windowInfo.zIndex
        }

    }
    func setTopWindow() { //-> WindowInfo? {
    topWindow = windows.first
    }
    func removeWindowsWithConvoId(convoID: Conversation.ID) {
        for window in windows {
            if window.convoId == convoID {
                removeWindow(window: window)

                if let index = windowViewModels.firstIndex(where: { $0.windowInfo.id == window.id } ) {
                    windowViewModels.remove(at: index)
                }
            }
        }
    }
}

struct WindowInfo: Identifiable, Equatable {
    let id = UUID()
    var frame: CGRect
    var zIndex: Int
    var windowType: WindowType
    var fileContents: String
    var file: RepoFile?
    var url: String?
    var convoId: Conversation.ID?

    enum WindowType {
        case webView
        case file
        case simulator
        case chat
        case project

        case repoTreeView
        case windowListView
        case changeView
        case workingChangesView
    }
}
