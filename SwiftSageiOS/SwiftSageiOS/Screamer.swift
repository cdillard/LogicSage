//
//  Screamer.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/28/23.
//

import Foundation
import SwiftUI
import Combine

var screamer = ScreamClient()
let reconnectInterval: TimeInterval = 2.666
let timeoutInterval: TimeInterval = 10
let PING_INTERVAL: TimeInterval = 60.666

class ScreamClient: WebSocketDelegate {

    var websocket: WebSocket!
    var pingTimer: Timer?
    public private(set) var isViable = false

    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(_):
#if !os(macOS)
            let devType = UIDevice.current.userInterfaceIdiom == .phone ? "iOS" : "iPadOS"

            logD("WebSocket connected \(devType) device.\n\(SettingsViewModel.shared.logoAscii5())")
#else
            logD("WebSocket connected Mac device.\n\(SettingsViewModel.shared.logoAscii5())")
#endif
            let authData: [String: Any] = ["username": SettingsViewModel.shared.userName, "password": SettingsViewModel.shared.password]
            do {
            let authJSON = try JSONSerialization.data(withJSONObject: authData, options: [.fragmentsAllowed]) 
                let authString = String(data: authJSON, encoding: .utf8)
                client.write(string: authString ?? "")
            }
            catch {
                logD("error = \(error)")
            }
            
            startPingTimer()
        case .disconnected(let reason, let code):
            logD("WebSocket disconnected, reason: \(reason), code: \(code)")

            stopPingTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
                self.websocket = nil

                logD("Reconnecting...")
                self.connect()
            }
        case .text(let text):
#if !os(macOS)
            do {
                let json = try JSONSerialization.jsonObject(with: Data(text.utf8), options: .fragmentsAllowed) as? [String: String]
                if let recipient = json?["recipient"] as? String,
                   let message = json?["message"] as? String {

                    if recipient == SettingsViewModel.shared.userName {
                        logD(message)

                        if message.hasPrefix("say:") {
                            let arr = message.split(separator: ": ", maxSplits: 1)
                            if arr.count > 1 {
                                logD("speaking...")
                                let speech = String(arr[1])
                                SettingsViewModel.shared.speak(speech)
                            }
                            else {
                                logD("failed")
                            }
                        }
                    }
                    else {
                        print("recipient: \(recipient)?")
                    }
                }
            }
            catch {
                logD("cmd err = \(error)")
            }
#endif
            // TODO HANDLE AUTH json structured data
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
            break
        case .pong:
            break
        case .viabilityChanged(let isViable):
            DispatchQueue.main.async {

                logD("connection viable: \(isViable)")
                self.isViable = isViable

            }
        case .reconnectSuggested(let shouldReconnect):

            logD("Reconnect suggested: \(shouldReconnect)")

            if shouldReconnect {
                DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
                    print("Reconnecting...")
                    self.connect()
                }
            } else {
                print("shouldn't reconnect")
            }
        case .cancelled:
            logD("WebSocket cancelled")
        case .error(let error):
            logD("Error: \(error?.localizedDescription ?? "Unknown error")")
            disconnect()

            websocket = nil
            screamer = ScreamClient()

            DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
                print("Reconnecting...")
                self.connect()
            }
        }
    }
    func connectWebSocket(ipAddress: String, port: String) {
        let urlString = "ws://\(ipAddress):\(port)/ws"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval

        websocket = WebSocket(request: request)
        websocket.callbackQueue = DispatchQueue(label: bundleID)
        websocket.delegate = self
        websocket.connect()
    }
    func connect() {
        if isViable && websocket != nil {
            logD("connect websocket...")

            websocket.connect()
        }
        else {
            disconnect()
            websocket = nil
            screamer = ScreamClient()
            screamer.connectWebSocket(ipAddress: SettingsViewModel.shared.ipAddress, port: SettingsViewModel.shared.port)

            logD("Attempt to connect non-viable connection - failing.")

        }

    }
    func sendCommand(command: String) {
        logD("Executing: \(command)")
        if SettingsViewModel.shared.currentMode == .mobile {
            logD("Handling \(command) mobile mode...")
            if callLocalCommand(command) {
                return
            }
        }
        else {
            logD("Handling \(command) in computer mode...")

            if websocket != nil {
                let messageData: [String: Any] = ["recipient": "SERVER", "command": command]
                do {
                    let messageJSON = try JSONSerialization.data(withJSONObject: messageData, options: [.fragmentsAllowed])
                    let messageString = String(data: messageJSON, encoding: .utf8)
                    websocket.write(string: messageString ?? "")
                }
                catch {
                    logD("error = \(error)")
                }

            }
            else {
                print("Websocket nil, not handling command")
            }
        }
    }
    func sendPing() {
        guard let socket = websocket else { return }
        socket.write(ping: Data())
    }
    func startPingTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

            // Invalidate any existing timer
            self.pingTimer?.invalidate()

            // Create a new timer that fires every 30 seconds
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: PING_INTERVAL, repeats: true) { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                    self?.sendPing()
                }
            }
        }
    }
    func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    public func disconnect() {
        websocket?.disconnect()
        websocket = nil
    }
}
