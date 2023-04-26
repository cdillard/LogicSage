//
//  SwiftSageiOSApp.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/23/23.
//

import SwiftUI
import Combine



@main
struct SwiftSageiOSApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var appState = AppState()
    var serviceDiscovery: ServiceDiscovery?
    init() {
        serviceDiscovery = ServiceDiscovery()
        serviceDiscovery?.startDiscovering()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                settingsViewModel.backgroundColor
                    .ignoresSafeArea()
                ContentView()
                    .environmentObject(settingsViewModel)
                    .environmentObject(appState)
            }
        }
    }

    func doDiscover() {
        serviceDiscovery?.startDiscovering()
    }
}

let screamer = ScreamClient()

class ScreamClient: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected, headers: \(headers)")
            let devType = UIDevice.current.userInterfaceIdiom == .phone ? "iOS" : "iPadOS"
            client.write(string: "Hello from \(devType) app!")
            startPingTimer()
        case .disconnected(let reason, let code):
            print("WebSocket disconnected, reason: \(reason), code: \(code)")
            stopPingTimer()
            DispatchQueue.global().asyncAfter(deadline: .now() + reconnectInterval) {
                print("Reconnecting...")
                self.connect()
            }
        case .text(let text):
            consoleManager.print(text)
        case .binary(let data):
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
        case .ping:
            print("websocket received ping")
            consoleManager.print("websocket received ping")
        case .pong:
            print("websocket received pong")
            consoleManager.print("websocket received pong")
        case .viabilityChanged(let isViable):
            print("Connection viability changed: \(isViable)")
        case .reconnectSuggested(let shouldReconnect):
            print("Reconnect suggested: \(shouldReconnect)")
            if shouldReconnect {
                DispatchQueue.global().asyncAfter(deadline: .now() + reconnectInterval) {
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
    let reconnectInterval: TimeInterval = 1.0

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
class AppState: ObservableObject {
    @Published var isInBackground: Bool = false
    private var cancellables: [AnyCancellable] = []

    init() {
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
                // screamer.connect()
            }
            .store(in: &cancellables)
    }
}
