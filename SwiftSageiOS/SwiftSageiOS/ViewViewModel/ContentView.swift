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
    @State private var tabSelection = 1

    @State private var showAddView = false
    @State private var showSettings = false

    @ObservedObject var settingsViewModel: SettingsViewModel = SettingsViewModel()
    @StateObject var windowManager = WindowManager()

#if !os(macOS)
#if !os(xrOS)
    @State private var isPortrait = UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown
#endif
#endif
    @State private var isInputViewShown = false
    @State var showInstructions: Bool = !hasSeenInstructions()
    @State var showHelp: Bool = false
    @State var viewSize: CGRect = .zero

#if !os(macOS)
#if !os(xrOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @ObservedObject var keyboardResponder = KeyboardResponder()
    @State var keyboardHeight: CGFloat = 0
#endif
#endif
#if !os(macOS)

    let appearance: UITabBarAppearance = UITabBarAppearance()
    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
    }
#endif
    var body: some View {
        GeometryReader { geometry in

            TabView(selection: $tabSelection) {
                // Start of ZStack 0
                ZStack {
#if !os(macOS)
#if !os(xrOS)
                    DrawerContent(settingsViewModel: settingsViewModel, windowManager: windowManager, conversations: $settingsViewModel.conversations, isPortrait: $isPortrait, viewSize: $viewSize, showSettings: $showSettings, showAddView: $showAddView, tabSelection: $tabSelection)
                        .transition(.move(edge: .leading))
                        .background(settingsViewModel.buttonColor)
                        .padding(.leading, 0)
                        .zIndex(999)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
#endif
#endif
                }
                .tabItem {
                    Label("Chats", systemImage: "text.bubble.fill")
                        .accentColor(settingsViewModel.buttonColor)
                }
                .tag(0)
                // End of ZStack 0

                // Start of ZStack 1
                ZStack {
                    ZStack {
#if !os(macOS)
#if !os(xrOS)
                        // START WINDOW MANAGER ZONE *************************************************
                        ForEach(windowManager.windowViewModels  ) { windowViewModel in

                            WindowView(window: windowViewModel.windowInfo, settingsViewModel: settingsViewModel, windowManager: windowManager, viewModel: windowViewModel, parentViewSize: $viewSize, keyboardHeight: $keyboardHeight)
                                .padding(.top, 20)
                                .padding(.bottom, 0)

                        }
                        // END WINDOW MANAGER ZONE *************************************************
#endif
#endif
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
                        .simultaneousGesture(TapGesture().onEnded {
                            withAnimation {
#if !os(macOS)
                                hideKeyboard()
#endif
                            }
                        })
                        .zIndex(-999)
#if !os(macOS)
#if !os(xrOS)
                        if keyboardResponder.currentHeight == 0 {
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
                            .animation(.easeIn(duration:0.25), value:keyboardResponder.currentHeight == 0)
                        }
#endif
#endif
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .overlay(
                        Group {
#if !os(xrOS)
#if !os(macOS)
                            if showInstructions {
                                InstructionsPopup(isPresented: $showInstructions ,settingsViewModel: settingsViewModel )
                            }
                            else if showHelp {
                                HelpPopup(isPresented: $showHelp ,settingsViewModel: settingsViewModel )
                            }
#endif
#endif
                        }
                            .zIndex(998)
                    )
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    // END TOOL BAR / COMMAND BAR ZONE ***************************************************************************

                    // BEGIN CONTENTVIEW BACKGROUND ZONE ***************************************************************************

                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
#if !os(macOS)
                    .onAppear {
                        recalculateWindowSize(size: geometry.size)
                    }

                    .onChange(of: geometry.size) { size in
                        recalculateWindowSize(size: geometry.size)
                        //logD("contentView viewSize update = \(viewSize)")
                    }
#if !os(xrOS)
                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                        recalculateWindowSize(size: geometry.size)
                    }
                    .onChange(of: horizontalSizeClass) { newSizeClass in
                        print("Size class changed to \(String(describing: newSizeClass))")
                        recalculateWindowSize(size: geometry.size)
                    }
                    .onChange(of: verticalSizeClass) { newSizeClass in
                        print("Size class changed to \(String(describing: newSizeClass))")
                        recalculateWindowSize(size: geometry.size)
                    }
                    .onChange(of: keyboardResponder.currentHeight) { newKeyHeight in
                        keyboardHeight = newKeyHeight > 0 ? newKeyHeight + geometry.size.height * 0.15 : 0

                    }
#endif
#endif
                }
                .tabItem {
                    Label("Windows", systemImage: "macwindow.on.rectangle")
                        .accentColor(settingsViewModel.buttonColor)
                }
                .tag(1)
// END OF ZSTACK 1

// Start of ZStack 2
                ZStack {
#if !os(macOS)
#if !os(xrOS)
                    VStack {
                        SettingsView(showSettings: $showSettings, showHelp: $showHelp, showInstructions: $showInstructions, settingsViewModel: settingsViewModel, tabSelection: $tabSelection)
                            .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width, minHeight: 0, maxHeight: .infinity)
                            .zIndex(997)
                    }
#endif
#endif
                }
                .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width , minHeight: 0, maxHeight: .infinity)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                        .accentColor(settingsViewModel.buttonColor)
                }
                .tag(2)
// End of ZStack 2

// Start of ZStack 3
                ZStack {
#if !os(macOS)
#if !os(xrOS)
                    VStack {
                        AddView(showAddView: $showAddView, settingsViewModel: settingsViewModel, windowManager: windowManager, isInputViewShown: $isInputViewShown, tabSelection: $tabSelection)
                            .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width, minHeight: 0, maxHeight: .infinity)
                            .zIndex(997)
                    }
#endif
#endif
                }
                .frame(minWidth: geometry.size.width, maxWidth: geometry.size.width , minHeight: 0, maxHeight: .infinity)
                .tabItem {
                    Label("Add", systemImage: "plus.rectangle")
                        .accentColor(settingsViewModel.buttonColor)
                }
                .tag(3)
// End of ZStack 3

            }
            .padding(1)
        }
    }

    // END CONTENTVIEW BACKGROUND ZONE ***************************************************************************

    private func recalculateWindowSize(size: CGSize) {
#if !os(macOS)
        if viewSize.size != size {
            if UIDevice.current.userInterfaceIdiom == .phone {
                // iOS
                defSize = CGRectMake(0, 0, size.width - (size.width * 0.1), size.height - (size.height * 0.2))
                defChatSize = CGRectMake(0, 0, size.width - (size.width * 0.1), size.height - (size.height * 0.2))
            }
            else {
                defSize = CGRectMake(0, 0, size.width - (size.width * 0.32), size.height - (size.height * 0.33))
                defChatSize = CGRectMake(0, 0, size.width - (size.width * 0.32), size.height - (size.height * 0.33))
            }
            // set parentViewSize
            viewSize = CGRectMake(0, 0, size.width, size.height)
            //logD("contentView viewSize update = \(viewSize)")

            guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
#if !os(xrOS)
            self.isPortrait = scene.interfaceOrientation.isPortrait
#endif
        }
#endif
    }
    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        if #available(iOS 16.0, *) {
            return  Image(systemName: systemName)
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
    }
}
