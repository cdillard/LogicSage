//
//  WindowList.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/7/23.
//

import Foundation
import SwiftUI

struct WindowList: View {
    @EnvironmentObject var windowManager: WindowManager
    @Binding var showAddView: Bool

    var body: some View {
        if !windowManager.windows.isEmpty {
            List {
                Text("tap to open window to foreground")
                    .foregroundColor(SettingsViewModel.shared.appTextColor)
                    .font(.caption2)
                ForEach(windowManager.windows.reversed()) { window in
                    VStack(alignment: .leading) {
                        Text(windowTitle(window: window))
                            .font(.headline)
                            .foregroundColor(SettingsViewModel.shared.appTextColor)

                        HStack {
                            Text("Frame:")
                                .font(.subheadline)
                            Text("X: \(window.frame.origin.x, specifier: "%.1f"), Y: \(window.frame.origin.y, specifier: "%.1f"), Width: \(window.frame.width, specifier: "%.1f"), Height: \(window.frame.height, specifier: "%.1f")")
                                .font(.footnote)
                        }
                        .foregroundColor(SettingsViewModel.shared.appTextColor)

                        HStack {
                            Text("Z-Index:")
                                .font(.subheadline)
                            Text("\(window.zIndex)")
                                .font(.footnote)
                        }
                        .foregroundColor(SettingsViewModel.shared.appTextColor)

                    }
                    .onTapGesture {
                        logD("bringing tapped view to front")
                        showAddView = false
                        windowManager.bringWindowToFront(window: window)
                    }
                }
            }
            .listRowBackground(SettingsViewModel.shared.backgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        else {
            Text("Open window and it will appear here")
                .frame(height: 30.0)
                .foregroundColor(SettingsViewModel.shared.appTextColor)
        }
    }

    private func windowTitle(window: WindowInfo) -> String {
        switch window.windowType {
        case .webView:
            return window.url ?? "Webview"
        case .file:
            return window.file?.name ?? "Filename"
        case .simulator:
            return "Simulator"
        case .chat:
            return "Chat \(window.convoId ?? "")"

        case .repoTreeView:
            return "Repo Tree"
        case .windowListView:
            return "Window List"
        case .changeView:
            return "Change List"
        case .workingChangesView:
            return "Working Changes"
        }
    }
}
