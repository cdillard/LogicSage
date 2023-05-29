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
    @State var textEditorHeight : CGFloat = 20
    @EnvironmentObject var windowManager: WindowManager

    @Binding var isInputViewShown: Bool
    func openText() {
       isInputViewShown.toggle()
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
                    if isInputViewShown {
                        if  settingsViewModel.currentMode == .computer {
                            // GOOGLE button
                            Button(action: {
                                
                                logD("CHOOSE RANDOM WALLPAPER")
                                // cmd send st
                                settingsViewModel.multiLineText = "wallpaper random"
                                DispatchQueue.main.async {
                                    
                                    // Execute your action here
                                    screamer.sendCommand(command: settingsViewModel.multiLineText)
                                    
                                    isInputViewShown = false
                                    
                                    settingsViewModel.multiLineText = ""
                                }
                            }) {
                                ZStack {
                                    Text("🖼️")
                                    //                                 Text("❌")
                                    //                                     .opacity(0.6)
                                    
                                }
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                            }
                            //                            .padding(.bottom)
                            
                            Button(action: {
                                logD("RUN SIMULATOR")

                                settingsViewModel.latestWindowManager = windowManager

                                settingsViewModel.multiLineText = "simulator"
                                DispatchQueue.main.async {
                                    
                                    // Execute your action here
                                    screamer.sendCommand(command: settingsViewModel.multiLineText)
                                    
                                    isInputViewShown = false
                                    
                                    settingsViewModel.multiLineText = ""
                                }
                            }) {
                                ZStack {
                                    Text("📲")
                                    //                                 Text("❌")
                                    //                                     .opacity(0.6)
                                }
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                            }
                            //                            .padding(.bottom)
                        }
                        //                        // GOOGLE button
                        //                        Button(action: {
                        //
                        //                            logD("toggling google mode")
                        //
                        //                        }) {
                        //                            ZStack {
                        //                                Text("🌐")
                        //                                Text("❌")
                        //                                    .opacity(0.6)
                        //
                        //                            }
                        //                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                        //                                .lineLimit(1)
                        //                                .foregroundColor(Color.white)
                        //                                .background(settingsViewModel.buttonColor)
                        //                                .cornerRadius(10)
                        //                        }
                        //                        .padding(.bottom)
                        //
                        //                        Button(action: {
                        //                            logD("toggling linking mode")
                        //                        }) {
                        //                            ZStack {
                        //                                Text("🔗")
                        //                                Text("❌")
                        //                                    .opacity(0.6)
                        //                            }
                        //                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                        //                                .lineLimit(1)
                        //                                .foregroundColor(Color.white)
                        //                                .background(settingsViewModel.buttonColor)
                        //                        }
                        //                        .padding(.bottom)

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
                            // .padding(.bottom)
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
                            //.padding(.bottom)
                        }

                        //                        // g BUTTON
                        //                        Button(action: {
                        //
                        //                            self.settingsViewModel.isInputViewShown = false
                        //                            settingsViewModel.multiLineText = ""
                        //
                        //                            settingsViewModel.createAndOpenNewConvo()
                        //
                        //                        }) {
                        //                            Text( "➕")
                        //                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                        //                                .lineLimit(1)
                        //                                .foregroundColor(Color.white)
                        //                                .background(settingsViewModel.buttonColor)
                        //                                .multilineTextAlignment(.center)
                        ////                                .padding(.leading, 8)
                        ////                                .padding(.trailing, 8)
                        //
                        //
                        //                        }
                        //
                        //                        .padding(.bottom)

                    }
                    //                    if !settingsViewModel.multiLineText.isEmpty && settingsViewModel.isInputViewShown {
                    //
                    //                        // STOP // EXIT CONVERSATIONAL MODE BUTTON
                    //                        Button(action: {
                    //
                    //                            // cmd send st
                    //                            settingsViewModel.multiLineText = "g end"
                    //                            DispatchQueue.main.async {
                    //
                    //                                // Execute your action here
                    //                                screamer.sendCommand(command: settingsViewModel.multiLineText)
                    //
                    //                                self.settingsViewModel.isInputViewShown = false
                    //
                    //                                settingsViewModel.multiLineText = ""
                    //                            }
                    //
                    //                        }) {
                    //                            ZStack {
                    //                                Text("🧠")
                    //                                Text("❌")
                    //                                    .opacity(0.74)
                    //                            }
                    //                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                    //
                    //                            .lineLimit(1)
                    //                            .foregroundColor(Color.white)
                    //                            .background(settingsViewModel.buttonColor)
                    //                        }
                    //                        .padding(.bottom)
                    //                    }
                    if !settingsViewModel.multiLineText.isEmpty && isInputViewShown {
                        // X BUTTON
                        Button(action: {
                            // cmd send st
                            settingsViewModel.multiLineText = "g end"
                            DispatchQueue.main.async {

                                // Execute your action here
                                screamer.sendCommand(command: settingsViewModel.multiLineText)

                                isInputViewShown = false

                                settingsViewModel.multiLineText = ""
                            }

                        }) {
                            Text( "🗑️")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }
                        //.padding(.bottom)
                    }

                    // STOP BUTTON
                    Button(action: {

                        // cmd send st
                        settingsViewModel.multiLineText = "st"
                        DispatchQueue.main.async {

                            // Execute your action here
                            screamer.sendCommand(command: settingsViewModel.multiLineText)

                            isInputViewShown = false

                            settingsViewModel.multiLineText = ""
                        }

                    }) {
                        Text("🛑")
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
                        //                            .padding(.bottom)
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
                            
                            isInputViewShown = false
#if !os(macOS)
                            consoleManager.isVisible = true
#endif
                        }) {
                            Text("✅")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                            // .padding(.bottom)
                        }
                    }

                    // TERM/COMMAND BUTTON
                    Button(action: {
                        if settingsViewModel.commandMode == .commandText {
                            // Execute your action here
                            screamer.sendCommand(command: settingsViewModel.multiLineText)

                            isInputViewShown = false
                            settingsViewModel.commandMode = .commandBar
                        }
                        else {
#if !os(macOS)
                            consoleManager.isVisible = false
#endif
                            openText()
                        }
                    }) {
                        if isInputViewShown {
                            Text("🔽")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }
                        else {
                            Text( "⬆️")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }

                    }
                }
                .padding(.leading,8)
                .padding(.trailing,8)
                .padding(.bottom,8)
                .edgesIgnoringSafeArea([.top])

                if isInputViewShown {
                    // MAIN INPUT TEXTFIELD

                    ZStack(alignment: .leading) {
                        Text(settingsViewModel.multiLineText)
                            .font(.system(.body))
                            .foregroundColor(.clear)
                            .padding(14)
                            .background(GeometryReader {
                                Color.clear.preference(key: ViewHeightKey.self,
                                                       value: $0.frame(in: .local).size.height)
                            })

                        TextEditor(text: $settingsViewModel.multiLineText)
                            .lineLimit(nil)
                            .border(settingsViewModel.buttonColor, width: 2)
                            .frame(height: max(40,textEditorHeight))
                            .padding(.leading, 8)
                            .padding(.bottom, 30 + settingsViewModel.commandButtonFontSize)
                            .autocorrectionDisabled(!settingsViewModel.autoCorrect)
#if !os(macOS)
                            .autocapitalization(.none)
#endif
                            .focused($isTextFieldFocused)
                            .scrollDismissesKeyboard(.interactively)
                            .toolbar {
                                if isTextFieldFocused {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()

                                        Button("Done") {
                                            isTextFieldFocused = false
                                        }
                                    }
                                }
                            }

                    }.onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
                }
            }
        }
    }
    struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value + nextValue()
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
