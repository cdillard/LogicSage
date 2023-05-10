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
    public private(set) var isViable = false

    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true

#if !os(macOS)

            let devType = UIDevice.current.userInterfaceIdiom == .phone ? "iOS" : "iPadOS"

            logD("WebSocket connected a \(devType) device.\n\(headers)\n\(SettingsViewModel.shared.logoAscii5())")
#else
            logD("WebSocket connected a Mac device.\n\(headers)\n\(SettingsViewModel.shared.logoAscii5())")
#endif

            let authData: [String: Any] = ["username": SettingsViewModel.shared.userName, "password": SettingsViewModel.shared.password]
            do {
            let authJSON = try JSONSerialization.data(withJSONObject: authData, options: [.fragmentsAllowed]) 
                let authString = String(data: authJSON, encoding: .utf8)
                client.write(string: authString ?? "")
            }
            catch {
                print("error = \(error)")
            }
            
            startPingTimer()
        case .disconnected(let reason, let code):
            logD("WebSocket disconnected, reason: \(reason), code: \(code)")

            isConnected = false
            stopPingTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {

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
                                speak(speech)
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

                return
            }
            catch {
                print("error printing text")
            }
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
        websocket.callbackQueue = DispatchQueue(label: bundleID)
        websocket.delegate = self
        websocket.connect()
    }
    func connect() {
        if isViable && websocket != nil {
            websocket.connect()
        }
        else {
            logD("Attempt to connect non-viable connection - failing.")
        }

    }
    func sendCommand(command: String) {

        logD("Executing: \(command)")
        if SettingsViewModel.shared.currentMode == .mobile {
            logD("Handling \(command) as local cmd...")
            if callLocalCommand(command) {
                return
            }
        }
        else {

            if websocket != nil {
                let messageData: [String: Any] = ["recipient": "SERVER", "command": command]
                do {
                    let messageJSON = try JSONSerialization.data(withJSONObject: messageData, options: [.fragmentsAllowed])
                    let messageString = String(data: messageJSON, encoding: .utf8)
                    websocket.write(string: messageString ?? "")
                }
                catch {
                    print("error = \(error)")
                }

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
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 22.666, repeats: true) { [weak self] _ in
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
        isConnected = false
    }

}
