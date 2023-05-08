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
                ForEach(windowManager.windows.reversed()) { window in
                    VStack(alignment: .leading) {
                        Text(windowTitle(window: window))
                            .font(.headline)
                        HStack {
                            Text("Frame:")
                                .font(.subheadline)
                            Text("X: \(window.frame.origin.x, specifier: "%.1f"), Y: \(window.frame.origin.y, specifier: "%.1f"), Width: \(window.frame.width, specifier: "%.1f"), Height: \(window.frame.height, specifier: "%.1f")")
                                .font(.footnote)
                        }
                        HStack {
                            Text("Z-Index:")
                                .font(.subheadline)
                            Text("\(window.zIndex)")
                                .font(.footnote)
                        }
                    }
                    .onTapGesture {
                        logD("bringing tapped view to front")
                        showAddView = false
                        windowManager.bringWindowToFront(window: window)
                    }
                }
            }
        }
        else {
            Text("Open window and it will appear here")
                .frame(height: 30.0)
        }
    }

    private func windowTitle(window: WindowInfo) -> String {
        switch window.windowType {
        case .webView:
            return window.url ?? "Webview"
        case .file:
            return window.file?.name ?? "Filename"
        }
    }
}
