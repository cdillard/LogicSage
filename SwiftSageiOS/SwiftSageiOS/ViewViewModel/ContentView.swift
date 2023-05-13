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

struct ContentView: View {
    @State private var showSettings = false
    @State private var isLabelVisible: Bool = true
    @State private var  code: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var buttonScale: CGFloat = 1.0
   // @StateObject private var keyboardObserver = KeyboardObserver()

    @ObservedObject var settingsViewModel = SettingsViewModel.shared

    @StateObject private var windowManager = WindowManager()

    var body: some View {

        GeometryReader { geometry in
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
                WindowView(window: window)
                    .padding(SettingsViewModel.shared.cornerHandleSize)
                    .background(.clear)
                    .environmentObject(windowManager)
            }
// END WINDOW MANAGER ZONE *************************************************

            // HANDLE SIMULATOR

            if let image = settingsViewModel.receivedImage {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.leading,geometry.size.width * 0.01)
                    Spacer()
                }
            }
#endif

// START TOOL BAR / COMMAND BAR ZONE ***************************************************************************
            VStack {
                Spacer()
                CommandButtonView(settingsViewModel: settingsViewModel)
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
                        settingsViewModel.receivedImage = nil
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
//                    }
//                    // PING BUTTON
//                    Button(action: {
//                        if screamer.websocket != nil {
//                            screamer.websocket.write(ping: Data())
//                        }
//#if !os(macOS)
                    //                        consoleManager.print("ping...")
//#endif
//                        print("ping...")
//                    }) {
//
//                        resizableButtonImage(systemName: "shippingbox.and.arrow.backward", size: geometry.size)
//                    }

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
                            .font(.body)
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
            .background(

                ZStack {
#if !os(macOS)

                    AddView(showAddView: $settingsViewModel.showAddView, settingsViewModel: settingsViewModel, currentRoot: nil)
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
        .background {
            ZStack {
                settingsViewModel.backgroundColor
                    .ignoresSafeArea()
                Text("Force quit and reboot app if you encounter issues, OK?\nFresh install if its bad")
                    .zIndex(1)
                    .font(.body)
                    .foregroundColor(settingsViewModel.appTextColor)
                    .ignoresSafeArea()
            }
        }
// END TOOL BAR / COMMAND BAR ZONE ***************************************************************************

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
struct CustomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        return path
    }
}
