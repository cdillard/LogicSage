//
//  LocalPeerConsole.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/23/23.
//

import Foundation
import Starscream

func multiPrinter(_ items: Any..., separator: String = " ", terminator: String = "\n") {

    if !swiftSageIOSEnabled {
        print(items, separator: separator, terminator: terminator)
        return
    }


    if items.count == 1, let singleString = items.first as? String {
        print(items, separator: separator, terminator: terminator)
        localPeerConsole.sendLog(singleString)
        return
    }
    // Otherwise, handle the items as a collection of strings
    for item in items {
        if let str = item as? String {
            print(str, separator: separator, terminator: terminator)
            localPeerConsole.sendLog(str)
        }
    }
}

let localPeerConsole = LocalPeerConsole()

class LocalPeerConsole: NSObject {
    let webSocketClient = WebSocketClient()

    func sendLog(_ text: String) {

        webSocketClient.websocket.write(string: text)
    }
}


import Foundation
import Starscream

class WebSocketClient: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("Conneted to server:  w/ headers \(headers))")
            client.write(string: "Hello from CMD LINE app!")

            startPingTimer()
        case .disconnected(let reason, let code):
            print("Disconnected from server: \(reason), code: \(code)")
            stopPingTimer()
            DispatchQueue.global().asyncAfter(deadline: .now() + reconnectInterval) {
                print("Reconnecting...")
                self.connect()
            }
        case .text(let text):
            print("Received text: \(text)")
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
            print("Error: \(error?.localizedDescription)")
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
