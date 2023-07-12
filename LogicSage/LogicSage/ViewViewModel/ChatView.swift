//
//  ChatView.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI
import Combine

struct ChatView: View {
    @ObservedObject var sageMultiViewModel: SageMultiViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel

    @Binding var isEditing: Bool
    @State var isLockToBottom: Bool = true

    @ObservedObject var windowManager: WindowManager

    @State var chatText = ""
    @State var textEditorHeight : CGFloat = 40
    @State var editingSystemPrompt: Bool = false

    @Environment(\.dateProviderValue) var dateProvider
    @Environment(\.idProviderValue) var idProvider

    @Binding var isMoveGestureActive: Bool
    @Binding var isResizeGestureActive: Bool

    @Binding var keyboardHeight: CGFloat

    @Binding var frame: CGRect
    @Binding var position: CGSize
    @Binding var resizeOffset: CGSize
    @State private var lastDragLocation: CGFloat = 0
    @State private var isDraggedDown: Bool = false
    @State private var showCheckmark: Bool = false

    @State private var choseBuiltInPrompt: String = ""
    @FocusState var inFocus

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { sp in
                ScrollView {
                    VStack(spacing: 0) {
                        let usableKeyboardHeight = sageMultiViewModel.frame.height > keyboardHeight ? (inFocus ? keyboardHeight : 0) : 0

#if !os(tvOS)
                        SourceCodeTextEditor(text: $sageMultiViewModel.sourceCode, isEditing: $isEditing, isLockToBottom: $isLockToBottom, customization:
                                                SourceCodeTextEditor.Customization(didChangeText:
                                                                                    { srcCodeTextEditor in
                            // do nothing
                        }, insertionPointColor: {
#if !os(macOS)
                            Colorv(cgColor: settingsViewModel.buttonColor.cgColor!)
#else
                            Colorv(.darkGreen)
#endif
                        }, lexerForSource: { lexer in
                            SwiftLexer()
                        }, textViewDidBeginEditing: { srcEditor in
                            // do nothing
                        }, theme: {
                            ChatSourceCodeTheme(settingsViewModel: settingsViewModel)
                        }, overrideText:  {
                            return sageMultiViewModel.getConvoText()
                        }, codeDidCopy: {
                            onCopy()
                        }, windowType: {.chat }), isMoveGestureActive: $isMoveGestureActive, isResizeGestureActive: $isResizeGestureActive)
                        .onAppear {
                            // TODO: Fix to use proper published.
                            Timer.scheduledTimer(withTimeInterval: settingsViewModel.chatUpdateInterval, repeats: true) { _ in
                                DispatchQueue.global(qos: .background).async {
                                    if let convoId = sageMultiViewModel.windowInfo.convoId {
                                        let convo = settingsViewModel.getConvo(convoId)
                                        DispatchQueue.main.async {
                                            sageMultiViewModel.conversation = convo
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: geometry.size.height - textEditorHeight - 30 - usableKeyboardHeight)

#endif
#if !os(tvOS)
                        
                        messgeEntry(size: geometry.size)
                            .padding(.trailing, settingsViewModel.cornerHandleSize)
                                            .padding(.bottom, 0)
                            .frame(height: textEditorHeight + 30)
                            .background(settingsViewModel.backgroundColorSrcEditor)
#endif
                    }
                    .overlay(CheckmarkView(text: "Copied", isVisible: $showCheckmark))
                    .cornerRadius(16)

                }
                .onChange(of: inFocus) { id in
                     withAnimation {
                         sp.scrollTo(id)
                     }
                 }
                .frame(height: geometry.size.height + 40)

            }
        }
    }
#if !os(tvOS)

    func messgeEntry(size: CGSize) -> some View {
        HStack(spacing: 0) {
            GeometryReader { innerReader in

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
                            .scrollContentBackground(.hidden)
                            .background(settingsViewModel.backgroundColorSrcEditor)
                            .frame(height: max( 40, textEditorHeight))
#if !os(macOS)
                            .autocorrectionDisabled(!settingsViewModel.autoCorrect)
#endif
#if !os(macOS)
                            .autocapitalization(.none)
#endif
                            .cornerRadius(16)
#if !os(xrOS)
                            .scrollDismissesKeyboard(.interactively)
#endif
                            .focused($inFocus)

                    Text(editingSystemPrompt ? "Set system msg" : "Send a \(sageMultiViewModel.windowInfo.convoId == Conversation.ID(-1) ? "cmd" : "message")")
                        .opacity(chatText.isEmpty ? 1.0 : 0.0 )
                        .padding(.leading,4)
                        .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                        .foregroundColor(settingsViewModel.plainColorSrcEditor)
                        .allowsHitTesting(false)

                    if keyboardHeight != 0 && inFocus {
                        AnimatedArrow()
                            .zIndex(994)
                            .simultaneousGesture(TapGesture().onEnded {
#if !os(macOS)
                                hideKeyboard()
#endif
                            })
                    }
                }.onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
                    .padding(.bottom, 0)
                    .cornerRadius(16)
                    .gesture(
                        DragGesture(minimumDistance: 5, coordinateSpace: .local)
                            .onChanged { value in
                                if value.startLocation.y < value.location.y {
                                    isDraggedDown = true
                                } else {
                                    isDraggedDown = false
                                }
                                lastDragLocation = value.location.y
                            }
                            .onEnded { value in

                                isDraggedDown = false
                            }
                    )
                    .onChange(of: isDraggedDown) { isDraggedDown in
#if !os(macOS)
                        hideKeyboard()
#endif
                    }
            }
            // BEGIN Chat bottom ... menu
            // EXEC BUTTON
            Button(action: {
                doChat()
            }) {
                resizableButtonImage(systemName:
                                        "paperplane.fill",
                                     size: size)
                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                .background(Color.clear)
#if !os(macOS)
                .hoverEffect(.automatic)
#endif
            }
            .disabled(chatText.isEmpty)

            //            if notAtBottom {
            //                Button(action: {
            //                    setLockToBottom()
            //                }) {
            //                    resizableButtonImage(systemName:"arrow.down",
            //                                         size: size)
            //                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
            //                    .lineLimit(1)
            //                    //                    .foregroundColor(Color.white)
            //                    .background(Color.clear)
            //                    //#if !os(macOS)
            //                    //                    .hoverEffect(.automatic)
            //                    //#endif
            //                }
            //            }

            Spacer()


            ChatBotomMenu(settingsViewModel: settingsViewModel, chatText: $chatText, windowManager: windowManager, windowInfo: $sageMultiViewModel.windowInfo, editingSystemPrompt: $editingSystemPrompt, choseBuiltInSystemPrompt: $choseBuiltInPrompt)
                .onChange(of: choseBuiltInPrompt) { value in

                    logD("EDIT SYSTEM PROMPT TO \(choseBuiltInPrompt)")
                    if let convoId = sageMultiViewModel.windowInfo.convoId {

                        settingsViewModel.setConvoSystemMessage(convoId, newMessage: choseBuiltInPrompt)

                    }
                    editingSystemPrompt = false
                }

        }
    }
#endif

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
#if os(macOS) || os(tvOS)
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)

#else
        if #available(iOS 16.0, *) {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
                .tint(settingsViewModel.appTextColor)
        } else {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
        }
#endif
    }
    func doChat() {
        if chatText.isEmpty {
            logD("nothing to exec.")
            return
        }
#if !os(macOS)
        hideKeyboard()
#endif

        if editingSystemPrompt {
            logD("EDIT SYSTEM PROMPT TO ")
            if let convoId = sageMultiViewModel.windowInfo.convoId {

                settingsViewModel.setConvoSystemMessage(convoId, newMessage: chatText)

            }
            editingSystemPrompt = false
            chatText = ""
        }
        else {
            if let convoID = sageMultiViewModel.windowInfo.convoId {
                if convoID == Conversation.ID(-1) {
                    screamer.sendCommand(command: chatText)
                }
                else {
                    settingsViewModel.sendChatText(convoID, chatText: chatText)
                }
                chatText = ""
            }
            else {
                logD("failed to chat")
            }
        }
    }
    func setLockToBottom() {
        isLockToBottom.toggle()
        if gestureDebugLogs {
            print("setting isLockToBottom to \(isLockToBottom)")
        }
    }
    private func onCopy() {
        withAnimation(Animation.easeInOut(duration: 0.666)) {
            showCheckmark = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.666) {
            withAnimation(Animation.easeInOut(duration: 0.6666)) {
                showCheckmark = false
            }
        }
    }
    struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value + nextValue()
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
