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
    @ObservedObject var windowManager: WindowManager

    @Binding var isDrawerOpen: Bool
    @Binding var conversations: [Conversation]
    @Binding var isPortrait: Bool
    @Binding var viewSize: CGRect
    @Binding var showSettings: Bool
    @Binding var showAddView: Bool

    @State var presentRenamer: Bool = false
    @State private var newName: String = ""
    @State var renamingConvo: Conversation? = nil

    @State var isDeleting: Bool = false
    @State var isDeletingIndex: Int = -1
    func rowString(convo: Conversation) -> String {
        convo.name ?? String(convo.id.prefix(4))
    }
    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: 33, height: 100 * settingsViewModel.buttonScale)
            .tint(settingsViewModel.appTextColor)
            .background(settingsViewModel.buttonColor)
    }
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 1) {
                VStack(alignment: .leading, spacing: 1) {
                    ScrollView {
                        HStack(spacing: 0) {
                            resizableButtonImage(systemName:
                                                    "text.and.command.macwindow",
                                                 size: geometry.size)
                            .padding(2)
                            .onTapGesture {
                                withAnimation {
                                    isDrawerOpen = false

                                    // TODO : SHOw / h9de terminal / server chat.


                                    settingsViewModel.latestWindowManager = windowManager

                                    settingsViewModel.createAndOpenServerChat()
                                }

                            }
                            resizableButtonImage(systemName:
                                                    "gearshape",
                                                 size: geometry.size)
                            .padding(2)
                            .onTapGesture {
                                withAnimation {
                                    isDrawerOpen = false
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            showSettings = true
                                        }
                                    }
                                }

                            }

                            resizableButtonImage(systemName:
                                                    "plus.rectangle",
                                                 size: geometry.size)
                            .padding(2)
                            .onTapGesture {
                                withAnimation {
                                    isDrawerOpen = false
                                    if showSettings {
                                        showSettings = false
                                    }

                                    DispatchQueue.main.async {
                                        withAnimation {
                                            
                                            showAddView = true
                                        }
                                    }
                                }

                            }
                            Spacer()
                        }

                        HStack(spacing: 0) {
                            resizableButtonImage(systemName:
                                                    "xmark.circle.fill",
                                                 size: geometry.size)
                            .padding(2)
                            .onTapGesture {

                                withAnimation {
                                    isDrawerOpen = false
                                }

                            }
                            Spacer()
                            Text("➕ New 💬")
                                .padding(2)
                                .lineLimit(1)
                                .font(.body)
                                .fontWeight(.heavy)
                                .foregroundColor(settingsViewModel.buttonColor)
                                .padding(3)
                                .onTapGesture {

                                    withAnimation {
                                        isDrawerOpen = false

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            settingsViewModel.latestWindowManager = windowManager

                                            settingsViewModel.createAndOpenNewConvo()

                                            playSelect()
                                        }
                                    }
                                }
                                .background(settingsViewModel.appTextColor)
                        }
                        ForEach(Array(conversations.reversed().enumerated()), id: \.offset) { index, convo in
                            Divider()
                                .foregroundColor(settingsViewModel.appTextColor.opacity(0.5))

                            HStack(spacing: 0) {
                                Text("💬 \(rowString(convo: convo))")
                                    .lineLimit(4)
                                    .padding(.leading, 2)
                                    .font(.body)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .onTapGesture {
                                        withAnimation {
                                            isDrawerOpen = false

                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                                                settingsViewModel.latestWindowManager = windowManager

                                                playSelect()

                                                settingsViewModel.openConversation(convo.id)
                                            }
                                        }
                                    }

                                Spacer()

                                if isDeleting && isDeletingIndex > -1 && isDeletingIndex == index {
                                    resizableButtonImage(systemName:
                                                            "x.circle.fill",
                                                         size: geometry.size)
                                    .lineLimit(1)

                                    .onTapGesture {
                                        isDeleting = false
                                        isDeletingIndex = -1
                                    }
                                    .animation(.easeIn(duration: 0.25), value: isDeleting)



                                    resizableButtonImage(systemName:
                                                            "checkmark.circle.fill",
                                                         size: geometry.size)
                                    .lineLimit(1)
                                    .onTapGesture {
                                        withAnimation {
                                            isDrawerOpen = false

                                            isDeleting = false

                                            isDeletingIndex = -1
                                            settingsViewModel.latestWindowManager = windowManager

                                            settingsViewModel.deleteConversation(convo.id)

                                        }
                                    }
                                    .animation(.easeIn(duration: 0.25), value: isDeleting)
                                }
                                else {
                                    resizableButtonImage(systemName:
                                                            "rectangle.and.pencil.and.ellipsis",
                                                         size: geometry.size)
                                    .lineLimit(1)
                                    .onTapGesture {

                                        presentRenamer = true
                                        renamingConvo = convo
                                    }
                                    .animation(.easeIn(duration: 0.25), value: isDeleting)

                                    resizableButtonImage(systemName:
                                                            "trash.circle.fill",
                                                         size: geometry.size)
                                    .lineLimit(1)

                                    .onTapGesture {
                                        isDeleting = true
                                        isDeletingIndex = index
                                    }
                                    .animation(.easeIn(duration: 0.25), value: isDeleting)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .minimumScaleFactor(0.9666)
                    .foregroundColor(settingsViewModel.appTextColor)

#if !os(macOS)
                    .frame(minWidth: isPortrait ? drawerWidth : drawerWidthLandscape, maxWidth: isPortrait ? drawerWidth : drawerWidthLandscape, minHeight: 0, maxHeight: .infinity)
#endif
                    .alert("Rename convo", isPresented: $presentRenamer, actions: {
                        TextField("New name", text: $newName)

                        Button("Rename", action: {
                            settingsViewModel.latestWindowManager = windowManager

                            presentRenamer = false
                            if let convoID = renamingConvo?.id {
                                settingsViewModel.renameConvo(convoID, newName: newName)
                                renamingConvo = nil

                            }
                            else {
                                logD("no rn")
                            }

                            renamingConvo = nil
                            newName = ""

                        })
                        Button("Cancel", role: .cancel, action: {
                            renamingConvo = nil
                            presentRenamer = false
                            newName = ""
                        })
                    }, message: {
                        if let renamingConvo {
                            Text("Please enter new name for convo \(rowString(convo:renamingConvo))")
                        }
                        else {
                            Text("Please enter new name")
                        }

                    })
                }
            }
            .zIndex(9)
            //        .padding(.leading,3)
            //        .padding(.top,3)
        }
    }
}
