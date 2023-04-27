//
//  SwiftSageiOSApp.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/23/23.
//

import SwiftUI
import Combine
let STRING_LIMIT = 50000


@main
struct SwiftSageiOSApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var appState = AppState()
    var serviceDiscovery: ServiceDiscovery?
    init() {
        serviceDiscovery = ServiceDiscovery()
        serviceDiscovery?.startDiscovering()

#if !os(macOS)
//        if !hasSeenInstructions() {
//            print("openning console after instr")
//        }
//        else {
//            consoleManager.isVisible = true
//        }
#endif
    //    cmdWindows = [LCManager]()

//        // Alpha window
//        cmdWindows.append(LCManager())
//        // Beta
//        cmdWindows.append(LCManager())
//        // Gamma
//        cmdWindows.append(LCManager())
//        // Delta
//        cmdWindows.append(LCManager())
//        // Epsilon
//        cmdWindows.append(LCManager())
//        // Zeta
//        cmdWindows.append(LCManager())
//        // Eta
//        cmdWindows.append(LCManager())
//        // Theta
//        cmdWindows.append(LCManager())
//        //Iota
//        cmdWindows.append(LCManager())
////        Kappa
//        Lambda
//        Mu
//        Nu
//        Xi
//        Omicron
//        Pi
//        Rho
//        Sigma
//        Tau
//        Upsilon
//        Phi
//        Chi
//        Psi
//        Omega
    }
    @State private var showInstructions: Bool = !hasSeenInstructions()
    var body: some Scene {
        WindowGroup {
            ZStack {
                settingsViewModel.backgroundColor
                    .ignoresSafeArea()
                ContentView()
                    .environmentObject(settingsViewModel)
                    .environmentObject(appState)

                    .overlay(
                        Group {
                            if showInstructions {
                                InstructionsPopup(isPresented: $showInstructions ,settingsViewModel: settingsViewModel )
                            }
                        }
                    )
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

// wimdowz 95
//var cmdWindows = [LCManager]()
//var mainWindow = LCManager.shared

// Socket
let screamer = ScreamClient()
let reconnectInterval: TimeInterval = 1.0

class ScreamClient: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected, headers: \(headers)")
#if !os(macOS)

            let devType = UIDevice.current.userInterfaceIdiom == .phone ? "iOS" : "iPadOS"
            client.write(string: "Hello from \(devType) app!")
#endif
            startPingTimer()
        case .disconnected(let reason, let code):
            print("WebSocket disconnected, reason: \(reason), code: \(code)")
            stopPingTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
                print("Reconnecting...")
                self.connect()
            }
        case .text(let text):
#if !os(macOS)

            consoleManager.print(text)
#endif
        case .binary(let data):
#if !os(macOS)

            print("Received binary data: \(data)")
            if let receivedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    SettingsViewModel.shared.receivedImage = receivedImage
                }
            }
            // parse audio chunks
            else {
                print("fail parse is it audio????")
            }
#endif
        case .ping:
            print("websocket received ping")
#if !os(macOS)

            consoleManager.print("websocket received ping")
#endif
        case .pong:
            print("websocket received pong")
#if !os(macOS)

            consoleManager.print("websocket received pong")
#endif
        case .viabilityChanged(let isViable):
            print("Connection viability changed: \(isViable)")
        case .reconnectSuggested(let shouldReconnect):
            print("Reconnect suggested: \(shouldReconnect)")
            if shouldReconnect {
                DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
                    print("Reconnecting...")
                    self.connect()
                }
            } else {
                print("shouldn't reconnect")
            }
        case .cancelled:
            print("WebSocket cancelled")
        case .error(let error):
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }

    var websocket: WebSocket!

    func connectWebSocket(ipAddress: String, port: String) {
        let urlString = "ws://\(ipAddress):\(port)/ws"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        websocket = WebSocket(request: request)
        websocket.callbackQueue = DispatchQueue(label: "com.chrisswiftygpt.swiftsage")
        websocket.delegate = self
        websocket.connect()
    }
    func connect() {
        websocket.connect()

    }
    func sendCommand(command: String) {
        print("Executing: \(command)")

        // TODO: More commands iOS side?
        switch command {
        case "open":
            // doooo open file thing
            print("Opening ContentView.swift...")
#if !os(macOS)

            consoleManager.print("Opening ContentView.swift...")
#endif
            return
        default:
            break
        }

        websocket.write(string:command)
    }

    func sendPing() {
        guard let socket = websocket else { return }
        socket.write(ping: Data())
    }

    var pingTimer: Timer?

    func startPingTimer() {
        // Invalidate any existing timer
        pingTimer?.invalidate()

        // Create a new timer that fires every 30 seconds
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

}
var firstBackground = false
class AppState: ObservableObject {
    @Published var isInBackground: Bool = false
    private var cancellables: [AnyCancellable] = []

    init() {
#if !os(macOS)

        let didEnterBackground = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .map { _ in true }
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()

        let willEnterForeground = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .map { _ in false }
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()

        didEnterBackground
            .merge(with: willEnterForeground)
            .sink { [weak self] in
                self?.isInBackground = $0
                // SHOULD RECONNECT????????
//                if !(self?.isInBackground ?? false) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
                        if firstBackground {
                            consoleManager.print("Reconnecting... but you should probably reboot app for now, he's working on it...")
                        }
                        //screamer.connect()
                        firstBackground = true
                    }
                    
//                }
            }
            .store(in: &cancellables)
#endif
    }
}
