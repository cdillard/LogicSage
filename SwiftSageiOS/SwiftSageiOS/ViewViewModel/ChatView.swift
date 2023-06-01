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

    @State var chatText = ""
    @State var textEditorHeight : CGFloat = 40
    @FocusState private var isTextFieldFocused: Bool

    @Environment(\.dateProviderValue) var dateProvider
    @Environment(\.idProviderValue) var idProvider


    var body: some View {
#if !os(macOS)
        VStack(spacing: 0) {
            let viewModel = SourceCodeTextEditorViewModel()
            let convoText = settingsViewModel.convoText(conversations, window: window)

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
            }, overrideText:  { convoText } ))
            .environmentObject(viewModel)

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
                    Text("Type Msg...")
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
                        Text("✅")
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

            }
        }

#else
        VStack { }
#endif
    }
    func doChat() {
        if chatText.isEmpty {
            logD("nothing to exec.")

            return
        }
        if let convoID = window?.convoId {
            settingsViewModel.sendChatText(convoID, chatText: chatText)

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
