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
                        // debate BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "debate "
                        }) {
                            Text( "debate")
                                .font(.caption)
                                .lineLimit(nil)
                                .foregroundColor(Color.white)
                                //.padding(geometry.size.width * 0.01)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                       // .padding(.bottom)

                        // STOP BUTTON
                        Button(action: {

                            // cmd send st
                            settingsViewModel.multiLineText = "g end"
                            DispatchQueue.main.async {

                                // Execute your action here
                                screamer.sendCommand(command: settingsViewModel.multiLineText)

                                self.settingsViewModel.isInputViewShown = false

                                settingsViewModel.multiLineText = ""
//    #if !os(macOS)
//
//                                consoleManager.isVisible = true
//    #endif
                            }

                        }) {
                            Text("g end")
                                .font(.caption)
                                .lineLimit(nil)
                                .foregroundColor(Color.white)
                                //.padding(geometry.size.width * 0.01)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                        //.padding(.bottom)
                        
                        // i BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "i "
                        }) {
                            Text( "i")
                                .font(.caption)
                                .lineLimit(nil)
                                .foregroundColor(Color.white)
                                //.padding(geometry.size.width * 0.01)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                        //.padding(.bottom)
                        // g BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "g "
                        }) {
                            Text( "g")
                                .font(.caption)
                                .lineLimit(nil)
                                .foregroundColor(Color.white)
//                                .padding(geometry.size.width * 0.01)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)

                        }

                    }

                    if !settingsViewModel.multiLineText.isEmpty && settingsViewModel.isInputViewShown {
                        // X BUTTON
                        Button(action: {
                            settingsViewModel.multiLineText = ""
                        }) {
                            Text( "X")
                                .font(.caption)
                                .lineLimit(nil)
                                .foregroundColor(Color.white)
//                                .padding(geometry.size.width * 0.01)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
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
//#if !os(macOS)
//
//                            consoleManager.isVisible = true
//#endif
                        }

                    }) {
                        Text("🛑")
                            .font(.caption)
                            .lineLimit(nil)
                            .foregroundColor(Color.white)
                           // .padding(geometry.size.width * 0.01)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
                    }
                    //.padding(.bottom)

                    // EXEC BUTTON
                    Button(action: {
                        // Execute your action here
                        screamer.sendCommand(command: settingsViewModel.multiLineText)

                        self.settingsViewModel.isInputViewShown = false
//#if !os(macOS)
//
//                        consoleManager.isVisible = true
//                        #endif

                    }) {
                        Text("EXEC")
                            .font(.caption)
                            .lineLimit(nil)
                            .foregroundColor(Color.white)
                            //.padding(geometry.size.width * 0.01)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
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
                        Text(self.settingsViewModel.isInputViewShown ? "DONE" : "COMMAND")
                            .font(.caption)
                            .lineLimit(nil)
                            .foregroundColor(Color.white)
                            //.padding(geometry.size.width * 0.01)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
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
