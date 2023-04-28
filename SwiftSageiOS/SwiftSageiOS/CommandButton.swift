//
//  CommandButton.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/24/23.
//

import Foundation
import SwiftUI

struct CommandButtonView: View {
    @StateObject var settingsViewModel: SettingsViewModel
    @FocusState var isTextFieldFocused: Bool

    func doExec() {
        self.settingsViewModel.isInputViewShown.toggle()
#if !os(macOS)

        consoleManager.isVisible = !settingsViewModel.isInputViewShown
        consoleManager.fontSize = settingsViewModel.textSize
#endif
    }

    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                Spacer()

                HStack {
                    Spacer()
#if !os(macOS)

                    if !settingsViewModel.isInputViewShown {
                        // PLugItIn BUTTON
                        Button("🔌") {
                            print("🔌 Force reconnecting websocket...")
                            consoleManager.print("🔌 Force reconnect...")
                            consoleManager.print("You can always force quit / restart you know...")

                            //screamer.connect()
                        }
                        .font(.body)
//                        .foregroundColor(Color.white)
//                        .padding(.bottom)
                        .background(settingsViewModel.buttonColor)
//                        .cornerRadius(10)
                    }
#endif

                    if settingsViewModel.multiLineText.isEmpty && settingsViewModel.isInputViewShown {
                        // debate BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "debate "
                        }) {
                            Text( "debate")
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .padding()
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
//                        // st BUTTON
//                        Button(action: {
//                            isTextFieldFocused = true
//                            multiLineText += "st"
//                        }) {
//                            Text( "st")
//                                .font(.subheadline)
//                                .foregroundColor(Color.white)
//                                .padding()
//                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(10)
//                        }
//                        .padding(.bottom)
                        // i BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "i "
                        }) {
                            Text( "i")
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .padding()
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        // g BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            settingsViewModel.multiLineText += "g "
                        }) {
                            Text( "g")
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .padding()
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)

                        }
                        .padding(.bottom)

                    }

                    if !settingsViewModel.multiLineText.isEmpty && settingsViewModel.isInputViewShown {
                        // X BUTTON
                        Button(action: {
                            settingsViewModel.multiLineText = ""
                        }) {
                            Text( "X")
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .padding()
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
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
#if !os(macOS)

                            consoleManager.isVisible = true
#endif
                        }

                    }) {
                        Text("🛑")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding()
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)

                    // EXEC BUTTON
                    Button(action: {
                        // Execute your action here
                        screamer.sendCommand(command: settingsViewModel.multiLineText)

                        self.settingsViewModel.isInputViewShown = false
#if !os(macOS)

                        consoleManager.isVisible = true
                        #endif

                    }) {
                        Text("EXEC")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding()
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)

                    // TERM/COMMAND BUTTON
                    Button(action: {
                        if settingsViewModel.isInputViewShown {
                            // Execute your action here
                            screamer.sendCommand(command: settingsViewModel.multiLineText)

                            self.settingsViewModel.isInputViewShown = false
#if !os(macOS)

                            consoleManager.isVisible = true
                            #endif
                        }
                        else {
                            doExec()
                        }
                    }) {
                        Text(self.settingsViewModel.isInputViewShown ? "DONE" : "COMMAND")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding()
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)

                }
                .padding(.bottom)


                if settingsViewModel.isInputViewShown {
                    // MAIN INPUT TEXTFIELD
                    TextEditor(text: $settingsViewModel.multiLineText)
                        .frame(height: 200)
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
