//
//  LogicSageApp.swift
//  LogicSage
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
struct LogicSageApp: App {

    @StateObject var appModel = AppModel()

    @StateObject private var settingsViewModel = SettingsViewModel.shared

#if os(xrOS)
    @State var immersionState: ImmersionStyle = .mixed
#endif

    init() {
        serviceDiscovery = ServiceDiscovery()
        
//#if targetEnvironment(macCatalyst)
//        // start up websocket server
//        Task {
//            do {
//                try await ServerEntrypoint.main()
//            }
//            catch {
//                print("LogicSage server error = \(error)")
//            }
//        }
//#endif
    }
    var body: some Scene {
        WindowGroup("LogicSage", id: "LogicSage-main") {
            ContentView(settingsViewModel: settingsViewModel)
                .environmentObject(appModel)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.666) {

                        serviceDiscovery?.startDiscovering()
                    }
                    DispatchQueue.main.async {
                        settingsViewModel.printVoicesInMyDevice()
                        settingsViewModel.configureAudioSession()
                    }
//#if targetEnvironment(macCatalyst)
//                    Task {
//                        
//                        Backend.doBackend(path: "~/LogicSage/")
//                        
//                        appModel.isServerActive = true
//                    }
//#endif
                }
#if !os(macOS)
#if !os(xrOS)
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
#if !os(xrOS)
                .preferredColorScheme(.dark)
#endif
        }

#if os(xrOS)
                .windowStyle(.plain)
#endif
#if os(xrOS)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(immersionMode: .immersive)
                .environmentObject(appModel)

        }
        .immersionStyle(selection: $immersionState, in: .mixed)

        WindowGroup(id: "ImmersiveSpaceVolume") {
            ImmersiveView(immersionMode: .volumetric)
                .environmentObject(appModel)

        }
        .windowStyle(.volumetric)
        .defaultSize(width: 2, height: 2.6, depth: 2.6, in: .meters)


        WindowGroup(id: "LogoVolume") {
            ImmersiveLogoView()
                .environmentObject(appModel)

        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.6, height: 1.6, depth: 1.6, in: .meters)
#endif
    }
}

class Backend {
    static func doBackend(path: String) {
#if targetEnvironment(macCatalyst)
        // The LogicSage for Mac app handles starting the server and MacOS Binary.
        Task {
                PluginLoader.loadPlugin(path: path)
        }
#endif
    }
}
