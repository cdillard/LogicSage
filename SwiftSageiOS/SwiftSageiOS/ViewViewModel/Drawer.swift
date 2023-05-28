//
//  Drawer.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI

#if !os(macOS)
var drawerWidth: CGFloat = UIScreen.main.bounds.width / 2
var drawerWidthLandscape: CGFloat = UIScreen.main.bounds.width / (UIDevice.current.userInterfaceIdiom == .pad ? 5.25 : 3.0)
#endif

struct DrawerContent: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var isDrawerOpen: Bool
    @Binding var conversations: [Conversation]
    @Binding var isPortrait: Bool
    @State var presentRenamer: Bool = false
    @State private var newName: String = ""
    @State var renamingConvo: Conversation? = nil

    @State var isDeleting: Bool = false
    @State var isDeletingIndex: Int = -1
    func rowString(convo: Conversation) -> String {
        convo.name ?? String(convo.id.prefix(4))
    }
    var body: some View {
        HStack(alignment: .top, spacing: 1) {
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    Text("➕ New 💬")
                        .padding(2)
                        .lineLimit(1)
                        .font(.body)
                        .fontWeight(.heavy)
                        .foregroundColor(settingsViewModel.buttonColor)
                        .padding(3)
                        .onTapGesture {
                            settingsViewModel.createAndOpenNewConvo()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                                playSelect()

                                isDrawerOpen.toggle()
                            }

                        }
                        .background(settingsViewModel.appTextColor)
                    ForEach(Array(conversations.reversed().enumerated()), id: \.offset) { index, convo in
                        Divider()
                            .foregroundColor(settingsViewModel.appTextColor.opacity(0.5))

                        HStack {
                            Text("💬 \(rowString(convo: convo))")
                                .lineLimit(2)
                                .font(.body)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .onTapGesture {
                                    isDrawerOpen.toggle()


                                    playSelect()

                                    settingsViewModel.openConversation(convo.id)
                                }

                            Spacer()

                            if isDeleting && isDeletingIndex > -1 && isDeletingIndex == index {
                                Text("❌")
                                    .lineLimit(1)
                                    .font(.body)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .padding(2)
                                    .onTapGesture {
                                        isDeleting = false
                                        isDeletingIndex = -1
                                    }
                                    .animation(.easeIn(duration: 0.25), value: isDeleting)

                                Text("✔️")
                                    .lineLimit(1)
                                    .font(.body)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .padding(2)
                                    .onTapGesture {
                                        isDeleting = false
                                        isDeletingIndex = -1
                                        isDrawerOpen.toggle()
                                        settingsViewModel.deleteConversation(convo.id)
                                    }
                                    .animation(.easeIn(duration: 0.25), value: isDeleting)
                            }
                            else {
                                HStack {
                                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                        .lineLimit(1)
                                        .font(.body)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .onTapGesture {

                                            presentRenamer = true
                                            renamingConvo = convo
                                        }
                                        .animation(.easeIn(duration: 0.25), value: isDeleting)

                                    Text("🗑️")
                                        .lineLimit(1)
                                        .font(.body)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .padding(.trailing, 2)
                                        .onTapGesture {
                                            isDeleting = true
                                            isDeletingIndex = index
                                        }
                                        .animation(.easeIn(duration: 0.25), value: isDeleting)
                                }
                            }
                        }
                        .padding(2)
                    }
                    Text("💬 Server")
                        .lineLimit(1)
                        .font(.body)
                        .foregroundColor(settingsViewModel.appTextColor)
                        .padding(2)
                        .onTapGesture {
                            settingsViewModel.createAndOpenServerChat()
                        }

                    Spacer()
                }
                .minimumScaleFactor(0.9666)
                .foregroundColor(settingsViewModel.appTextColor)

#if !os(macOS)
                .frame(minWidth: isPortrait ? drawerWidth : drawerWidthLandscape, maxWidth: isPortrait ? drawerWidth : drawerWidthLandscape, minHeight: 0, maxHeight: .infinity)
#endif
                .alert("Rename convo", isPresented: $presentRenamer, actions: {
                    TextField("New name", text: $newName)

                    Button("Rename", action: {
                        presentRenamer = false
                        if let convoID = renamingConvo?.id {
                            settingsViewModel.renameConvo(convoID, newName: newName)
                            renamingConvo = nil

                        }
                        else {
                            logD("no rn")
                        }

                        isDrawerOpen = false

                    })
                    Button("Cancel", role: .cancel, action: {
                        renamingConvo = nil
                        presentRenamer = false
                        isDrawerOpen = false
                    })
                }, message: {
                    if let renamingConvo {
                        Text("Please enter new name for convo \(rowString(convo:renamingConvo))")
                    }
                    else {
                        Text("Please enter new name")
                    }

                })
                Spacer()
            }
        }
        .zIndex(9)
        .padding(.leading,3)
        .padding(.top,3)

    }
}
