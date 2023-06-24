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
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
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
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .padding(.leading, 7)

                    // IF Debugger is running....
                    if settingsViewModel.isDebugging {
                        Button(action: {
                            logD("on STOP tap")
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.caption)
                                .minimumScaleFactor(0.75)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                        }
                        .foregroundColor(SettingsViewModel.shared.buttonColor)
                        .padding(.leading, 7)

                    }

                    Button(action: {
                        logD("on PLAY tap")
                    }) {
                        Image(systemName: "play.fill")
                            .font(.caption)
                            .minimumScaleFactor(0.75)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .padding(.leading, 7)
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
                        .padding(.trailing, SettingsViewModel.shared.cornerHandleSize + 8)

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
                            if #available(iOS 16.0, *) {
                                
                                ShareLink(item: "Check out LogicSage: the mobile AI workspace on the AppStore for free now: \(appLink.absoluteString)\nHere is the chat I had with my GPT.\n\(convoText)", message: Text("LogicSage convo"))
                                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                            }
                            if windowInfo.convoId == Conversation.ID(-1) {
                                
                            }
                            else {
                                Button {
                                    // either renaming file or chat
                                    if windowInfo.windowType == .file {
                                        
                                    }
                                    else if windowInfo.windowType == .chat {
#if !os(macOS)
                                        LogicSageDev.alert(subject: "convo", convoId: windowInfo.convoId)
#endif
                                    }
                                } label: {
                                    Label("Rename", systemImage: "rectangle.and.pencil.and.ellipsis")
                                        .font(.body)
                                        .labelStyle(DemoStyle())
                                        .foregroundColor(SettingsViewModel.shared.buttonColor)
                                }
                            }

                        } label: {
                            Label("", systemImage: "ellipsis")
                                .font(.body)
                                .labelStyle(DemoStyle())
                        }
                        .padding(.trailing, SettingsViewModel.shared.cornerHandleSize + 8)
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
