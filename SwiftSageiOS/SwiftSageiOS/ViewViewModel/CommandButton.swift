//
//  CommandButton.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/24/23.
//

import Foundation
import SwiftUI

enum EntryMode {
    case commandText
    case commandBar
}

struct CommandButtonView: View {
    @StateObject var settingsViewModel: SettingsViewModel
    @FocusState var isTextFieldFocused: Bool

    func openText() {
        self.settingsViewModel.isInputViewShown.toggle()
#if !os(macOS)

       // consoleManager.isVisible = !settingsViewModel.isInputViewShown
#endif
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                HStack {
                    Spacer()
//#if !os(macOS)
//
//                    if !settingsViewModel.isInputViewShown {
//                        // PLugItIn BUTTON
//                        Button("🔌") {
//                            print("🔌 Force reconnecting websocket...")
//                            consoleManager.print("🔌 Force reconnect...")
//                            consoleManager.print("You can always force quit / restart you know...")
//
//                            screamer.connect()
//                        }
//                        .font(.body)
//                        .lineLimit(nil)
////                        .foregroundColor(Color.white)
////                        .padding(.bottom)
//                        .background(settingsViewModel.buttonColor)
////                        .cornerRadius(10)
//                    }
//#endif

                    if settingsViewModel.multiLineText.isEmpty && settingsViewModel.isInputViewShown {

                        // GOOGLE button
                        Button(action: {

                            logD("toggling google mode")

                        }) {
                            ZStack {
                                Text("🌐")
                                Text("❌")
                                    .opacity(0.6)

                            }
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        
                        Button(action: {
                            logD("toggling linking mode")
                        }) {
                            ZStack {
                                Text("🔗")
                                Text("❌")
                                    .opacity(0.6)
                            }
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }
                        .padding(.bottom)

                        if settingsViewModel.currentMode == .computer {

                            // Debate BUTTON
                            Button(action: {
                                isTextFieldFocused = true
                                settingsViewModel.multiLineText += "debate "
                            }) {
                                Text( "⚖️")
                                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                    .lineLimit(1)
                                    .foregroundColor(Color.white)
                                    .background(settingsViewModel.buttonColor)
                            }
                            .padding(.bottom)
                        }


                        if settingsViewModel.currentMode == .computer {
                            // i BUTTON
                            Button(action: {
                                isTextFieldFocused = true
                                settingsViewModel.multiLineText += "i "
                            }) {
                                Text( "💡")
                                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                    .lineLimit(1)
                                    .foregroundColor(Color.white)
                                    .background(settingsViewModel.buttonColor)
                            }
                            .padding(.bottom)
                        }

                        // g BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "g "
                        }) {
                            Text( "g")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)

                        }
                        .padding(.bottom)

                    }
                    if !settingsViewModel.multiLineText.isEmpty && settingsViewModel.isInputViewShown {

                        // STOP // EXIT CONVERSATIONAL MODE BUTTON
                        Button(action: {

                            // cmd send st
                            settingsViewModel.multiLineText = "g end"
                            DispatchQueue.main.async {

                                // Execute your action here
                                screamer.sendCommand(command: settingsViewModel.multiLineText)

                                self.settingsViewModel.isInputViewShown = false

                                settingsViewModel.multiLineText = ""
                            }

                        }) {
                            ZStack {
                                Text("🧠")
                                Text("❌")
                                    .opacity(0.74)
                            }
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))

                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
                        }
                        .padding(.bottom)
                    }
                    if !settingsViewModel.multiLineText.isEmpty && settingsViewModel.isInputViewShown {
                        // X BUTTON
                        Button(action: {
                            settingsViewModel.multiLineText = ""
                        }) {
                            Text( "🗑️")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }
                        .padding(.bottom)
                    }

                    // STOP BUTTON
                    Button(action: {

                        // cmd send st
                        settingsViewModel.multiLineText = "st"
                        DispatchQueue.main.async {

                            // Execute your action here
                            screamer.sendCommand(command: settingsViewModel.multiLineText)

                            self.settingsViewModel.isInputViewShown = false

                            settingsViewModel.multiLineText = ""
                        }

                    }) {
                        Text("🛑")
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
                            .padding(.bottom)
                    }
                    if settingsViewModel.multiLineText.count > 0 {
                        // EXEC BUTTON
                        Button(action: {
                            if settingsViewModel.multiLineText.isEmpty {
                                logD("nothing to exec.")
                                
                                return
                            }
                            // Execute your action here
                            screamer.sendCommand(command: settingsViewModel.multiLineText)
                            
                            self.settingsViewModel.isInputViewShown = false
#if !os(macOS)
                            consoleManager.isVisible = true
#endif
                        }) {
                            Text("✅")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                                .padding(.bottom)
                        }
                    }

                    // TERM/COMMAND BUTTON
                    Button(action: {
                        if settingsViewModel.commandMode == .commandText {
                            // Execute your action here
                            screamer.sendCommand(command: settingsViewModel.multiLineText)

                            self.settingsViewModel.isInputViewShown = false
                            settingsViewModel.commandMode = .commandBar
                        }
                        else {
#if !os(macOS)
                            consoleManager.isVisible = false
#endif
                            openText()
                        }
                    }) {
                        if self.settingsViewModel.isInputViewShown {
                            ZStack {
                                Text("🔽")
                            }
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
                        }
                        else {
                           Text( "💬")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }

                    }
                    .padding(.trailing, 16)
                    .padding(.bottom)
                }
                .edgesIgnoringSafeArea([.top])

                if settingsViewModel.isInputViewShown {
                    // MAIN INPUT TEXTFIELD
                    TextEditor(text: $settingsViewModel.multiLineText)
                        .frame(height: 200)
                        .padding(.bottom, 30)
                        .lineLimit(nil)
                        .border(settingsViewModel.buttonColor, width: 2)
                        .autocorrectionDisabled(!settingsViewModel.autoCorrect)
#if !os(macOS)
                        .autocapitalization(.none)
#endif
                        .focused($isTextFieldFocused)
                        .scrollDismissesKeyboard(.interactively)
                }
            }
        }
    }
}
struct CustomFontSize: ViewModifier {
    @Binding var size: Double

    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(size)))
    }
}
