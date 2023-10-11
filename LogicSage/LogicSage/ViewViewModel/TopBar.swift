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

    @State private var newName: String = ""
    @State private var newURL: String = "https://"

    @State private var showDocumentPicker = false
    @State private var pickedDocumentURL: URL?

    @ObservedObject var sageMultiViewModel: SageMultiViewModel

    var body: some View {
        ZStack {
            ZStack {
                Capsule()
                    .fill(.white.opacity(0.4))
                    .frame(width: 180, height: 4.5, alignment: .topLeading)
                Capsule()
                    .fill(.white.opacity(0.0))
                    .frame(width: 200, height: 9, alignment: .topLeading)
            }
#if !os(macOS)
            .hoverEffect(.automatic)
#endif
#if os(xrOS)
            .offset(y: -settingsViewModel.cornerHandleSize / 1.566666)
#else
            .offset(y: -14)
#endif
            VStack {

                HStack(spacing: 0) {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .minimumScaleFactor(0.01)
#if !os(macOS)
                            .hoverEffect(.lift)
#endif
                    }
                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .padding(.leading, SettingsViewModel.shared.cornerHandleSize + 8)


                    Text(getName())
                        .font(.body)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                        .foregroundColor(SettingsViewModel.shared.buttonColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.leading, 15)

                    Spacer()

                    if windowInfo.windowType == .repoTreeView {
                        Button(action: {
                            showDocumentPicker = true
                        }, label: {
                            Image(systemName: "plus")
                        })
                        .padding(.trailing, SettingsViewModel.shared.cornerHandleSize + 8)

                    }

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
#if os(xrOS)
                                .padding(.trailing,SettingsViewModel.shared.cornerHandleSize + 8 + 20)
#else
                                .padding(.trailing, SettingsViewModel.shared.cornerHandleSize + 8)
#endif

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
        .sheet(isPresented: $showDocumentPicker) {
            ProjectDocumentPicker(pickedDocumentURL: $pickedDocumentURL)
        }

    }

    func menu() -> some View {
        Menu {

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

                if windowInfo.windowType == .file {

                    Button {
                      // DO SAVE OF FILE TO DISK :D
                        print("do save to disk")
                        sageMultiViewModel.saveFileToDisk()
                    } label: {
                        Label("Save file", systemImage: "opticaldiscdrive")
                            .font(.body)
                            .labelStyle(DemoStyle())
                            .foregroundColor(SettingsViewModel.shared.buttonColor)
                    }
                }
            }

        } label: {
            ZStack {

                Circle()
                    .strokeBorder(SettingsViewModel.shared.buttonColor, lineWidth: 1)

                Label("...", systemImage: "ellipsis")
                    .font(.title3)
                    .minimumScaleFactor(0.5)
#if os(xrOS)

                    .offset(x:6)
#else
                    .offset(x:3)

#endif

                    .labelStyle(DemoStyle())
                    .background(Color.clear)

            }

            .padding(4)
        }
#if !os(macOS)
        .hoverEffect(.automatic)
#endif
        .frame(width: 30, height: 30)

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
