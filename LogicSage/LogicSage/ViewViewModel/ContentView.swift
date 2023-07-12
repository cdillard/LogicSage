//
//  ContentView.swift
//  LogicSage
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
    @State private var isInputViewShown = false
    @State var showInstructions: Bool = !hasSeenInstructions()
    @State var showHelp: Bool = false
    @State var viewSize: CGRect = .zero

    @EnvironmentObject var appModel: AppModel

#if os(xrOS)

    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
#endif

#if !os(macOS)
#if !os(xrOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
#if !os(tvOS)

    @ObservedObject var keyboardResponder = KeyboardResponder()
#endif
#endif
#endif
    @State var keyboardHeight: CGFloat = 0
    @State var dragCursorPoint: CGPoint = .zero

#if !os(macOS)
    let appearance: UITabBarAppearance = UITabBarAppearance()
    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
#endif
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $tabSelection) {
                tabZero(size: geometry.size)
                tabOne(size: geometry.size)
                tabTwo(size: geometry.size)
                tabThree(size: geometry.size)
                tabFour(size: geometry.size)
            }
            .padding(1)
#if os(xrOS)
            .glassBackgroundEffect()
#endif
        }
    }
    func tabZero(size: CGSize) -> some View {
        ZStack {
            DrawerContent(settingsViewModel: settingsViewModel, windowManager: windowManager, conversations: $settingsViewModel.conversations, viewSize: $viewSize, showSettings: $showSettings, showAddView: $showAddView, tabSelection: $tabSelection)
                .transition(.move(edge: .leading))
                .background(settingsViewModel.buttonColor)
                .padding(.leading, 0)
                .zIndex(999)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .tabItem {
            Label("Chats", systemImage: "text.bubble.fill")
                .accentColor(settingsViewModel.buttonColor)
        }
        .tag(0)
    }
    func tabOne(size: CGSize) -> some View {
        ZStack {
            ZStack {
                // START WINDOW MANAGER ZONE *************************************************
                ForEach(windowManager.windowViewModels  ) { windowViewModel in

                    WindowView(window: windowViewModel.windowInfo, settingsViewModel: settingsViewModel, windowManager: windowManager, viewModel: windowViewModel, parentViewSize: $viewSize, keyboardHeight: $keyboardHeight, dragCursorPoint: $dragCursorPoint)
                        .padding(.top, 20)
                        .padding(.bottom, 0)
                }
                // END WINDOW MANAGER ZONE *************************************************
                ZStack {
#if os(macOS)
                    settingsViewModel.backgroundColor
                        .edgesIgnoringSafeArea(.all)
#else
                    settingsViewModel.backgroundColor
                        .edgesIgnoringSafeArea(.all)
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

                    if  settingsViewModel.initalAnim {
                        LoadingLogicView()
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                            .onAppear {
                                setHasSeenAnim(true)
                            }
                    }
                    else {
                        Text(logoAscii6)
                            .minimumScaleFactor(0.6)
#if !os(macOS)
                            .font(Font(UIFont(name: "Menlo", size: 18)!))
#endif
                            .foregroundColor(randomColor)
                    }
#endif
                }
                .overlay(
                    Group {
                        if showInstructions {
                            InstructionsPopup(isPresented: $showInstructions ,settingsViewModel: settingsViewModel )
                        }
                    }
                        .zIndex(998)
                )
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
                if keyboardHeight == 0 && !showInstructions {
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
                    .animation(.easeIn(duration:0.25), value:keyboardHeight == 0)
                }
#if !os(macOS)
#if !os(tvOS)
                // Handle dragging point for resize gesture.
                if dragCursorPoint != .zero {
                    BezierShape(bezierPath: Beziers.createTopLeft())
                        .fill(Color.white.opacity(0.5))
                        .offset(x: dragCursorPoint.x, y: dragCursorPoint.y)
                        .allowsTightening(false)
                }
#endif
#endif
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            // END TOOL BAR / COMMAND BAR ZONE ***************************************************************************

            // BEGIN CONTENTVIEW BACKGROUND ZONE ***************************************************************************
#if !os(macOS)
            .onAppear {
                recalculateWindowSize(size: size)
            }
            .onChange(of: size) { size in
                recalculateWindowSize(size: size)
            }
#if !os(xrOS)
#if !os(tvOS)
            .onChange(of: keyboardResponder.currentHeight) { newKeyHeight in
                keyboardHeight = newKeyHeight > 0 ? newKeyHeight - 33 : 0

                if keyboardHeight > 0 {
                    // move all windows to y:10
                    for smvm in windowManager.windowViewModels {
                        var topYBound: CGFloat = 10

                        if smvm.resizeOffset.height < 0 {
                            topYBound = 10 - abs(smvm.resizeOffset.height / 2)
                        }
                        else if smvm.resizeOffset.height > 0 {
                            topYBound = 10 + (smvm.resizeOffset.height / 2)
                        }

                        smvm.position = CGSizeMake(smvm.position.width, topYBound)
                    }
                }
            }
#endif
#endif
#endif
        }
        .tabItem {
            Label("Windows", systemImage: "macwindow.on.rectangle")
                .accentColor(settingsViewModel.buttonColor)
        }
        .tag(1)
    }
    func tabTwo(size: CGSize) -> some View {
        ZStack {
            VStack {
                SettingsView(showSettings: $showSettings, showHelp: $showHelp, showInstructions: $showInstructions, settingsViewModel: settingsViewModel, tabSelection: $tabSelection)
                    .frame(minWidth: size.width, maxWidth: size.width, minHeight: 0, maxHeight: .infinity)
                    .zIndex(997)
            }
        }
        .overlay(
            Group {
                if showInstructions {
                    InstructionsPopup(isPresented: $showInstructions ,settingsViewModel: settingsViewModel )
                }
            }
                .zIndex(998)
        )
        .frame(minWidth: size.width, maxWidth: size.width , minHeight: 0, maxHeight: .infinity)
        .tabItem {
            Label("Settings", systemImage: "gearshape")
                .accentColor(settingsViewModel.buttonColor)
        }
        .tag(2)
    }
    func tabThree(size: CGSize) -> some View {
        ZStack {
            VStack {
                AddView(showAddView: $showAddView, settingsViewModel: settingsViewModel, windowManager: windowManager, isInputViewShown: $isInputViewShown, tabSelection: $tabSelection)
                    .frame(minWidth: size.width, maxWidth: size.width, minHeight: 0, maxHeight: .infinity)
                    .zIndex(997)
            }
        }
        .frame(minWidth: size.width, maxWidth: size.width , minHeight: 0, maxHeight: .infinity)
        .tabItem {
            Label("Add", systemImage: "plus.rectangle")
                .accentColor(settingsViewModel.buttonColor)
        }
        .tag(3)
    }

    func tabFour(size: CGSize) -> some View {
        ZStack {
            VStack {
                AudioView( settingsViewModel: settingsViewModel, windowManager: windowManager, isInputViewShown: $isInputViewShown, tabSelection: $tabSelection)
                    .frame(minWidth: size.width, maxWidth: size.width, minHeight: 0, maxHeight: .infinity)
                    .zIndex(997)
            }
        }
        .frame(minWidth: size.width, maxWidth: size.width , minHeight: 0, maxHeight: .infinity)
        .tabItem {
            Label("Audio", systemImage: "headphones")
                .accentColor(settingsViewModel.buttonColor)
        }
        .tag(4)
    }
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
            if gestureDebugLogs {
                logD("contentView viewSize update = \(viewSize)")
            }
        }
#endif
    }
}

