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
//                        .font(.caption)
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

                            consoleManager.print("toggling google mode")
                            print("toggling google mode")
                            // cmd send st


                        }) {
                            ZStack {
                                Text("🌐")
                                Text("❌")
                                    .opacity(0.6)

                            }
                                .font(.caption)
                                .padding(geometry.size.width * 0.01)
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                        
                        // LINK BUTTON
                        Button(action: {

                            consoleManager.print("toggling linking mode")
                            print("toggling linking mode")


                        }) {
                            ZStack {
                                Text("🔗")
                                Text("❌")
                                    .opacity(0.6)
                            }
                                .font(.caption)
                                .padding(geometry.size.width * 0.01)
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(10)
                        }


                        
                        // debate BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "debate "
                        }) {
                            Text( "debate")
                                .font(.caption)
                                .padding(geometry.size.width * 0.01)
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(10)
                        }

                        // STOP BUTTON
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
                                .font(.caption)
                                .padding(geometry.size.width * 0.01)

                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                //.padding(geometry.size.width * 0.01)
                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(10)
                        }

                        // i BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "i "
                        }) {
                            Text( "i")
                                .font(.caption)
                                .padding(geometry.size.width * 0.01)

                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                //.padding(geometry.size.width * 0.01)
                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(10)
                        }
                        // g BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "g "
                        }) {
                            Text( "g")
                                .font(.caption)
                                .padding(geometry.size.width * 0.01)

                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(10)

                        }

                    }

                    if !settingsViewModel.multiLineText.isEmpty && settingsViewModel.isInputViewShown {
                        // X BUTTON
                        Button(action: {
                            settingsViewModel.multiLineText = ""
                        }) {
                            Text( "🗑️")
                                .font(.caption)
                                .padding(geometry.size.width * 0.01)

                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(10)
                        }
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
                            .font(.caption)
                            .padding(geometry.size.width * 0.01)
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
//                            .cornerRadius(10)
                    }

                    // EXEC BUTTON
                    Button(action: {
                        if settingsViewModel.multiLineText.isEmpty {
                            consoleManager.print("nothing to exec.")
                            return
                        }
                        // Execute your action here
                        screamer.sendCommand(command: settingsViewModel.multiLineText)

                        self.settingsViewModel.isInputViewShown = false

                        consoleManager.isVisible = true
//#if !os(macOS)
//
//                        consoleManager.isVisible = true
//                        #endif

                    }) {
                        Text("✅🔄")
                            .font(.caption)
                            .padding(geometry.size.width * 0.01)

                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            //.padding(geometry.size.width * 0.01)
                            .background(settingsViewModel.buttonColor)
//                            .cornerRadius(10)
                    }
                    //.padding(.bottom)

                    // TERM/COMMAND BUTTON
                    Button(action: {
                        if settingsViewModel.commandMode == .commandText {
                            // Execute your action here
                            screamer.sendCommand(command: settingsViewModel.multiLineText)

                            self.settingsViewModel.isInputViewShown = false
                            settingsViewModel.commandMode = .commandBar
#if !os(macOS)
//                            consoleManager.isVisible = true
#endif
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
//                                Text("❌")
                            }
                            .font(.caption)
                            .padding(geometry.size.width * 0.01)
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            //.padding(geometry.size.width * 0.01)
                            .background(settingsViewModel.buttonColor)
//                            .cornerRadius(10)
                        }
                        else {
                           Text( "🔹💬")
                                .font(.caption)
                                .padding(geometry.size.width * 0.01)
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                //.padding(geometry.size.width * 0.01)
                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(10)
                        }

                    }
                    ///.padding(.bottom)

                }
                //.padding(.bottom)


                if settingsViewModel.isInputViewShown {
                    // MAIN INPUT TEXTFIELD
                    TextEditor(text: $settingsViewModel.multiLineText)
                        .frame(height: 200)
                        .font(.caption)
                        .lineLimit(nil)
                        .border(settingsViewModel.buttonColor, width: 2)
                        .autocorrectionDisabled(true)
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
