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
    @State private var isDrawerOpen = false

    @State private var showAddView = false
    @State private var showSettings = false
    @State private var  code: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var buttonScale: CGFloat = 1.0
    @ObservedObject var settingsViewModel: SettingsViewModel = SettingsViewModel()

    @StateObject var windowManager = WindowManager()

#if !os(macOS)

    @State private var isPortrait = UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown
#endif

#if !os(macOS)

    @ObservedObject private var keyboardResponder = KeyboardResponder()
#endif

    @State private var isInputViewShown = false

    var body: some View {

        GeometryReader { geometry in
            HStack(spacing:0) {
#if !os(macOS)
                if isDrawerOpen {
                    DrawerContent(settingsViewModel: settingsViewModel, windowManager: windowManager, isDrawerOpen: $isDrawerOpen, conversations: $settingsViewModel.conversations, isPortrait: $isPortrait)
                        .environmentObject(windowManager)
                        .transition(.move(edge: .leading))
                        .background(settingsViewModel.buttonColor)
                        .frame(minWidth: isPortrait ? drawerWidth : drawerWidthLandscape, maxWidth: isPortrait ? drawerWidth : drawerWidthLandscape, minHeight: 0, maxHeight: .infinity)
                }
#endif
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
    //#if !os(macOS)
    //                .padding(.bottom,
    //                          keyboardResponder.currentHeight > 0 ?
    //                         keyboardResponder.currentHeight + geometry.size.height * 0.25 :
    //                            0
    //                )
    //#endif
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
                                    .frame(width: UIScreen.main.bounds.width / 15, height: 27.666 )
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

                    if !isDrawerOpen {
                        // START TOOL BAR / COMMAND BAR ZONE ***************************************************************************
                        VStack {
                            Spacer()
                            CommandButtonView(settingsViewModel: settingsViewModel, isInputViewShown: $isInputViewShown)
                                .environmentObject(windowManager)
                        }
                        .padding(.horizontal)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                    }
                    
                    VStack {
                        Spacer()
                        if !isDrawerOpen {

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
                                    if showAddView  {
                                        showAddView = false
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
                                    showAddView.toggle()
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
                    }
                    .padding(.leading,8)
                    .padding(.bottom,8)
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
                            AddView(showAddView: $showAddView, settingsViewModel: settingsViewModel, isInputViewShown: $isInputViewShown)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .opacity(showAddView ? 1.0 : 0.0)
                                .environmentObject(windowManager)
                            SettingsView(showSettings: $showSettings, settingsViewModel: settingsViewModel)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .opacity(showSettings ? 1.0 : 0.0)
    #endif
                        }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    )
    #if !os(macOS)
                    .onAppear {
                        guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
                        self.isPortrait = scene.interfaceOrientation.isPortrait
                    }

                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                        guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
                        self.isPortrait = scene.interfaceOrientation.isPortrait
                    }
    #endif
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
                        if let image = settingsViewModel.actualReceivedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .ignoresSafeArea()
                                .animation(.easeIn(duration: 0.28), value: image)
                        }
                        else {
                            settingsViewModel.backgroundColor
                                .ignoresSafeArea()
                        }
                        if settingsViewModel.initalAnim {
                            LoadingLogicView()
                                .frame( maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                        }
    #else
                        settingsViewModel.backgroundColor
                            .ignoresSafeArea()
    #endif
                    }

                    .edgesIgnoringSafeArea(.all)

                }
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
