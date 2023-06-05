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
    @State private var isInputViewShown = false
    @State var showInstructions: Bool = !hasSeenInstructions()
    @State var showHelp: Bool = false

    @State var viewSize: CGRect = .zero

#if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @ObservedObject var keyboardResponder = KeyboardResponder()

#endif
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
#if !os(macOS)
                if isDrawerOpen {
                    DrawerContent(settingsViewModel: settingsViewModel, windowManager: windowManager, isDrawerOpen: $isDrawerOpen, conversations: $settingsViewModel.conversations, isPortrait: $isPortrait, viewSize: $viewSize)
                        .transition(.move(edge: .leading))
                        .background(settingsViewModel.buttonColor)
                        .padding(.leading, 0)
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


                                Button(action: {
                                    openiTerm2()
                                }) {
                                    Text("Open iTerm2")
                                }

                                Button(action: {
                                    openTerminalAndRunCommand(command: "echo 'Hello, Terminal!'")

                                }) {
                                    Text("Open Terminal.app and run cmd.")
                                }
                            }
#endif
                        }
                        // END MAC OS SPECIFIC PANE FOR OPENING TERMINALS AND POTENTIALLY MORE. *********************
                    }
#if !os(macOS)
                    // START WINDOW MANAGER ZONE *************************************************
                    ForEach(windowManager.windows) { window in
                        WindowView(window: window, frame: window.convoId != nil ? defChatSize : defSize, settingsViewModel: settingsViewModel, windowManager: windowManager, viewModel: SageMultiViewModel(settingsViewModel: settingsViewModel, windowInfo: window), parentViewSize: $viewSize)
                            .padding(SettingsViewModel.shared.cornerHandleSize)
                            .edgesIgnoringSafeArea(.all)
                            .background(.clear)
                            .allowsHitTesting(!isDrawerOpen)
                    }
                    // END WINDOW MANAGER ZONE *************************************************
#endif
                    // START CPNVERSATION HAMBURGER ZONE *************************************************
                    if !isDrawerOpen {
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
                        .zIndex(-9)
                        .padding(8)
                    }
                    // END CPNVERSATION HAMBURGER ZONE *************************************************

                    if !isDrawerOpen && keyboardResponder.currentHeight == 0 {
                        // START TOOL BAR / COMMAND BAR ZONE ***************************************************************************
                        VStack {
                            Spacer()
                            CommandButtonView(settingsViewModel: settingsViewModel, windowManager: windowManager, isInputViewShown: $isInputViewShown)
                        }
                        .zIndex(-9)

                        .padding(.horizontal)
                        .padding(.vertical)

                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .animation(.easeIn(duration:0.25), value: !isDrawerOpen && keyboardResponder.currentHeight == 0)

                    }
                    
                    VStack {
                        Spacer()
                        if !isDrawerOpen && keyboardResponder.currentHeight == 0 {

                            HStack(alignment: .bottom, spacing: 0) {
                                // OPEN TERM BUTTON

                                Button(action: {
#if !os(macOS)
                                    hideKeyboard()

                                    // TODO : SHOw / h9de terminal / server chat.

                                    if showSettings {
                                        showSettings = false
                                    }
                                    if showAddView  {
                                        showAddView = false
                                    }

                                    settingsViewModel.latestWindowManager = windowManager

                                    settingsViewModel.createAndOpenServerChat()
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
                                    }
                                }) {
                                    resizableButtonImage(systemName: "gearshape", size: geometry.size)
                                }

                                // ADD VIEW BUTTON
                                Button(action: {
#if !os(macOS)
                                    hideKeyboard()
#endif
                                    // TODO : SHOw / h9de terminal / server chat.

                                    showAddView.toggle()
                                    if showSettings {
                                        showSettings = false
                                    }
                                }) {

                                    resizableButtonImage(systemName: "plus.rectangle", size: geometry.size)
                                }

                                if settingsViewModel.hasAcceptedMicrophone {
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
                                }
                                Spacer()
                            }
                            .zIndex(-9)
                            .animation(.easeIn(duration:0.25), value: !isDrawerOpen && keyboardResponder.currentHeight == 0)

                        }
                    }
                    .padding(.leading,8)
                    .padding(.bottom,8)
#if !os(macOS)
                    .onAppear {
                        recalculateWindowSize(size: geometry.size)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                        recalculateWindowSize(size: geometry.size)
                    }
                    .onChange(of: geometry.size) { size in
                        recalculateWindowSize(size: geometry.size)
                        //                        logD("contentView viewSize update = \(viewSize)")
                    }
                    .onChange(of: horizontalSizeClass) { newSizeClass in
                        print("Size class changed to \(String(describing: newSizeClass))")
                        recalculateWindowSize(size: geometry.size)
                    }
                    .onChange(of: verticalSizeClass) { newSizeClass in
                        print("Size class changed to \(String(describing: newSizeClass))")
                        recalculateWindowSize(size: geometry.size)
                    }
#endif
 //                   .offset(y: showSettings ||  showAddView ? 0 :  -keyboardResponder.currentHeight)

                    .background(
                        ZStack {
#if !os(macOS)
                            AddView(showAddView: $showAddView, settingsViewModel: settingsViewModel, windowManager: windowManager, isInputViewShown: $isInputViewShown)
                                .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width, minHeight: 0, maxHeight: .infinity)
                                .opacity(showAddView ? 1.0 : 0.0)

                            SettingsView(showSettings: $showSettings, showHelp: $showHelp, showInstructions: $showInstructions, settingsViewModel: settingsViewModel)
                                .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width, minHeight: 0, maxHeight: .infinity)
                                .opacity(showSettings ? 1.0 : 0.0)
#endif
                        }
                            .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width , minHeight: 0, maxHeight: .infinity)
                    )
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                }
                .overlay(
                    Group {
                        if showInstructions {
                            InstructionsPopup(isPresented: $showInstructions ,settingsViewModel: settingsViewModel )
                        }
                        else if showHelp {
                            HelpPopup(isPresented: $showHelp ,settingsViewModel: settingsViewModel )
                        }
                    }
                )
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

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
                        // TODO: Make this way better.
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
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

                    .edgesIgnoringSafeArea(.all)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .if(isDrawerOpen) { view in
                    view.onTapGesture {
                        if isDrawerOpen {  withAnimation { isDrawerOpen = false } }
                    }
                }
            }
        }
    }
    // END CONTENTVIEW BACKGROUND ZONE ***************************************************************************

    private func recalculateWindowSize(size: CGSize) {
        DispatchQueue.main.async {

#if !os(macOS)
            defSize = CGRectMake(0, 0, size.width - (size.width * 0.32), size.height - (size.height * 0.5))
            defChatSize = CGRectMake(0, 0, size.width - (size.width * 0.32), size.height - (size.height * 0.52))

            // set parentViewSize
            viewSize = CGRectMake(0, 0, size.width, size.height)
            logD("contentView viewSize update = \(viewSize)")

            guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
            self.isPortrait = scene.interfaceOrientation.isPortrait

#endif
        }
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
