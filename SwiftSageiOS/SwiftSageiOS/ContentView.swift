//
//  ContentView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/23/23.
//

import SwiftUI
import Foundation
import Combine
#if os(macOS)

import AppKit
#endif

#if !os(macOS)

let consoleManager = LCManager.shared//cmdWindows[0]

#endif

let maxButtonSize: CGFloat = 19.5


struct ContentView: View {
    @State private var showSettings = false
    @State private var isLabelVisible: Bool = true
    @State private var  code: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0

    @StateObject private var keyboardObserver = KeyboardObserver()

    @ObservedObject var settingsViewModel = SettingsViewModel.shared




    var body: some View {

        GeometryReader { geometry in
            ZStack {
                // SOURCE CODE EDITOR HANDLE
                ZStack {

                    // MAC OS SPECIFIC PANE FOR OPENING TERMINALS AND POTENTIALLY MORE.
#if os(macOS)
                    VStack {
                        Button(action: {
                            openTerminal()
                        }) {
                            Text("Open Terminal")
                        }
                        .zIndex(2)


                        Button(action: {
                            openiTerm2()
                        }) {
                            Text("Open iTerm2")
                        }
                        .zIndex(2)

                        Button(action: {
                            openTerminalAndRunCommand(command: "echo 'Hello, Terminal!'")

                        }) {
                            Text("Open Terminal.app and run cmd.")
                        }
                        .zIndex(2)

                    }
                    .zIndex(2)
#endif

                    //
                    //                    if settingsViewModel.isEditorVisible {
                    //#if !os(macOS)
                    //
                    //                        HandleView()
                    //                            .zIndex(2) // Add zIndex to ensure it's above the SageWebView
                    //                            .offset(x: -12, y: -12) // Adjust the offset values
                    //                            .gesture(
                    //                                DragGesture()
                    //                                    .onChanged { value in
                    //                                        positionEditor = CGSize(width: positionEditor.width + value.translation.width, height: positionEditor.height + value.translation.height)
                    //                                    }
                    //                                    .onEnded { value in
                    //                                        // No need to reset the translation value, as it's read-only
                    //                                    }
                    //                            )
                    //#endif
                }
                HStack {
                    VStack {
                        Image("swsLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.1)
                            .scaledToFit()
                            .padding(.top, 3)
                            .padding(.leading, 1)
                        Spacer()

                    }
                    Spacer()
                }

            }

            // HANDLE WEBVIEW
            if settingsViewModel.isWebViewVisible {
#if !os(macOS)
                VStack {

                    SageMultiView(settingsViewModel: settingsViewModel, theCode: "", viewMode: .webView)
                }
#endif
            }
            if settingsViewModel.isEditorVisible {
#if !os(macOS)
                VStack {

                    SageMultiView(settingsViewModel: settingsViewModel, theCode: code1, viewMode: .editor)
                }
#endif
            }


            // HANDLE SIMULATOR
#if !os(macOS)

            if let image = settingsViewModel.receivedImage {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.leading,geometry.size.width * 0.01)
                    Spacer()
                }
            } else {
                VStack {
                    HStack {
                        Spacer()

                        Text("Restart app if you encounter any issues, OK?\nFresh install if terminal becomes too small :(")
                            .font(.caption)
                            .lineLimit(nil)


                    }
                    Spacer()
                }
            }
#endif

            VStack {
                Spacer()
                CommandButtonView(settingsViewModel: settingsViewModel)
            }
            .padding(.bottom, keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight : 0)
            .animation(.easeInOut(duration: 0.25), value: keyboardObserver.isKeyboardVisible)
            .environmentObject(keyboardObserver)


            VStack {
                Spacer()
                HStack(spacing: 0) {
                    // OPEN TERM BUTTON

                    Button(action: {
#if !os(macOS)
                        if consoleManager.isVisible {
                            consoleManager.isVisible = false

                        } else {
                            consoleManager.isVisible = true
                        }

                        settingsViewModel.receivedImage = nil
#endif
                    }) {
                        resizableButtonImage(systemName: "text.and.command.macwindow", size: geometry.size)
                    }

                    // SETTINGS BUTTON
                    Button(action: {
                        withAnimation {
                            showSettings.toggle()
                        }
                    }) {
                        resizableButtonImage(systemName: "gearshape", size: geometry.size)
                    }
                    .popover(isPresented: $showSettings, arrowEdge: .top) {
#if !os(macOS)

                        if UIDevice.current.userInterfaceIdiom == .pad {
                            SettingsView(showSettings: $showSettings, settingsViewModel: settingsViewModel)
                                .frame(width:  geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                        }
                        else {
                            SettingsView(showSettings: $showSettings, settingsViewModel: settingsViewModel)

                        }
#endif


                    }
                    // PING BUTTON
                    Button(action: {
                        if screamer.websocket != nil {
                            screamer.websocket.write(ping: Data())
                        }
#if !os(macOS)
                        consoleManager.print("ping...")
#endif
                        print("ping...")
                    }) {

                        resizableButtonImage(systemName: "shippingbox.and.arrow.backward", size: geometry.size)
                    }

                    // ADD VIEW BUTTON
                    Button(action: {
#if !os(macOS)
                        consoleManager.isVisible = false
#endif
                        settingsViewModel.showAddView.toggle()

                        // window 1 is for second cmd prompt
                    }) {

                        resizableButtonImage(systemName: "plus.rectangle", size: geometry.size)
                    }
                    .popover(isPresented: $settingsViewModel.showAddView, arrowEdge: .top) {

#if !os(macOS)

                        if UIDevice.current.userInterfaceIdiom == .pad {
                            AddView(showAddView: $settingsViewModel.showAddView, settingsViewModel: settingsViewModel)
                                .frame(width:  geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                        }
                        else {
                            AddView(showAddView: $settingsViewModel.showAddView, settingsViewModel: settingsViewModel)

                        }
#endif

                    }

                    // MIC BUTTON
                    // "mic.fill"
                    // "mic.slash.fill"
                    Button(action: {
                        if !settingsViewModel.hasAcceptedMicrophone {
#if !os(macOS)
                            consoleManager.print("Enable mic in Settings...")
#endif
                            print("Enable mic in Settings...")
                            return
                        }
                        if settingsViewModel.isRecording {
                            settingsViewModel.speechRecognizer.stopRecording()
                        } else {
                            settingsViewModel.speechRecognizer.startRecording()
                        }
                        settingsViewModel.isRecording.toggle()
                    }) {
                        //Text(isRecording ? "Stop Recording" : "Start Recording")
                        resizableButtonImage(systemName: settingsViewModel.isRecording ? "mic.fill" : "mic.slash.fill", size: geometry.size)
                            .font(.caption)
                            .lineLimit(nil)
                            .overlay(
                                Group {
                                    if !settingsViewModel.hasAcceptedMicrophone {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(Color.white.opacity(0.5))
                                    }
                                }
                            )
                    }

                    Text(settingsViewModel.recognizedText)
                        .font(.caption)
                        .lineLimit(nil)

                    Spacer()

                }
            }
            .onAppear {
                keyboardObserver.startObserve(height: geometry.size.height)
            }
            .onDisappear {
                keyboardObserver.stopObserve()
            }
            .onChange(of: showSettings) { newValue in
#if !os(macOS)
                if newValue {
                    print("Popover is shown")
                    consoleManager.isVisible = false
                } else {
                    print("Popover is hidden")
                    consoleManager.isVisible = true
                }
#endif
            }
        }
        .overlay(
            Group {
                if settingsViewModel.showInstructions {
                    InstructionsPopup(isPresented: $settingsViewModel.showInstructions ,settingsViewModel: settingsViewModel )
                }
            }
        )
    }
    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: min(size.width * 0.05, maxButtonSize), height: min(size.width * 0.05, maxButtonSize))
            .padding(size.width * 0.01)
            .background(settingsViewModel.buttonColor)
            .foregroundColor(.white)
//            .cornerRadius(size.width * 0.05)
    }
}


class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible = false
    @Published var keyboardHeight: CGFloat = 0

    private var screenHeight: CGFloat = 0

    func startObserve(height: CGFloat) {
#if !os(macOS)

        screenHeight = height
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
#endif
    }

    func stopObserve() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func onKeyboardChange(notification: Notification) {
#if !os(macOS)

        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardTop = screenHeight - keyboardFrame.origin.y
            isKeyboardVisible = keyboardTop > 0
            keyboardHeight = max(0, keyboardTop)
        }
#endif
    }
}

#if os(macOS)
func openTerminal() {
    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") {
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
    }
}

func openiTerm2() {
    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.googlecode.iterm2") {
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
    }
}

func openTerminalAndRunCommand(command: String) {
    let scriptContent = "#!/bin/sh\n" +
    "\(command)\n"

    do {
        let tempDirectory = FileManager.default.temporaryDirectory
        let appDirectory = tempDirectory.appendingPathComponent("SwiftSageiOS")
        try FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)

        let scriptURL = appDirectory.appendingPathComponent("temp_script.sh")
        try scriptContent.write(to: scriptURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: NSNumber(value: 0o755)], ofItemAtPath: scriptURL.path)

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = [scriptURL.path]
        configuration.promptsUserIfNeeded = true
        if let terminalURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") {
            NSWorkspace.shared.openApplication(at: terminalURL, configuration: configuration, completionHandler: nil)
        }
    } catch {
        print("Error: \(error)")
    }
}

#endif
