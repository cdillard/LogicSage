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
    var body: some View {
        GeometryReader { geometry in
            let keyboardTop = geometry.frame(in: .global).height - keyboardHeight

            VStack(spacing: 0) {
                ZStack {
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
                    } ), isMoveGestureActive: $isMoveGestureActive, isResizeGestureActive: $isResizeGestureActive)

                    .onAppear {
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
#endif
                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(tvOS)

                messgeEntry(size: geometry.size)
                .frame( maxWidth: .infinity, maxHeight: .infinity)
                .padding(.trailing, settingsViewModel.cornerHandleSize)
                .padding(.bottom, 0)
                .frame(height: textEditorHeight + 30)
                .background(settingsViewModel.backgroundColorSrcEditor)
#endif

            }
            .frame( maxWidth: .infinity, maxHeight: .infinity)
            .overlay(CheckmarkView(isVisible: $showCheckmark))
            .cornerRadius(16)
#if !os(xrOS)
#if !os(macOS)
            .keyboardAdaptive(keyboardHeight: $keyboardHeight, frame: $frame, position: $position, resizeOffset: $resizeOffset, keyboardTop: keyboardTop, safeAreaInsetBottom: geometry.safeAreaInsets.bottom)
#endif
#endif
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
                    if #available(iOS 16.0, *) {
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

                    }
                    else {
                        TextEditor(text: $chatText)
                            .lineLimit(nil)
                            .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                            .foregroundColor(settingsViewModel.plainColorSrcEditor)
                            .background(settingsViewModel.backgroundColorSrcEditor)
                            .frame(height: max( 40, textEditorHeight))
#if !os(macOS)
                            .autocorrectionDisabled(!settingsViewModel.autoCorrect)
#endif
#if !os(macOS)
                            .autocapitalization(.none)
#endif
                            .cornerRadius(16)
                    }

                    Text("Send a \(sageMultiViewModel.windowInfo.convoId == Conversation.ID(-1) ? "cmd" : "message")")
                        .opacity(chatText.isEmpty ? 1.0 : 0.0 )
                        .padding(.leading,4)
                        .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                        .foregroundColor(settingsViewModel.plainColorSrcEditor)
                        .allowsHitTesting(false)

                    if keyboardHeight != 0 {
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

//#if !os(macOS)
//            .hoverEffect(.automatic)
//#endif
            // END Chat message entry

            // BEGIN Chat bottom ... menu
            if chatText.count > 0 {
                // EXEC BUTTON
                Button(action: {
                    doChat()
                }) {
                    resizableButtonImage(systemName:
                                            "paperplane.fill",
                                         size: size)
                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
//dddd//                    .background(settingsViewModel.buttonColor)
#if !os(macOS)
                    .hoverEffect(.automatic)
#endif
                }
            }

            // EXEC BUTTON
            Button(action: {
                setLockToBottom()
            }) {
                resizableButtonImage(systemName:
                                        !isLockToBottom ? "arrow.down" : "lock",
                                     size: size)
                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                    .lineLimit(1)
//                    .foregroundColor(Color.white)
//                    .background(settingsViewModel.buttonColor)
//#if !os(macOS)
//                    .hoverEffect(.automatic)
//#endif
            }

            if sageMultiViewModel.windowInfo.convoId == Conversation.ID(-1) {

                Spacer()
                ChatBotomMenu(settingsViewModel: settingsViewModel, chatText: $chatText, windowManager: windowManager)

            }
            // END Chat bottom ... menu
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
                .background(settingsViewModel.buttonColor)
        } else {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
                .background(settingsViewModel.buttonColor)
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
