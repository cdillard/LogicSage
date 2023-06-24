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
#if !os(xrOS)
    
    @ObservedObject var sageMultiViewModel: SageMultiViewModel
#endif
#endif
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
    @State private var activeFieldFrame: CGRect = .zero
    
    @Binding var frame: CGRect
    @Binding var position: CGSize
    @Binding var resizeOffset: CGSize
    @State private var lastDragLocation: CGFloat = 0
    @State private var isDraggedDown: Bool = false
    @State private var showCheckmark: Bool = false
    var body: some View {
        GeometryReader { geometry in
#if !os(macOS)
#if !os(xrOS)
            
            ScrollView {
                VStack(spacing: 0) {
                    ZStack {
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
                        },
                                                                                   overrideText:  {
                            //                    print("ex overrideText.update() of ChatView")
                            //                    if isMoveGestureActive { return "moving" }
                            //                    if isResizeGestureActive { return "resizing" }
                            return sageMultiViewModel.getConvoText()
                        }, codeDidCopy: {
                            onCopy()
                        } ),
                                             isMoveGestureActive: $isMoveGestureActive, isResizeGestureActive: $isResizeGestureActive)
                        //                    .disabled(isMoveGestureActive || isResizeGestureActive)
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
                    }

                    // Chat message entry...
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
                                        .autocorrectionDisabled(!settingsViewModel.autoCorrect)
                                        .autocapitalization(.none)
                                        .cornerRadius(16)
                                        .scrollDismissesKeyboard(.interactively)
                                        .onAppear {
                                            activeFieldFrame = innerReader.frame(in: .global)
                                        }
                                }
                                else {
                                    TextEditor(text: $chatText)
                                        .lineLimit(nil)
                                        .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                                        .foregroundColor(settingsViewModel.plainColorSrcEditor)
                                        .background(settingsViewModel.backgroundColorSrcEditor)
                                        .frame(height: max( 40, textEditorHeight))
                                        .autocorrectionDisabled(!settingsViewModel.autoCorrect)
                                        .autocapitalization(.none)
                                        .cornerRadius(16)
                                    
                                        .onAppear {
                                            activeFieldFrame = innerReader.frame(in: .global)
                                        }

                                    
                                }
                                Text("Type \(sageMultiViewModel.windowInfo.convoId == Conversation.ID(-1) ? "Cmd" : "Msg")...")
                                    .opacity(chatText.isEmpty ? 1.0 : 0.0 )
                                    .padding(.leading,4)
                                    .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                                    .foregroundColor(settingsViewModel.plainColorSrcEditor)
                                    .allowsHitTesting(false)
                                
                                if keyboardHeight != 0 {
                                    AnimatedArrow()
                                        .zIndex(994)
                                        .simultaneousGesture(TapGesture().onEnded {
                                            hideKeyboard()
                                            // Handle the swipe down action here
                                            
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
                                    hideKeyboard()
                                }
                        }
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
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
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                            }
                        }
                        
                        // EXEC BUTTON
                        Button(action: {
                            setLockToBottom()
                        }) {
                            Text("\(!isLockToBottom ? "🔽": "🔒")")
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .background(settingsViewModel.buttonColor)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                        }
                        
                        if sageMultiViewModel.windowInfo.convoId == Conversation.ID(-1) {
                            // EXEC BUTTON
                            Spacer()
                            
                            Menu {
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
                                
                                // Simulator BUTTON
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
                            } label: {
                                Label("", systemImage: "ellipsis")
                                    .font(.body)
                                    .labelStyle(DemoStyle())
                            }
                        }


                    }
                    
                    .padding(.trailing, settingsViewModel.cornerHandleSize)
                    
                    .frame(height: textEditorHeight + 30)
                    
                    .background(settingsViewModel.backgroundColorSrcEditor)
                    .cornerRadius(16)
                    
                }
                .frame(height: geometry.size.height)
                .background(settingsViewModel.backgroundColorSrcEditor)
                .cornerRadius(16)
                
                
                Spacer()
            }
            .overlay(CheckmarkView(isVisible: $showCheckmark))
            .padding(.bottom, getBottomPadding())
            .animation(.easeOut(duration: 0.16))
            .frame(height: geometry.size.height)
            .cornerRadius(16)
            .background(settingsViewModel.backgroundColorSrcEditor)
            .onAppear {
#if !os(macOS)
                UIScrollView.appearance().bounces = false
                UITextView.appearance().backgroundColor = .clear
#endif
            }

#else
            VStack { }
#endif
#endif
            
        }
    }
    func resizableButtonImage(systemName: String, size: CGSize) -> some View {
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
            // .tint(settingsViewModel.appTextColor)
                .background(settingsViewModel.buttonColor)
            
        }
    }
    func doChat() {
#if !os(macOS)
#if !os(xrOS)
        
        if chatText.isEmpty {
            logD("nothing to exec.")
            
            return
        }
        
        hideKeyboard()
        
        if let convoID = sageMultiViewModel.windowInfo.convoId {
            if convoID == Conversation.ID(-1) {
                screamer.sendCommand(command: chatText)
            }
            else {
                settingsViewModel.sendChatText(convoID, chatText: chatText)
            }
            chatText = ""
            //isTextFieldFocused = false
        }
        else {
            logD("failed to chat")
        }
#endif
#endif
        
    }
    func setLockToBottom() {
        isLockToBottom.toggle()
        
        print("setting isLockToBottom to \(isLockToBottom)")
        
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
#if !os(macOS)
#if !os(xrOS)
    
    private func getBottomPadding() -> CGFloat {
        //        if windowManager.topWindow() != sageMultiViewModel.windowInfo {
        //            return 0
        //        }
        var offset: CGFloat = 0
        var fieldBottom: CGFloat = 0
        if resizeOffset.height < 0 {
            offset = -abs(resizeOffset.height / 2)
            fieldBottom = activeFieldFrame.origin.y + activeFieldFrame.size.height + position.height + offset
            
        }
        else if resizeOffset.height > 0 {
            offset = -(resizeOffset.height / 2)
            fieldBottom = activeFieldFrame.origin.y + activeFieldFrame.size.height + position.height - offset
            
        }
        else {
            fieldBottom = activeFieldFrame.origin.y + activeFieldFrame.size.height + position.height
        }
        let keyboardTop = UIScreen.main.bounds.height - keyboardHeight
        
        //        print("keyboardTop: \(keyboardTop) < fieldBottom: \(fieldBottom)")
        //
        //        print("windowFrame = \(frame)")
        //        print("windowPos = \(position)")
        if keyboardTop < fieldBottom {
            return fieldBottom - keyboardTop
        } else {
            return 0
        }
    }
#endif
#endif
    struct DemoStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .center) {
                configuration.icon
                configuration.title
            }
        }
    }
}
#if !os(macOS)

class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
            .map { $0.height }
            .merge(with:
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in CGFloat(0) }
            )
            .assign(to: \.keyboardHeight, on: self)
    }

    deinit {
        cancellable?.cancel()
    }
}
#endif
struct AnimatedArrow: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let size = geometry.size.height * 0.3
                let yPosition = size * 0.7
                path.move(to: CGPoint(x: geometry.size.width * 0.5, y: yPosition))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.5 - size * 0.5, y: yPosition + size))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.5 + size * 0.5, y: yPosition + size))
            }

            .fill(Color.gray)
            .opacity(self.animate ? 1.0 : 0.0)
            .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.3))
            .rotationEffect(.degrees(180), anchor: .center)

            .onAppear {
                self.animate = true
            }
        }
    }
}
struct CheckmarkView: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            HStack(spacing: 10) {
                Image(systemName: "checkmark")
                Text("Copied!")
                    .font(.title3)
            }
            .font(.callout)
            .background(SettingsViewModel.shared.buttonColor)
            .cornerRadius(10)
            .foregroundColor(SettingsViewModel.shared.appTextColor)
            .padding()
            .transition(.opacity)
        }
    }
}
