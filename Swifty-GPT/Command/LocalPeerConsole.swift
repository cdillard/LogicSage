//
//  LocalPeerConsole.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/23/23.
//

import Foundation
import Starscream

func multiPrinter(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    for username in ["chris", "chuck", "hackerman"] {
        if !swiftSageIOSEnabled {
            print(items, separator: separator, terminator: terminator)
            return
        }

        if items.count == 1, let singleString = items.first as? String {
            print(items, separator: separator, terminator: terminator)
            localPeerConsole.sendLog(to: username, text: singleString)
            return
        }
        // Otherwise, handle the items as a collection of strings
        for item in items {
            if let str = item as? String {
                print(str, separator: separator, terminator: terminator)
                localPeerConsole.sendLog(to: username, text: str)
            }
        }
    }
}

let localPeerConsole = LocalPeerConsole()

class LocalPeerConsole: NSObject {
    let webSocketClient = WebSocketClient()

    func sendLog(to recipient: String, text: String) {
         let logData: [String: String] = ["recipient": recipient, "message": text]
        do {
            let logJSON = try JSONSerialization.data(withJSONObject: logData, options: [.fragmentsAllowed])
            let logString = String(data: logJSON, encoding: .utf8)
            webSocketClient.websocket.write(string: logString ?? "")

        }
        catch {
            print( "error = \(error)")
        }
     }

    func sendCommand(to recipient: String, command: String) {
        let logData: [String: String] = ["recipient": recipient, "command": command, "from": "SERVER"]
        do {
            let logJSON = try JSONSerialization.data(withJSONObject: logData, options: [.fragmentsAllowed])
            let logString = String(data: logJSON, encoding: .utf8)
            webSocketClient.websocket.write(string: logString ?? "")

        }
        catch {
            print( "error = \(error)")
        }
     }

    // TODO: Fix with Auth
    func sendImageData(_ imageData: Data?) {
        guard let data = imageData else {
            print("failed")
            return
        }
        webSocketClient.websocket.write(data: data)
    }
}

class WebSocketClient: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("Conneted to server:  w/ headers \(headers))")
            let authData: [String: String] = ["username": "SERVER", "password": "supers3cre3t"]
            do {
                let authJSON = try JSONSerialization.data(withJSONObject: authData, options: [.fragmentsAllowed])
                let authString = String(data: authJSON, encoding: .utf8)
                client.write(string: authString ?? "")
            }
            catch {
                print("fail = \(error)")
            }
            startPingTimer()
        case .disconnected(let reason, let code):
            print("Disconnected from server: \(reason), code: \(code)")
            stopPingTimer()
//            DispatchQueue.global().asyncAfter(deadline: .now() + reconnectInterval) {
//                print("Reconnecting...")
//                self.connect()
//            }
        case .text(let text):
            print("Received text: \(text)")

            // TODO: should probably be parsing the command JSON for recipient and command....

            let components = text.split(separator: " ", maxSplits: 1)
            if !components.isEmpty {
                var comp2 = ""
                if components.count > 1 {
                    comp2 = String(components[1])
                }
                callCommandCommand(String(components[0]), comp2)
            }
            else {
                print("niped")
            }

        case .binary(let data):
            print("Received binary data: \(data)")
        case .pong(let data):
            print("Received PONG data: \(data ?? Data())")
        case .ping(let data):
            print("Received PING data: \(data ?? Data())")
        case .error(let error):
            print("Error: \(error?.localizedDescription ?? "error")")
        case .viabilityChanged(let isViable):
            print("Viability changed: \(isViable)")
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
            DispatchQueue.global().asyncAfter(deadline: .now() + reconnectInterval) {
                print("Reconnecting...")
                self.connect()
            }
        }
    }

    var websocket: WebSocket!
    let reconnectInterval: TimeInterval = 1.0

    init() {

        let urlString = "ws://127.0.0.1:8080/ws"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
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

    func sendPing() {
        websocket.write(ping: Data())
    }
}
