//
//  ChatBottomMenu.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/29/23.
//

import SwiftUI



struct ChatBotomMenu: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var chatText: String
    @ObservedObject var windowManager: WindowManager
    @Binding var windowInfo: WindowInfo
    @Binding var editingSystemPrompt: Bool
    @Binding var choseBuiltInSystemPrompt: String


    @State private var isModalPresented = false
    @State private var isSystemPromptSelectionPresented = false


    var body: some View {
//        ZStack {
//            if !showModelMenu {
                Menu {
                    if windowInfo.convoId == Conversation.ID(-1) {
                        serverChatOptions()
                    }
                    // Normal chat // Allows changing system message / changing AI model.
                    else {
                        Button(action: {
                            logD("selected Change AI model")
                            isModalPresented = true

                            // display overlay sheet w/ the model group..
                        }) {
                            Text( "Change AI model")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }
                        
                        Button(action: {
                            logD("selected Change system prompt")
                            editingSystemPrompt.toggle()
                        }) {
                            Text( editingSystemPrompt ? "Stop editing system message" :
                                    "Edit system message")
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
                        }
                        Button(action: {
                            logD("selected SELECT system prompt")
                            editingSystemPrompt = false

                            isSystemPromptSelectionPresented = true

                        }) {
                            Text(
                                    "Choose from built-in system 🌱:")
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
                        }
//                        Button(action: {
//                            logD("selected Enable/Disable/Change Voice")
//                        }) {
//                            Text("Enable/Disable/Change Voice")
//                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
//                                .lineLimit(1)
//                                .foregroundColor(Color.white)
//                                .background(settingsViewModel.buttonColor)
//                        }
                        
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
        .sheet(isPresented: $isModalPresented) {
            ModalView(items: aiModelOptions)
        }
        .sheet(isPresented: $isSystemPromptSelectionPresented) {
            ModalViewSystemPrompt(items: systemPromptOptions, choseBuiltInSystemPrompt: $choseBuiltInSystemPrompt)
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

    struct DemoStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .center) {
                configuration.icon
                configuration.title
            }
        }
    }
}

struct ModalView: View {
    @Environment(\.presentationMode) var presentationMode

    let items: [String]

    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
                Button(item) {
                    presentationMode.wrappedValue.dismiss()
                    SettingsViewModel.shared.openAIModel = item
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationTitle("Choose model:")
        }
    }
}
struct ModalViewSystemPrompt: View {
    @Environment(\.presentationMode) var presentationMode

    let items: [String: String]
    @Binding var choseBuiltInSystemPrompt: String

    var body: some View {
        NavigationView {
            List {
                ForEach(items.sorted(by: >), id: \.key) { key, value in
                    Button("\(key) act: \(value)") {
                        presentationMode.wrappedValue.dismiss()
                        choseBuiltInSystemPrompt = value
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationTitle("Choose system msg:")
        }
    }
}
