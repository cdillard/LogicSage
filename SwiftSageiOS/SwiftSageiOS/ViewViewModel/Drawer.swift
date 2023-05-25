//
//  Drawer.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI

#if !os(macOS)
var drawerWidth: CGFloat = UIScreen.main.bounds.width / 2.5
var drawerWidthLandscape: CGFloat = UIScreen.main.bounds.width / 6
#endif

struct DrawerContent: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var isDrawerOpen: Bool
    @Binding var conversations: [Conversation]
    @Binding var isPortrait: Bool

    @State var isDeleting: Bool = false
    @State var isDeletingIndex: Int = -1

    var body: some View {
        HStack(alignment: .top, spacing: 2) {
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    Text("➕ New Chat")
                        .padding(2)
                        .lineLimit(1)
//                        .border(settingsViewModel.appTextColor, width: 2)
                        .font(.body)

                        .fontWeight(.heavy)
                        .foregroundColor(settingsViewModel.appTextColor)
                        .padding(3)
                        .onTapGesture {
                            isDrawerOpen.toggle()
                            settingsViewModel.createAndOpenNewConvo()
                        }
                    ForEach(Array(conversations.enumerated()), id: \.offset) { index, convo in
                        HStack {
                            Text("💬 Chat: \(String(convo.id.prefix(4)))")
                                .lineLimit(1)
                                .font(.body)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .padding(2)
                                .onTapGesture {
                                    settingsViewModel.openConversation(convo.id)
                                }
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

                                        settingsViewModel.deleteConversation(convo.id)
                                    }
                                    .animation(.easeIn(duration: 0.25), value: isDeleting)

                            }
                            else {
                                Text("🗑️")
                                    .lineLimit(1)
                                    .font(.body)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .padding(2)
                                    .onTapGesture {
                                        // settingsViewModel.selectConversation(convo.id)
                                        isDeleting = true
                                        isDeletingIndex = index
                                    }
                                    .animation(.easeIn(duration: 0.25), value: isDeleting)
                            }
                        }
                    }
                    Text("💬 Server Chat")
                        .lineLimit(1)
                        .font(.body)
                        .foregroundColor(settingsViewModel.appTextColor)
                        .padding(2)
                        .onTapGesture {
                            settingsViewModel.createAndOpenServerChat()
                        }

                    Spacer()
                }
                .minimumScaleFactor(0.85)
                .foregroundColor(settingsViewModel.appTextColor)
                .padding(.leading,2)
                .padding(.top,2)
#if !os(macOS)
                .frame(minWidth: isPortrait ? drawerWidth : drawerWidthLandscape, maxWidth: isPortrait ? drawerWidth : drawerWidthLandscape, minHeight: 0, maxHeight: .infinity)
#endif
                Spacer()
            }
        }
        .zIndex(9)
        .padding(.leading,3)
        .padding(.top,3)

    }
}
