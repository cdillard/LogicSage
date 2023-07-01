//
//  ChatBottomMenu.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 6/29/23.
//

import SwiftUI

struct ChatBotomMenu: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var chatText: String
    @ObservedObject var windowManager: WindowManager

    var body: some View {
        Menu {
            // Random Wallpaper BUTTON
            Button(action: {
                logD("CHOOSE RANDOM WALLPAPER")
                // cmd send st
                DispatchQueue.main.async {
                    // Execute your action here
                    screamer.sendCommand(command: "wallpaper random")
                }
            }) {
                Text("🖼️ random wallpaper")
                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                    .lineLimit(1)
                    .foregroundColor(Color.white)
                    .background(settingsViewModel.buttonColor)
            }

            // Simulator BUTTON
            Button(action: {
                logD("RUN SIMULATOR")

                settingsViewModel.latestWindowManager = windowManager

                DispatchQueue.main.async {

                    // Execute your action here
                    screamer.sendCommand(command: "simulator")
                }
            }) {
                ZStack {
                    Text("📲 simulator")
                }
                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                .lineLimit(1)
                .foregroundColor(Color.white)
                .background(settingsViewModel.buttonColor)
            }

            // Debate BUTTON
            Button(action: {
                chatText = "debate "
            }) {
                Text( "⚖️ debate")
                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                    .lineLimit(1)
                    .foregroundColor(Color.white)
                    .background(settingsViewModel.buttonColor)
            }

            // i BUTTON
            Button(action: {
                chatText = "i "
            }) {
                Text( "💡 i")
                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                    .lineLimit(1)
                    .foregroundColor(Color.white)
                    .background(settingsViewModel.buttonColor)
            }

            // Trash BUTTON
            Button(action: {
                chatText = ""
                screamer.sendCommand(command: "g end")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.333) {
                    settingsViewModel.consoleManagerText = ""
                }

            }) {
                Text("🗑️ Reset")
                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                    .lineLimit(1)
                    .foregroundColor(Color.white)
                    .background(settingsViewModel.buttonColor)
            }
        } label: {
            ZStack {
                Label("", systemImage: "ellipsis")
                    .font(.title3)
                    .minimumScaleFactor(0.5)
                    .labelStyle(DemoStyle())
            }
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
}
