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
    @ObservedObject var settingsViewModel: SettingsViewModel
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .minimumScaleFactor(0.75)
                }
                .foregroundColor(SettingsViewModel.shared.buttonColor)
                .padding(.leading, SettingsViewModel.shared.cornerHandleSize + 8)

                if windowInfo.windowType == .project {
                    Button(action: {
                        logD("on side bar tap")
                    }) {
                        Image(systemName: "sidebar.left")
                            .font(.caption)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)

                    // IF Debugger is running....
                    if settingsViewModel.isDebugging {
                        Button(action: {
                            logD("on STOP tap")
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.caption)
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundColor(SettingsViewModel.shared.buttonColor)
                    }

                    Button(action: {
                        logD("on PLAY tap")
                    }) {
                        Image(systemName: "play.fill")
                            .font(.caption)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                }

                Text(getName())
                    .font(.body)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()

                if windowInfo.windowType == .chat || windowInfo.windowType == .file {
                    if isEditing {
                        Button {
                            isEditing.toggle()
                        } label: {
                            Label( "Done", systemImage: "checkmark")
                                .font(.body)
                                .labelStyle(DemoStyle())
                                .foregroundColor(SettingsViewModel.shared.buttonColor)
                        }
                    }
                    else {
                        Menu {
                            Button {
                                isEditing.toggle()

                            } label: {
                                Label(isEditing ? "Done" : windowInfo.windowType == .chat ? "Select" : "Edit", systemImage: "pencil")
                                    .font(.body)
                                    .labelStyle(DemoStyle())
                                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                            }

                            let convoText = settingsViewModel.convoText(settingsViewModel.conversations, window: windowInfo)
                            ShareLink(item: "\(SettingsViewModel.link.absoluteString)\n\(convoText)", message: Text("LogicSage convo"))
                                .foregroundColor(SettingsViewModel.shared.buttonColor)
                        } label: {
                            Label("", systemImage: "ellipsis")
                                .font(.body)
                                .labelStyle(DemoStyle())
                        }
                        .foregroundColor(SettingsViewModel.shared.buttonColor)
                    }
                }
            }
        }
        .background(SettingsViewModel.shared.backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: SettingsViewModel.shared.cornerHandleSize)
    }
    struct DemoStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .center) {
                configuration.icon
                configuration.title
            }
        }
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
