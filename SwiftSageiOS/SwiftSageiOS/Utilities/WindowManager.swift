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

    public static let shared = WindowManager()


    @Published var windows: [WindowInfo] = []

    func addWindow(windowType: WindowInfo.WindowType, frame: CGRect, zIndex: Int, file: RepoFile? = nil, fileContents: String = "", url: String = "", convoId: Conversation.ID? = nil) {

        // TODO: OFFSET NEW WINDOWS
        
        let newWindow = WindowInfo(frame: frame, zIndex: zIndex, windowType: windowType, fileContents: fileContents, file: file, url: url, convoId: convoId)
        windows.append(newWindow)
        sortWindowsByZIndex()
        bringWindowToFront(window: newWindow)

//        originPoint.x += offsetPoint.x
//        originPoint.y += offsetPoint.y

    }

    func removeWindow(window: WindowInfo) {
        if let index = windows.firstIndex(of: window) {
            windows.remove(at: index)
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
        guard let index = windows.firstIndex(of: window) else { return }
        let maxZIndex = windows.map({ $0.zIndex }).max() ?? 0
        windows[index].zIndex = maxZIndex + 1
        sortWindowsByZIndex()
    }
    
    private func sortWindowsByZIndex() {
        windows.sort(by: { $0.zIndex < $1.zIndex })
    }

    func topWindow() -> WindowInfo? {
        windows.first
    }

    func removeWindowsWithConvoId(convoID: Conversation.ID) {
        for window in windows {
            if window.convoId == convoID {
                removeWindow(window: window)
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

        case repoTreeView
        case windowListView
        case changeView
        case workingChangesView

    }
}



