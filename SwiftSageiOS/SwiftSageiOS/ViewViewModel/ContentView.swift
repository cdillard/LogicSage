//
//  ContentView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/23/23.
//

import SwiftUI
import Foundation
import Combine
import AVKit

#if os(macOS)

import AppKit
#endif

#if !os(macOS)

let consoleManager = LCManager.shared//cmdWindows[0]

#endif

struct ContentView: View {
    @State private var showSettings = false
    @State private var  code: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var buttonScale: CGFloat = 1.0
    @ObservedObject var settingsViewModel: SettingsViewModel

    @StateObject private var windowManager = WindowManager.shared

    @Binding var isDrawerOpen: Bool
#if !os(macOS)

    @ObservedObject private var keyboardResponder = KeyboardResponder()
#endif
    var body: some View {

        GeometryReader { geometry in
            ZStack {
                ZStack {
                    ZStack {
                        // START MAC OS SPECIFIC PANE FOR OPENING TERMINALS AND POTENTIALLY MORE. *********************
#if os(macOS)
                        VStack(alignment: .leading, spacing: 8) {
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
                    }
                    // END MAC OS SPECIFIC PANE FOR OPENING TERMINALS AND POTENTIALLY MORE. *********************
                }
#if !os(macOS)
                // START WINDOW MANAGER ZONE *************************************************
                ForEach(windowManager.windows) { window in
                    WindowView(window: window, frame: window.convoId != nil ? defChatSize : defSize, settingsViewModel: settingsViewModel)
                        .padding(SettingsViewModel.shared.cornerHandleSize)
                        .edgesIgnoringSafeArea(.all)
                        .background(.clear)
                        .environmentObject(windowManager)
                }
                // END WINDOW MANAGER ZONE *************************************************
#endif
                // START CPNVERSATION HAMBURGER ZONE *************************************************
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.isDrawerOpen.toggle()
                            }
                        }) {
                            Image(systemName: isDrawerOpen ? "x.circle.fill" : "line.horizontal.3")
                                .resizable()
                                .scaledToFit()
                                .tint(settingsViewModel.appTextColor)
                                .background(settingsViewModel.buttonColor)
                                .padding(3)
#if !os(macOS)
                                .frame(width: UIScreen.main.bounds.width / 15, height: UIScreen.main.bounds.height / 15 )
#endif
                                .animation(.easeIn(duration:0.25), value: isDrawerOpen)
                        }
                        Spacer()
                    }
                    .padding(8)
                    Spacer()
                }
                .padding(8)
                // END CPNVERSATION HAMBURGER ZONE *************************************************


                // START TOOL BAR / COMMAND BAR ZONE ***************************************************************************
                VStack {
                    Spacer()
                    CommandButtonView(settingsViewModel: settingsViewModel)
                        .environmentObject(windowManager)
                }

                VStack {
                    Spacer()
                    HStack(alignment: .bottom, spacing: 0) {
                        // OPEN TERM BUTTON

                        Button(action: {
#if !os(macOS)

                            hideKeyboard()
#endif
#if !os(macOS)
                            if consoleManager.isVisible {
                                consoleManager.isVisible = false

                            } else {
                                consoleManager.isVisible = true
                            }
                            if showSettings {
                                showSettings = false
                            }
                            if settingsViewModel.showAddView  {
                                settingsViewModel.showAddView = false
                            }
#endif
                        }) {
                            resizableButtonImage(systemName: "text.and.command.macwindow", size: geometry.size)
                        }

                        // SETTINGS BUTTON
                        Button(action: {
#if !os(macOS)

                            hideKeyboard()
#endif

                            withAnimation {
                                showSettings.toggle()
#if !os(macOS)

                                if consoleManager.isVisible {
                                    consoleManager.isVisible = false
                                }
#endif

                            }
                        }) {
                            resizableButtonImage(systemName: "gearshape", size: geometry.size)
                        }

                        // ADD VIEW BUTTON
                        Button(action: {
#if !os(macOS)
                            hideKeyboard()
#endif

#if !os(macOS)
                            consoleManager.isVisible = false
#endif
                            settingsViewModel.showAddView.toggle()
                            if showSettings {
                                showSettings = false
                            }
                        }) {

                            resizableButtonImage(systemName: "plus.rectangle", size: geometry.size)
                        }

                        Button(action: {
#if !os(macOS)
                            hideKeyboard()
#endif
                            if !settingsViewModel.hasAcceptedMicrophone {
                                logD("Enable mic in Settings...")
                                return
                            }
                            if settingsViewModel.isRecording {
                                settingsViewModel.speechRecognizer.stopRecording()
                            } else {
                                settingsViewModel.speechRecognizer.startRecording()
                            }
                            settingsViewModel.isRecording.toggle()
                        }) {
                            resizableButtonImage(systemName: settingsViewModel.isRecording ? "mic.fill" : "mic.slash.fill", size: geometry.size)
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
                            .font(.body)
                        Spacer()
                    }
                }
#if !os(macOS)
                .onAppear {
                    recalculateWindowSize(size: geometry.size)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    DispatchQueue.main.async {
                        recalculateWindowSize(size: geometry.size)
                    }
                }
#endif
                .background(
                    ZStack {
#if !os(macOS)
                        AddView(showAddView: $settingsViewModel.showAddView, settingsViewModel: settingsViewModel)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .opacity(settingsViewModel.showAddView ? 1.0 : 0.0)
                            .environmentObject(windowManager)
                        SettingsView(showSettings: $showSettings, settingsViewModel: settingsViewModel)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .opacity(showSettings ? 1.0 : 0.0)
#endif
                    }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                )
                .padding(.leading,8)

                .padding(.bottom,8)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .overlay(
                Group {
                    if settingsViewModel.showInstructions {
                        InstructionsPopup(isPresented: $settingsViewModel.showInstructions ,settingsViewModel: settingsViewModel )
                    }
                    else if settingsViewModel.showHelp {
                        HelpPopup(isPresented: $settingsViewModel.showHelp ,settingsViewModel: settingsViewModel )

                    }
                }
            )
            // END TOOL BAR / COMMAND BAR ZONE ***************************************************************************

            // BEGIN CONTENTVIEW BACKGROUND ZONE ***************************************************************************
            .background {
                ZStack {
#if !os(macOS)
                    // Use
                    // settingsViewModel.receivedImage = nil
                    // To clear background image
                    if let image = settingsViewModel.actualReceivedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .zIndex(2)
                            .ignoresSafeArea()
                            .animation(.easeIn(duration: 0.28), value: image)
                    }
                    else {
                        settingsViewModel.backgroundColor
                            .ignoresSafeArea()
                    }

                    //                let fileURL = getDocumentsDirectory().appendingPathComponent("recording.mov")
                    //
                    //                VideoPlayer(player: AVPlayer(url:  fileURL))
                    //                    .frame(height: 400)

#else
                    settingsViewModel.backgroundColor
                        .ignoresSafeArea()
#endif
                }
#if !os(macOS)
                .padding(.bottom, keyboardResponder.currentHeight)
#endif
                //.animation(.easeOut(duration: 0.16))
//                .animation(.easeOut(duration: 16), value: keyboardResponder.currentHeight)

                .edgesIgnoringSafeArea(.all)

            }
        }
        
    }
// END CONTENTVIEW BACKGROUND ZONE ***************************************************************************

    private func recalculateWindowSize(size: CGSize) {
#if !os(macOS)
        defSize = CGRectMake(0, 0, size.width - (size.width * 0.22), size.height - (size.height * 0.22))
        defChatSize = CGRectMake(0, 0, size.width - (size.width * 0.5), size.height - (size.height * 0.5))
#endif
    }
    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
            .tint(settingsViewModel.appTextColor)
            .background(settingsViewModel.buttonColor)
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
#if !os(macOS)

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    var keyboardShow: AnyCancellable?
    var keyboardHide: AnyCancellable?

    init() {
        keyboardShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
            .assign(to: \.currentHeight, on: self)

        keyboardHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .assign(to: \.currentHeight, on: self)
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
#endif
