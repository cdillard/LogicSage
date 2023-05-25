//
//  Drawer.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI
var drawerWidth: CGFloat = 140

struct DrawerContent: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var isDrawerOpen: Bool
    @Binding var conversations: [Conversation]

    var body: some View {
        HStack(alignment: .top, spacing: 2) {
            VStack(alignment: .leading, spacing: 2) {

                Text("➕ New Chat")
                    .padding(3)
                    .lineLimit(1)
                    .border(settingsViewModel.buttonColor, width: 2)
                    .font(.caption)

                    .fontWeight(.bold)
                    .foregroundColor(settingsViewModel.appTextColor)
                    .padding(3)
                    .onTapGesture {
                        isDrawerOpen.toggle()
                        settingsViewModel.createAndOpenNewConvo()
                    }
                ForEach(Array(conversations.enumerated()), id: \.offset) { index, convo in
                    Text("💬 Chat: \(index): \(String(convo.id.prefix(4)))")
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(settingsViewModel.appTextColor)
                        .padding(3)
                        .onTapGesture {
                            settingsViewModel.selectConversation(convo.id)
                            settingsViewModel.openConversation(convo.id)
                        }


                }
                Spacer()
            }
            .minimumScaleFactor(0.01)

            .foregroundColor(settingsViewModel.appTextColor)

            .padding(.leading,3)
            .padding(.top,3)

            .frame(minWidth: drawerWidth, maxWidth: drawerWidth, minHeight: 0, maxHeight: .infinity)

            Spacer()
        }
        .zIndex(9)
        .padding(.leading,3)
        .padding(.top,3)

    }
}
