//
//  ChatBottomMenu.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/29/23.
//

import SwiftUI

let aiModelOptions: [String] = [
    "gpt-4",
    "gpt-4-0314",
    "gpt-4-0613",
    "gpt-4-32k",
    "gpt-4-32k-0314",
    "gpt-4-32k-0613",
    "gpt-3.5-turbo",
    "gpt-3.5-turbo-0301",
    "gpt-3.5-turbo-0613",
    "gpt-3.5-turbo-16k",
    "gpt-3.5-turbo-16k-0613",
]

struct ChatBotomMenu: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var chatText: String
    @ObservedObject var windowManager: WindowManager
    @Binding var windowInfo: WindowInfo
    @State var showModelMenu: Bool = false

    var body: some View {
        ZStack {
            if !showModelMenu {
                Menu {
                    if windowInfo.convoId == Conversation.ID(-1) {
                        serverChatOptions()
                    }
                    // Normal chat // Allows changing system message / changing AI model.
                    else {
                        Button(action: {
                            logD("selected Change AI model")
                            showModelMenu = true
                        }) {
                            Text( "Change AI model")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }

                        Button(action: {
                            logD("selected Change system prompt")
                        }) {
                            Text( "Change system prompt")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }

                        Button(action: {
                            logD("selected Enable/Disable/Change Voice")
                        }) {
                            Text("Enable/Disable/Change Voice")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }

                    }
                } label: {
                    ZStack {
                        if #available(iOS 16.0, *) {
                            Label("", systemImage: "ellipsis")
                                .font(.title3)
                                .minimumScaleFactor(0.5)
                                .labelStyle(DemoStyle())
                                .background(Color.clear)
                                .tint(settingsViewModel.appTextColor)

                        } else {
                            Label("", systemImage: "ellipsis")
                                .font(.title3)
                                .minimumScaleFactor(0.5)
                                .labelStyle(DemoStyle())
                                .background(Color.clear)
                        }

                    }
                    .padding(4)

                }
            }
            if showModelMenu {
                Menu {
                    modelOptions()
                }
            label: {
                ZStack {
                    if #available(iOS 16.0, *) {

                        Label("", systemImage: "ellipsis")
                            .font(.title3)
                            .minimumScaleFactor(0.5)
                            .labelStyle(DemoStyle())
                            .background(Color.clear)
                            .tint(settingsViewModel.appTextColor)

                    } else {
                        Label("", systemImage: "ellipsis")
                            .font(.title3)
                            .minimumScaleFactor(0.5)
                            .labelStyle(DemoStyle())
                            .background(Color.clear)
                    }

                }
                .padding(4)

            }
            }
        }
    }

    func serverChatOptions() -> some View {
        Group {
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
        }
    }

    func modelOptions() -> some View {
        Group {
            ForEach(aiModelOptions, id: \.self) { line in
                Button(action: {
                    logD("CHOOSE model: \(line)")
                    showModelMenu = false
                    settingsViewModel.openAIModel = line
                }) {
                    Text(line)
                        .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                        .lineLimit(1)
                        .foregroundColor(Color.white)
                        .background(settingsViewModel.buttonColor)
                }
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
