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
            ZStack {
#if !os(macOS)
                if isDrawerOpen {
                    let drawerWidth = viewSize.width - (viewSize.width / (UIDevice.current.userInterfaceIdiom == .phone ? 3 : 3))
                    DrawerContent(settingsViewModel: settingsViewModel, windowManager: windowManager, isDrawerOpen: $isDrawerOpen, conversations: $settingsViewModel.conversations, isPortrait: $isPortrait, viewSize: $viewSize, showSettings: $showSettings, showAddView: $showAddView)
                        .transition(.move(edge: .leading))
                        .background(settingsViewModel.buttonColor)
                        .padding(.leading, 0)
                        .zIndex(999)
                        .frame(minWidth: drawerWidth, maxWidth: drawerWidth, minHeight: 0, maxHeight: .infinity)
                }
#endif
                ZStack {
#if !os(macOS)
                    if !isDrawerOpen {
                        // START WINDOW MANAGER ZONE *************************************************
                        ForEach(windowManager.windowViewModels  ) { windowViewModel in

                            WindowView(window: windowViewModel.windowInfo, settingsViewModel: settingsViewModel, windowManager: windowManager, viewModel: windowViewModel, parentViewSize: $viewSize)
                            //                            .edgesIgnoringSafeArea(.all)
                                .background(.clear)
                                .opacity(isDrawerOpen ? 0.0 : 1.0)
                                .allowsHitTesting(!isDrawerOpen)
                                .padding(.top, 20)
                        }
                    }
                    // END WINDOW MANAGER ZONE *************************************************
#endif
                    // START CONVERSATION HAMBURGER ZONE *************************************************
                    if !isDrawerOpen {
                        VStack {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        showAddView = false
                                        showSettings = false
                                        showHelp = false
                                        showInstructions = false
                                        self.isDrawerOpen.toggle()
                                    }
                                }) {
                                    Image(systemName: isDrawerOpen ? "x.circle.fill" : "line.horizontal.3")
                                        .resizable()
                                        .scaledToFit()
                                        .tint(settingsViewModel.appTextColor)
                                        .padding(.leading,16)
                                        .padding(.top,16)
                                        .padding(.trailing,8)
                                        .padding(.bottom,8)
                                        .background(settingsViewModel.buttonColor.opacity(0.666))
                                        .frame(width: 40, height: 40 )
                                        .animation(.easeIn(duration:0.25), value: isDrawerOpen)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .zIndex(998)
                    }
                    // END CPNVERSATION HAMBURGER ZONE *************************************************
#if !os(macOS)
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
#endif

                    ZStack {
#if !os(macOS)
                        AddView(showAddView: $showAddView, settingsViewModel: settingsViewModel, windowManager: windowManager, isInputViewShown: $isInputViewShown)
                            .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width, minHeight: 0, maxHeight: .infinity)
                            .opacity(showAddView ? 1.0 : 0.0)
                            .zIndex(997)

                        SettingsView(showSettings: $showSettings, showHelp: $showHelp, showInstructions: $showInstructions, settingsViewModel: settingsViewModel)
                            .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width, minHeight: 0, maxHeight: .infinity)
                            .opacity(showSettings ? 1.0 : 0.0)
                            .zIndex(997)
#endif
                    }
                    .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width , minHeight: 0, maxHeight: .infinity)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .overlay(
                    Group {
                        if showInstructions {
                            InstructionsPopup(isPresented: $showInstructions ,settingsViewModel: settingsViewModel )
                        }
                        else if showHelp {
                            HelpPopup(isPresented: $showHelp ,settingsViewModel: settingsViewModel )
                        }
                    }
                    .zIndex(998)
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
                                .edgesIgnoringSafeArea(.all)
                                .animation(.easeIn(duration: 0.28), value: image)
                        }
                        else {
                            settingsViewModel.backgroundColor
                                .animation(.easeIn(duration: 0.28), value: true)

                                .edgesIgnoringSafeArea(.all)
                        }
                        // TODO: Make this way better.
                        if  settingsViewModel.initalAnim {
                            LoadingLogicView()
                                .frame( maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                                .onAppear {
                                    setHasSeenAnim(true)
                                }
                        }
#else
                        settingsViewModel.backgroundColor
                            .edgesIgnoringSafeArea(.all)
#endif
                    }
                    .frame(minWidth: viewSize.size.width, maxWidth: viewSize.size.width, minHeight: viewSize.size.height, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isDrawerOpen = false
#if !os(macOS)
                            hideKeyboard()
#endif
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .if(isDrawerOpen) { view in
                    view.onTapGesture {
                        if isDrawerOpen {  withAnimation { isDrawerOpen = false } }
                    }
                }
#if !os(macOS)
                .onAppear {
                    recalculateWindowSize(size: geometry.size)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    recalculateWindowSize(size: geometry.size)
                }
                .onChange(of: geometry.size) { size in
                    recalculateWindowSize(size: geometry.size)
                    //logD("contentView viewSize update = \(viewSize)")
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
            }
        }
    }
// END CONTENTVIEW BACKGROUND ZONE ***************************************************************************

    private func recalculateWindowSize(size: CGSize) {
#if !os(macOS)
        if viewSize.size != size {
            defSize = CGRectMake(0, 0, size.width - (size.width * 0.32), size.height - (size.height * 0.5))
            defChatSize = CGRectMake(0, 0, size.width - (size.width * 0.32), size.height - (size.height * 0.52))

            // set parentViewSize
            viewSize = CGRectMake(0, 0, size.width, size.height)
            //logD("contentView viewSize update = \(viewSize)")

            guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
            self.isPortrait = scene.interfaceOrientation.isPortrait
        }
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
