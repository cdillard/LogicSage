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
            HStack(spacing: 1) {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                }
                .foregroundColor(SettingsViewModel.shared.buttonColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.leading, SettingsViewModel.shared.cornerHandleSize)

                if windowInfo.windowType == .project {
                    Button(action: {
                        logD("on side bar tap")
                    }) {
                        Image(systemName: "sidebar.left")
                            .font(.body)
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // IF Debugger is running....
                    if settingsViewModel.isDebugging {
                        Button(action: {
                            logD("on STOP tap")
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.body)
                        }
                        .foregroundColor(SettingsViewModel.shared.buttonColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    Button(action: {
                        logD("on PLAY tap")
                    }) {
                        Image(systemName: "play.fill")
                            .font(.body)
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
              
                Text(getName())
                    .font(.body)
                    .lineLimit(1)
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if windowInfo.windowType == .chat {

                    Button(action: {
                        logD("elips tap")
                    }) {
                        let convoText = settingsViewModel.convoText(settingsViewModel.conversations, window: windowInfo)
                        ShareLink(item: "\(link.absoluteString)\n\(convoText)", message: Text("LogicSage conversation")) {

                            Image(systemName: "ellipsis")
                                .font(.body)
                        }
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .padding(.trailing, 4)
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
            return "\(settingsViewModel.convoName(windowInfo.convoId ?? Conversation.ID(-1)))"
        case .project:
            return "SwiftSageiOS"
        case .file:
            return "\(windowInfo.file?.name ?? "Filename")"
        case .webView:
            return  "\(webViewURL?.absoluteString ?? "WebView")"
        case .repoTreeView:
            return "Files"
        case .windowListView:
            return "Windows"
        case .changeView:
            return "Changes"
        case .workingChangesView:
            return "Changes"
        }
    }
}
