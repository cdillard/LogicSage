//
//  TopBar.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/6/23.
//

import Foundation
import SwiftUI

struct TopBar: View {
    @Binding var isEditing: Bool
    var onClose: () -> Void
    @State var windowInfo: WindowInfo
    @State var webViewURL: URL?
    @EnvironmentObject var windowManager: WindowManager

    var body: some View {
        ZStack {
            HStack {

                if windowInfo.windowType == .file ||
                   windowInfo.windowType == .webView {

                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.leading, SettingsViewModel.shared.cornerHandleSize)
                }



                    Text(getName())
                        .font(.body)
                        .lineLimit(1)

                        .foregroundColor(SettingsViewModel.shared.buttonColor)
                        .padding(.leading, SettingsViewModel.shared.cornerHandleSize)

                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                Spacer()

                if windowInfo.windowType == .file {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Done" : "Edit")
                            .font(.body)
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.trailing, 8)
                }

            }
        }
//        .simultaneousGesture(
//            TapGesture().onEnded {
//                self.windowManager.bringWindowToFront(window: self.windowInfo)
//            }
//        )
        .background(SettingsViewModel.shared.backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: 30)
    }
    func getName() -> String {
        switch windowInfo.windowType {
        case .file:
            return "\(windowInfo.file?.name ?? "Filename")"
        case .webView:
            return  "\(webViewURL?.absoluteString ?? "WebView")"
        case .repoTreeView:
            return "Repo Tree"
        case .windowListView:
            return "Window List"
        case .changeView:
            return "Change View"
        case .workingChangesView:
            return "Working Changes"
        }
    }
}
