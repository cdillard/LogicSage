//
//  LogicSageApp.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/23/23.
// ████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
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
struct LogicSageApp: App {

    @StateObject var appModel = AppModel()

    @StateObject private var settingsViewModel = SettingsViewModel.shared

#if os(visionOS)
    @State var immersionState: ImmersionStyle = .mixed
    //let defaultSize = Size3D(width: 1.0 * 3, height: 1.0 * 2, depth: 1.0)
    let defaultSize = Size3D(width: 1.0 * 1.75, height: 1.0 * 1.75, depth: 1.0)

#endif


    init() {
        serviceDiscovery = ServiceDiscovery()

    }
    var body: some Scene {
        WindowGroup( id: "LogicSage-main") {
            ContentView()
                .environmentObject(appModel)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.666) {

                        serviceDiscovery?.startDiscovering()
                    }
                    Task {
                        settingsViewModel.printVoicesInMyDevice()
                        settingsViewModel.configureAudioSession()
                    }

                }
                .environmentObject(settingsViewModel)
#if !os(macOS)
#if !os(visionOS)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification)) { _ in
                    //logD("didFinishLaunchingNotification")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                   // logD("applicationWillEnterForeground")

                    screamer.discoReconnect()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                   // logD("didEnterBackgroundNotification")
                }
#endif
#endif
#if !os(visionOS)
                .preferredColorScheme(.dark)
#endif
        }

#if os(visionOS)
        .windowStyle(.plain)
#endif
#if os(visionOS)
        WindowGroup( id: "LogicSage-newWindow") {
            NewWindowContentView()
                .environmentObject(appModel)
                .environmentObject(settingsViewModel)
        }

        WindowGroup(id: "LogoVolume") {
            ImmersiveLogoView(defaultSize: defaultSize, settingsViewModel: settingsViewModel)
                .environmentObject(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(defaultSize, in: .meters)


        WindowGroup(id: "SphereVolume") {
            SphereVolumeContentView(defaultSize: defaultSize)
                            .environmentObject(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(defaultSize, in: .meters)
#endif
    }
}
