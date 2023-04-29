//
//  Screamer.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/28/23.
//

import Foundation
import SwiftUI
import Combine

let screamer = ScreamClient()
let reconnectInterval: TimeInterval = 1.0

class ScreamClient: WebSocketDelegate {

    var websocket: WebSocket!
    var pingTimer: Timer?
    public private(set) var isConnected = false

    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
#if !os(macOS)

            consoleManager.print("WebSocket connected")
#endif
            print("WebSocket connected \(headers)")
#if !os(macOS)

            let devType = UIDevice.current.userInterfaceIdiom == .phone ? "iOS" : "iPadOS"
            client.write(string: "Hello from \(devType)")
#endif
            startPingTimer()
        case .disconnected(let reason, let code):
            print("WebSocket disconnected, reason: \(reason), code: \(code)")
#if !os(macOS)
            consoleManager.print("WebSocket disconnected: reason: \(reason), code: \(code)")
#endif

            stopPingTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
#if !os(macOS)

                consoleManager.print("Reconnecting...")
#endif
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
#if !os(macOS)

            consoleManager.print("Connection viability changed: \(isViable)")
#endif

        case .reconnectSuggested(let shouldReconnect):
            print("Reconnect suggested: \(shouldReconnect)")
#if !os(macOS)

            consoleManager.print("Reconnect suggested: \(shouldReconnect)")
#endif

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
#if !os(macOS)

            consoleManager.print("WebSocket cancelled")
#endif
        case .error(let error):

#if !os(macOS)

            consoleManager.print("Error: \(error?.localizedDescription ?? "Unknown error")")
#endif
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
            isConnected = false
            disconnect()
        }
    }


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
#if !os(macOS)
            consoleManager.print("Executing: \(command)")
#endif
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

    public func disconnect() {
        websocket?.disconnect()
        websocket = nil
        isConnected = false
    }

}
