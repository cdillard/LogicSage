//
//  SwiftSageiOSApp.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/23/23.
//████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
// █░░░░░░█████████░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█
// █░░▄▀░░█████████░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█
// █░░▄▀░░█████████░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█░░░░▄▀░░░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░░░█
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░███████████░░▄▀░░███░░▄▀░░█████████░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░█████████░░▄▀░░█████████
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░███████████░░▄▀░░███░░▄▀░░█████████░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░█████████░░▄▀░░░░░░░░░░█
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░██░░░░░░███░░▄▀░░███░░▄▀░░█████████░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░░░░░█░░▄▀▄▀▄▀▄▀▄▀░░█
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░█████████░░░░░░░░░░▄▀░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░░░░░█
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░█████████████████░░▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀░░█████████
// █░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░▄▀░░█░░░░▄▀░░░░█░░▄▀░░░░░░░░░░█░░░░░░░░░░▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█
// █░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█
//
//
//

import SwiftUI
import Combine

// TODO MAKE SURE ITS OKAY TO UP THIS SO MUCH
let STRING_LIMIT = 150000

// TODO BEFORE RELEASE: PROD BUNDLE ID
// TODO USE BUILT IN BundleID var.
let bundleID = "com.chrisdillard.SwiftSage"

var serviceDiscovery: ServiceDiscovery?

@main
struct SwiftSageiOSApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel.shared
    @StateObject private var appState = AppState()
    @State private var isDrawerOpen = false

    init() {
        serviceDiscovery = ServiceDiscovery()
    }
    var body: some Scene {
        WindowGroup {
            ZStack {
                HStack(spacing: 0) {
                    if self.isDrawerOpen {
                        DrawerContent(settingsViewModel: settingsViewModel, isDrawerOpen: $isDrawerOpen, conversations: $settingsViewModel.conversations)
                            .environmentObject(appState)
                            .environmentObject(WindowManager.shared)
                            .transition(.move(edge: .leading))
                            .background(settingsViewModel.buttonColor)
                            .frame(minWidth: drawerWidth, maxWidth: drawerWidth, minHeight: 0, maxHeight: .infinity)
                    }

                    ContentView(settingsViewModel: settingsViewModel, isDrawerOpen: $isDrawerOpen)
                        .environmentObject(appState)

                    Spacer() 
                }
                .overlay(
                    Group {
                        if settingsViewModel.showInstructions {
                            InstructionsPopup(isPresented: $settingsViewModel.showInstructions ,settingsViewModel: settingsViewModel )
                        }
                    }
                )
                .onAppear {
                    doDiscover()
#if !os(macOS)
                    consoleManager.fontSize = settingsViewModel.textSize
#endif
                    DispatchQueue.main.async {
                        settingsViewModel.printVoicesInMyDevice()
                        settingsViewModel.configureAudioSession()
                    }

                }
#if !os(macOS)

                //                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification)) { _ in
                //                        print("didFinishLaunchingNotification")
                //                        SwiftSageiOSAppDelegate.applicationDidFinishLaunching()
                //                    }
                //                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                //                        print("applicationDidBecomeActive")
                //                    }
                //                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                //                        print("applicationWillEnterForeground")
                //                    }
                //                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                //                        print("didEnterBackgroundNotification")
                //                        SwiftSageiOSAppDelegate.applicationDidEnterBackground()
                //                    }
#endif
            }

        }
    }
    func doDiscover() {
        serviceDiscovery?.startDiscovering()
    }
}
func setHasSeenInstructions(_ hasSeen: Bool) {
    UserDefaults.standard.set(hasSeen, forKey: "hasSeenInstructions")
}
func hasSeenInstructions() -> Bool {
    return UserDefaults.standard.bool(forKey: "hasSeenInstructions")
}
class AppState: ObservableObject {
    @Published var isInBackground: Bool = false
    private var cancellables: [AnyCancellable] = []

    init() {
#if !os(macOS)

        //        let didEnterBackground = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
        //            .map { _ in true }
        //            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        //            .removeDuplicates()
        //
        //        let willEnterForeground = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
        //            .map { _ in false }
        //            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        //            .removeDuplicates()
        //
        //        didEnterBackground
        //            .merge(with: willEnterForeground)
        //            .sink { [weak self] in
        //                self?.isInBackground = $0
        //                DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
        //                        serviceDiscovery?.startDiscovering()
        //                }
        //            }
        //            .store(in: &cancellables)
#endif
    }
}
