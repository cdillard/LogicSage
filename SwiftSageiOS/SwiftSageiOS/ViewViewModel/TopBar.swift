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
    @ObservedObject var settingsViewModel: SettingsViewModel

    let link = URL(string: "https://apps.apple.com/us/app/logicsage/id6448485441")!
    var body: some View {
        ZStack {
            HStack(spacing: 2) {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                }
                .foregroundColor(SettingsViewModel.shared.buttonColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .padding(.leading, SettingsViewModel.shared.cornerHandleSize)

                Text(getName())
                    .font(.body)
                    .lineLimit(1)

                    .foregroundColor(SettingsViewModel.shared.buttonColor)
//                    .padding(.leading, SettingsViewModel.shared.cornerHandleSize)

                    .frame(maxWidth: .infinity, maxHeight: .infinity)



                if windowInfo.windowType == .chat {

                    Button(action: {
                        logD("elips tap")
                    }) {
                        let convoText = convoText(settingsViewModel.conversations, window: windowInfo)
                        ShareLink(item: "\(link.absoluteString)\n\(convoText)", message: Text("LogicSage conversation")) {

                            Image(systemName: "ellipsis")
                                .font(.body)
                        }
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .padding(.leading, SettingsViewModel.shared.cornerHandleSize)
                }

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

                Spacer()
            }
        }
        .background(SettingsViewModel.shared.backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: 28)
    }
    func getName() -> String {
        switch windowInfo.windowType {
        case .simulator:
            return "Simulator"
        case .chat:
            return "Chat \(windowInfo.convoId?.prefix(4) ?? "")"

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
