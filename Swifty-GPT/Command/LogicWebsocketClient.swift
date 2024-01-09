//
//  LogicWebsocketClient.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 5/26/23.
//

import Foundation
import Starscream

class ServerWebSocketClient: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("Conneted to server:  w/ headers \(headers))")
            let authData: [String: String] = ["username": SWIFTSAGE_SERVER_USERNAME, "password": SWIFTSAGE_SERVER_PASSWORD]
            do {
                let authJSON = try JSONSerialization.data(withJSONObject: authData, options: [.fragmentsAllowed])
                let authString = String(data: authJSON, encoding: .utf8)
                client.write(string: authString ?? "")
            }
            catch {
                print("fail = \(error)")
            }
          //  startPingTimer()
        case .disconnected(let reason, let code):
            print("Disconnected from server: \(reason), code: \(code)")
            stopPingTimer()

            DispatchQueue.global().asyncAfter(deadline: .now() + reconnectInterval) {
                print("Reconnecting...")
                self.connect()
            }
// HANDLE MESSAGES *****************************************************************
        case .text(let text):
            do {
                let json = try JSONSerialization.jsonObject(with:
                                                    Data(text.utf8), options: .fragmentsAllowed) as? [String: String]
                if let recipient = json?["recipient"] as? String,
                   let command = json?["command"] as? String {
                  // print("recipient=\(recipient) , command=\(command)")
                    let commandSplit = command.split(separator: " ", maxSplits: 1)

                    if !commandSplit.isEmpty {
                        var comp2 = ""
                        if commandSplit.count > 1 {
                            comp2 = String(commandSplit[1])
                        }

                        callCommandCommand(String(commandSplit[0]), comp2, recipient: recipient)
                    }
                }
                break
            }
            catch {
                print("failed to parse command as JSON: \(error), trying normal...")
            }
// END HANDLE MESSAGES *****************************************************************
        case .binary(let data):
            break
           // print("Received binary data: \(data)")
        case .pong( _):
            break
        case .ping( _):
            break
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
    private let timer: DispatchSourceTimer
    private var isRunning: Bool

    init() {
        let urlString = "ws://127.0.0.1:8080/ws"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        isRunning = false

        websocket = WebSocket(request: request)
        websocket.callbackQueue = DispatchQueue(label: "\(bundleID)websocket")

        websocket.delegate = self
        websocket.connect()
    }
    func connect() {
        websocket.connect()
    }

    func startPingTimer() {
        guard !isRunning else { return }
        isRunning = true

        let delay: TimeInterval = PING_INTERVAL

        timer.schedule(deadline: .now(), repeating: delay)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }

            if !self.isRunning {
                return
            }

           sendPing()
        }

        timer.resume()
    }

    func stopPingTimer() {
        isRunning = false
    }

    func sendPing() {
        websocket.write(ping: Data())
    }
}
