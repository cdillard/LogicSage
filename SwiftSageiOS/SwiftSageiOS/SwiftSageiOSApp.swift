//
//  SwiftSageiOSApp.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/23/23.
//

import SwiftUI
import LocalConsole
import Starscream

//import MultipeerConnectivity
//
//public extension MCPeerID {
//    static var defaultSageDisplayName: String { "CommandLineAppPeerId" }
//    static var defaultSagePhoneDisplayName: String { "iOSAppPeerID" }
//
//}

let defaultTerminalFontSize: CGFloat = 12.666


@main
struct SwiftSageiOSApp: App {
    init() {
        ScreamClient.screamer.connectWebSocket()
    }


    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.purple
                    .ignoresSafeArea()
                ContentView()
            }

        }
    }
}

class ScreamClient: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected, headers: \(headers)")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected, reason: \(reason), code: \(code)")
        case .text(let text):
            consoleManager.print(text)
        case .binary(let data):
            print("Received binary data: \(data)")
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged(let isViable):
            print("Connection viability changed: \(isViable)")
        case .reconnectSuggested(let shouldReconnect):
            print("Reconnect suggested: \(shouldReconnect)")
        case .cancelled:
            print("WebSocket cancelled")
        case .error(let error):
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }

    var websocket: WebSocket!

    static let screamer = ScreamClient()
    func connectWebSocket() {
        // 10.0.0.1
        // Substitute with your Mac OS IP Address.
        let urlString = "ws://127.0.0.1:8080/ws"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        websocket = WebSocket(request: request)
        websocket.delegate = self
        websocket.connect()
    }
}

// Left commented MultipeerTransceiver in case I have to get it working
//class Transceiver {
//    var transceiver: MultipeerTransceiver!
//
//    var connectedPeers: [Peer] = []
//
//    init() {
//        configureTransceiver()
//    }
//
//    func configureTransceiver() {
//
//
//        let inviterScheme = MultipeerConfiguration.Invitation.none
//
//        let config = MultipeerConfiguration(serviceType: "ssage-service",
//                                            peerName: MCPeerID.defaultSagePhoneDisplayName,
//                                            defaults: .standard,
//                                            security: .default,
//                                            invitation: inviterScheme)
//
//
//        transceiver = MultipeerTransceiver(configuration: config, modes: [.receiver])
//        transceiver.peerAdded = {  peer in
//            print("Connected to: \(peer.name)")
//            self.connectedPeers.append(peer)
//            print("Connected peers: \(self.connectedPeers.map { $0.name } )")
//        }
//
//        transceiver.peerRemoved = {  peer in
//            print("Disconnected from: \(peer.name)")
//            self.connectedPeers.removeAll { $0 == peer }
//
//            print("Connected peers: \(self.connectedPeers.map { $0.name } )")
//        }
//        transceiver.peerDisconnected = {  peer in
//            print("peerDisconnected from: \(peer.name)")
//
//        }
//
//
//
//        transceiver.resume()
//
//
//        transceiver.receive(YourDataType.self, using: { payload,sender  in
//            print("received msg = \(payload)")
//
//            consoleManager.print(payload)
//         })
////        do {
////            var cmdLinePeer = try Peer(peer: MCPeerID(displayName:  MCPeerID.defaultSageDisplayName), discoveryInfo: [:])
////            self.transceiver.invite(cmdLinePeer, with: nil, timeout: 5) { result in
////                print("transceiver invite result  = \(result)")
////
////            }
////        }
////        catch {
////            print("error = \(error)")
////        }
//    }
//
//}
//enum YourDataType: Codable {
//    case text(String)
//}

