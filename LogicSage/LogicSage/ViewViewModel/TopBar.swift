//
//  TopBar.swift
//  LogicSage
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
    @Binding var keyboardHeight: CGFloat

    @State var presentRenamer: Bool = false
    @State var presentDeleter: Bool = false
    @State var presentURLChanger: Bool = false

    @State private var newName: String = ""
    @State private var newURL: String = "https://"

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    Capsule()
                        .fill(.white.opacity(0.666))
#if !os(xrOS)
                        .frame(width: 200, height: 15)
#else
                        .frame(width: 200, height: 12)
#endif
                }
#if !os(macOS)
                .hoverEffect(.automatic)
#endif
                HStack(spacing: 0) {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .minimumScaleFactor(0.01)
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
                                .minimumScaleFactor(0.01)
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
                                    .minimumScaleFactor(0.01)
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
                                .minimumScaleFactor(0.01)
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

                    if windowInfo.windowType == .chat || windowInfo.windowType == .file || windowInfo.windowType == .webView {
                        if windowInfo.windowType == .file && keyboardHeight != 0 {
                            Button {
#if !os(macOS)
                                hideKeyboard()
#endif
                            } label: {
                                Label( "Done", systemImage: "checkmark")
                                    .font(.body)
                                    .labelStyle(DemoStyle())
                                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                            }
                            .padding(.trailing, SettingsViewModel.shared.cornerHandleSize + 8)
                        }
                        else {
                            menu()
                                .padding(.trailing, SettingsViewModel.shared.cornerHandleSize + 8)
                                .foregroundColor(SettingsViewModel.shared.buttonColor)
                        }
                    }
                }
            }
        }
        #if !os(xrOS)
        .background(SettingsViewModel.shared.backgroundColor)

        .frame(maxWidth: .infinity, maxHeight: SettingsViewModel.shared.cornerHandleSize)
        #else
        .frame(maxWidth: .infinity, maxHeight: SettingsViewModel.shared.cornerHandleSize + 35)
        #endif
        .modify { view in

                view.alert("Rename convo", isPresented: $presentRenamer, actions: {
                    TextField("New name", text: $newName)

                    Button("Rename", action: {
                        presentRenamer = false
                        if let convoID = windowInfo.convoId {
                            settingsViewModel.renameConvo(convoID, newName: newName)
                        }
                        else {
                            logD("no rn")
                        }

                        newName = ""

                    })
                    Button("Cancel", role: .cancel, action: {
                        presentRenamer = false
                        newName = ""
                    })
                }, message: {
                        Text("Please enter new name for convo")

                })
        }

        .modify { view in


                view.alert("Delete convo?", isPresented: $presentDeleter, actions: {
                    Button("Delete",role:.destructive,  action: {

                        presentDeleter = false
                        if let convoID = windowInfo.convoId {
                            settingsViewModel.deleteConversation(convoID)

                        }
                        else {
                            logD("no rn")
                        }


                    })
                    Button("Cancel", role: .cancel, action: {
                        presentDeleter = false
                    })
                }, message: {
                        Text("Would you like to delete the convo?")
                })
            }

        .modify { view in


                view.alert("Change URL?", isPresented: $presentURLChanger, actions: {

                    TextField("New URL", text: $newURL)
                        .autocorrectionDisabled()

                    Button("Go",role:.destructive,  action: {

                        presentURLChanger = false
//                        if let convoID = windowInfo.convoId {
//                            settingsViewModel.deleteConversation(convoID)
//
//                        }
//                        else {
//                            logD("no rn")
//                        }


                    })
                    Button("Cancel", role: .cancel, action: {
                        presentURLChanger = false
                    })
                }, message: {
                        Text("Would you like to change the URL?")
                })
            }
    }

    func menu() -> some View {
        Menu {
            if windowInfo.windowType == .webView {
                Button {


                        presentURLChanger = true
                } label: {
                    Label("Change URL", systemImage: "rectangle.and.pencil.and.ellipsis")
                        .font(.body)
                        .labelStyle(DemoStyle())
                        .foregroundColor(SettingsViewModel.shared.buttonColor)
                }
            }
            else {
                //            Button {
                //                isEditing.toggle()
                //
                //            } label: {
                //                Label(isEditing ? "Done" : windowInfo.windowType == .chat ? "Select" : "Edit", systemImage: "pencil")
                //                    .font(.body)
                //                    .labelStyle(DemoStyle())
                //                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                //            }
                
                let convoText = settingsViewModel.convoText(settingsViewModel.conversations, window: windowInfo)
#if !os(tvOS)
                ShareLink(item: "Check out LogicSage: AI Code & Chat on the AppStore for free now: \(appLink.absoluteString)\nHere is the chat I had with my GPT.\n\(convoText)", message: Text("LogicSage convo"))
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
#endif
                if windowInfo.convoId == Conversation.ID(-1) {
                    
                }
                else {
                    Button {
                        // either renaming file or chat
                        if windowInfo.windowType == .file {
                            
                        }
                        else if windowInfo.windowType == .chat {
                            presentRenamer = true
                        }
                    } label: {
                        Label("Rename", systemImage: "rectangle.and.pencil.and.ellipsis")
                            .font(.body)
                            .labelStyle(DemoStyle())
                            .foregroundColor(SettingsViewModel.shared.buttonColor)
                    }
                    
                    Button {
                        // either renaming file or chat
                        if windowInfo.windowType == .file {
                            
                        }
                        else if windowInfo.windowType == .chat {
                            presentDeleter = true
                        }
                    } label: {
                        Label("Delete", systemImage: "trash.circle.fill")
                            .font(.body)
                            .labelStyle(DemoStyle())
                            .foregroundColor(SettingsViewModel.shared.buttonColor)
                    }
                }
            }

        } label: {
            ZStack {
                Label("", systemImage: "ellipsis")
                    .font(.title3)
                    .minimumScaleFactor(0.5)
                    .labelStyle(DemoStyle())
                    .background(Color.clear)

            }
            .padding(4)
        }
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
            return "LogicSage"
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
