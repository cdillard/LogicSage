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

    func addWindow(windowType: WindowInfo.WindowType, frame: CGRect, zIndex: Int, file: GitHubContent? = nil, fileContents: String = "") {
        let newWindow = WindowInfo(frame: frame, zIndex: zIndex, windowType: windowType, fileContents: fileContents, file: file)
        windows.append(newWindow)
        sortWindowsByZIndex()
        bringWindowToFront(window: newWindow)
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
}

struct WindowInfo: Identifiable, Equatable {
    let id = UUID()
    var frame: CGRect
    var zIndex: Int
    var windowType: WindowType
    var fileContents: String
    var file: GitHubContent?
    
    enum WindowType {
        case webView
        case file
        // Add more window types as needed
    }
}



