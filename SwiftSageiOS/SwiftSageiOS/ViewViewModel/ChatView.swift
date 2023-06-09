//
//  ChatView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI
import Combine

struct ChatView: View {
#if !os(macOS)

    @ObservedObject var sageMultiViewModel: SageMultiViewModel
#endif
    @ObservedObject var settingsViewModel: SettingsViewModel

    @Binding var conversations: [Conversation]

    var window: WindowInfo?
    @Binding var isEditing: Bool
    @Binding var isLockToBottom: Bool

    @ObservedObject var windowManager: WindowManager

    @State var chatText = ""
    @State var textEditorHeight : CGFloat = 40
    @FocusState private var isTextFieldFocused: Bool

    @Environment(\.dateProviderValue) var dateProvider
    @Environment(\.idProviderValue) var idProvider

    @Binding var isMoveGestureActive: Bool
    @Binding var isResizeGestureActive: Bool

    var body: some View {
        GeometryReader { geometry in
#if !os(macOS)
            VStack(spacing: 0) {

                // TODO: OPTIMIZE THIS INEFFECIENT
                let convoText =  window?.convoId == Conversation.ID(-1) ? settingsViewModel.consoleManagerText : settingsViewModel.convoText(conversations, window: window)
                
                // We reuse the SourceCodeEditor as GPT chat view :)
                SourceCodeTextEditor(text: $sageMultiViewModel.sourceCode, isEditing: $isEditing, isLockToBottom: $isLockToBottom, customization:
                                        SourceCodeTextEditor.Customization(didChangeText:
                                                                            { srcCodeTextEditor in
                    // do nothing
                    
                }, insertionPointColor: {
                    Colorv(cgColor: settingsViewModel.buttonColor.cgColor!)
                }, lexerForSource: { lexer in
                    SwiftLexer()
                }, textViewDidBeginEditing: { srcEditor in
                    // do nothing
                }, theme: {
                    ChatSourceCodeTheme(settingsViewModel: settingsViewModel)
                    // The Magic
                }, overrideText:  { convoText } ), isMoveGestureActive: $isMoveGestureActive, isResizeGestureActive: $isResizeGestureActive)

                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Text(chatText)
                            .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                            .foregroundColor(.clear)
                            .background(GeometryReader {
                                Color.clear.preference(key: ViewHeightKey.self,
                                                       value: $0.frame(in: .local).size.height)
                            })

                        TextEditor(text: $chatText)
                            .lineLimit(nil)
                            .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                            .foregroundColor(settingsViewModel.plainColorSrcEditor)
                            .scrollContentBackground(.hidden) // <- Hide it
                            .background(settingsViewModel.backgroundColorSrcEditor)
                            .frame(height: max( 40, textEditorHeight))
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
                        // Placeholder...
                        Text("Type \(window?.convoId == Conversation.ID(-1) ? "Cmd" : "Msg")...")
                            .padding(.leading,4)
                            .fontWeight(.light)
                            .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                            .foregroundColor(settingsViewModel.plainColorSrcEditor)

                            .allowsHitTesting(false)
                            .foregroundColor(settingsViewModel.appTextColor.opacity(0.5)).opacity(!isTextFieldFocused && chatText.isEmpty ? 1.0 : 0.0)
                    }.onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }

                    if chatText.count > 0 {
                        // EXEC BUTTON
                        Button(action: {
                            doChat()
                        }) {
                            resizableButtonImage(systemName:
                                                    "paperplane.fill",
                                                 size: geometry.size)
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
                        }
                    }
                    if !convoText.isEmpty {
                        // EXEC BUTTON
                        Button(action: {
                            setLockToBottom()
                        }) {
                            Text("\(!isLockToBottom ? "🔽": "🔒")")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }
                    }

                    if window?.convoId == Conversation.ID(-1) {
                        // EXEC BUTTON
                        Spacer()

                        // GOOGLE button
                        Button(action: {

                            logD("CHOOSE RANDOM WALLPAPER")
                            // cmd send st
                            DispatchQueue.main.async {
                                // Execute your action here
                                screamer.sendCommand(command: "wallpaper random")
                            }
                        }) {
                            Text("🖼️")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }

                        Button(action: {
                            logD("RUN SIMULATOR")

                            settingsViewModel.latestWindowManager = windowManager

                            DispatchQueue.main.async {

                                // Execute your action here
                                screamer.sendCommand(command: "simulator")
                            }
                        }) {
                            ZStack {
                                Text("📲")
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
                            Text( "⚖️")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }

                        // i BUTTON
                        Button(action: {
                            chatText = "i "
                        }) {
                            Text( "💡")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }


                        Button(action: {
                            chatText = ""
                            screamer.sendCommand(command: "g end")

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.333) {
                                settingsViewModel.consoleManagerText = ""
                            }

                        }) {
                            Text("🗑️")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
                        }
                    }
                }
                .onChange(of: isEditing) { editing in
                    if editing {
                        isTextFieldFocused = true
                    }
                }
                
                .background(settingsViewModel.backgroundColorSrcEditor)
            }
#else
            VStack { }
#endif
        }
        
    }
    func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
            .tint(settingsViewModel.appTextColor)
            .background(settingsViewModel.buttonColor)
    }
    func doChat() {
        if chatText.isEmpty {
            logD("nothing to exec.")

            return
        }
        if let convoID = window?.convoId {
            if convoID == Conversation.ID(-1) {
                screamer.sendCommand(command: chatText)
            }
            else {
                settingsViewModel.sendChatText(convoID, chatText: chatText)
            }
            chatText = ""
            isTextFieldFocused = false
        }
        else {
            logD("failed to chat")
        }
    }
    func setLockToBottom() {
        isLockToBottom.toggle()
    }
    struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value + nextValue()
        }
    }
}
