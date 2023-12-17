//
//  ChatBottomMenu.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/29/23.
//

import SwiftUI



struct ChatBottomMenu: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var chatText: String

    @ObservedObject var windowManager: WindowManager
    @Binding var windowInfo: WindowInfo
    @Binding var editingSystemPrompt: Bool
    @Binding var choseBuiltInSystemPrompt: String
    @Binding var choseBuiltInModel: String


    @State private var isModalPresented = false
    @State private var isSystemPromptSelectionPresented = false
    @State private var isTemperaturePromptShown = false
    @State var newTemp: String = "0.7"

    @Binding var conversation: Conversation

    var body: some View {
        Menu {
            if windowInfo.convoId == Conversation.ID(-1) {
                serverChatOptions()
            }
            // Normal chat // Allows changing system message / changing AI model.
            else {
                Text("Tokens: \(conversation.tokens ?? 0)")
                Button(action: {
                    logD("selected Change AI model")
                    isModalPresented = true
                }) {
                    Text( "Change AI model")
                        .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                        .lineLimit(1)
                        .foregroundColor(Color.white)
                        .background(settingsViewModel.buttonColor)
                }

                Button(action: {
                    logD("selected Change Chat temperature")
                    isTemperaturePromptShown = true
                }) {
                    let disp = (conversation.temperature ?? 0.7).formatted(.number.precision(.fractionLength(2)))

                    Text( "Change chat temperature: Current: \(disp)")
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
                        "Choose from built-in system prompt 🌱:")
                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                    .lineLimit(1)
                    .foregroundColor(Color.white)
                    .background(settingsViewModel.buttonColor)
                }


            }
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(SettingsViewModel.shared.buttonColor, lineWidth: 1)

                Label("...", systemImage: "ellipsis")
                    .font(.title3)
                    .minimumScaleFactor(0.5)
                    .labelStyle(DemoStyle())
                    .background(Color.clear)
#if os(visionOS)

                    .offset(x:6)
#else
                    .offset(x:4)

#endif
                    .tint(settingsViewModel.appTextColor)


            }
            .padding(4)

        }
        .frame(width: 30)

        .sheet(isPresented: $isModalPresented) {
            ModalView(items: aiModelOptions, choseBuiltInModel: $choseBuiltInModel)
        }
        .sheet(isPresented: $isSystemPromptSelectionPresented) {
            ModalViewSystemPrompt(choseBuiltInSystemPrompt: $choseBuiltInSystemPrompt)
        }
        .alert("Set Temp", isPresented: $isTemperaturePromptShown, actions: {
            TextField("New Temp", text: $newTemp)

            Button("Set", action: {
                // convert double string to double
                let double = Double(newTemp)
                conversation.temperature = double ?? 0.7
                SettingsViewModel.shared.setTemp(conversation.id, newTemp: double ?? 0.7)
            })
            Button("Cancel", role: .cancel, action: {
                isTemperaturePromptShown = false
            })
        }, message: {
            Text("Please enter temperature for chat")
        })
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

            //            // Simulator BUTTON
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
            //
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
    @Binding var choseBuiltInModel: String

    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
        

                Button(item == "gpt-4-1106-ls-web-browsing" ? "gpt-4-1106-ls-web-browsing*":item) {
                    presentationMode.wrappedValue.dismiss()
                    SettingsViewModel.shared.openAIModel = item
                    choseBuiltInModel = item
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
    @ObservedObject var viewModel = SystemPromptViewModel(items:systemPromptOptions)
    @Environment(\.presentationMode) var presentationMode


    @Binding var choseBuiltInSystemPrompt: String

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items.indices, id: \.self) { index in
                    let item = viewModel.items[index]
                    Button("\(item.0) act: \(item.1)") {
                        presentationMode.wrappedValue.dismiss()
                        choseBuiltInSystemPrompt = item.1
                    }
                    .padding()
                }
                .onDelete(perform: deleteItem)
//                .onMove(perform: moveItem)
            }
            .navigationBarItems(trailing: Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationTitle("Choose system msg:")
        }
    }
    func deleteItem(at offsets: IndexSet) {
        viewModel.items.remove(atOffsets: offsets)
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        viewModel.items.move(fromOffsets: source, toOffset: destination)
    }
}


class SystemPromptViewModel: ObservableObject {
    @Published var items: [(String, String)]

    init(items: [(String, String)]) {
        self.items = items
    }
}
