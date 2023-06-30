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

#if !os(macOS)
import UIKit
#endif

var serviceDiscovery: ServiceDiscovery?

@main
struct SwiftSageiOSApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel.shared
#if !os(macOS)
#if !os(xrOS)
    @State private var isPortrait = UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown
#endif
#endif
    init() {
        serviceDiscovery = ServiceDiscovery()
    }
    var body: some Scene {
        WindowGroup(id: "LogicSage-main") {
            ContentView(settingsViewModel: settingsViewModel)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.666) {
                        serviceDiscovery?.startDiscovering()
                    }
                    DispatchQueue.main.async {
#if !os(macOS)
#if !os(xrOS)
                        isPortrait = UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown
#endif
#endif
                        settingsViewModel.printVoicesInMyDevice()
                        settingsViewModel.configureAudioSession()
                    }
                }
#if !os(macOS)
#if !os(xrOS)
                .onAppear {
                    guard let scene = UIApplication.shared.windows.first?.windowScene else { return }

                    self.isPortrait = scene.interfaceOrientation.isPortrait
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
                    self.isPortrait = scene.interfaceOrientation.isPortrait
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification)) { _ in
                    logD("didFinishLaunchingNotification")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    logD("applicationWillEnterForeground")

                    screamer.discoReconnect()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    logD("didEnterBackgroundNotification")
                }
#endif
#endif
        }
#if os(xrOS)
        //        .windowStyle(.plain)
#endif
    }
}

func setHasSeenInstructions(_ hasSeen: Bool) {
    UserDefaults.standard.set(hasSeen, forKey: "hasSeenInstructions")
}
func hasSeenInstructions() -> Bool {
    return UserDefaults.standard.bool(forKey: "hasSeenInstructions")
}
func setHasSeenLogo(_ hasSeen: Bool) {
    UserDefaults.standard.set(hasSeen, forKey: "hasSeenLogo")
}
func hasSeenLogo() -> Bool {
    return UserDefaults.standard.bool(forKey: "hasSeenLogo")
}
func hasSeenAnim() -> Bool {
    return UserDefaults.standard.bool(forKey: "hasSeenAnim")
}
func setHasSeenAnim(_ hasSeen: Bool) {
    UserDefaults.standard.set(hasSeen, forKey: "hasSeenAnim")
}

