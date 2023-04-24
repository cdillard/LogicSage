//
//  LocalPeerConsole.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/23/23.
//

import Foundation
import Starscream
//import MultipeerConnectivity
//public extension MCPeerID {
//    static var defaultSageDisplayName: String { "CommandLineAppPeerId" }
//    static var defaultSagePhoneDisplayName: String { "iOSAppPeerID" }
//
//}
func multiPrinter(_ items: Any..., separator: String = " ", terminator: String = "\n") {

    if !swiftSageIOSEnabled {
        print(items, separator: separator, terminator: terminator)
        return
    }


    if items.count == 1, let singleString = items.first as? String {
        print(items, separator: separator, terminator: terminator)
        LocalPeerConsole.localPeerConsole.sendLog(singleString)
        return
    }
    // Otherwise, handle the items as a collection of strings
    for item in items {
        if let str = item as? String {
            print(str, separator: separator, terminator: terminator)
            LocalPeerConsole.localPeerConsole.sendLog(str)
        }
    }
}



class LocalPeerConsole: NSObject {
        static let localPeerConsole = LocalPeerConsole()
        static let webSocketClient = WebSocketClient()

        func sendLog(_ text: String) {

            LocalPeerConsole.webSocketClient.websocket.write(string: text)
        }
}


import Foundation
import Starscream

class WebSocketClient: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected, headers: \(headers)")
            client.write(string: "Hello from the command line app!")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected, reason: \(reason), code: \(code)")
        case .text(let text):
            print("Received text: \(text)")
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

    let websocket: WebSocket
    private let messageSemaphore = DispatchSemaphore(value: 12)
    init() {
        let urlString = "ws://127.0.0.1:8080/ws"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        websocket = WebSocket(request: request)
        websocket.delegate = self
        websocket.connect()
    }

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected, headers: \(headers)")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected, reason: \(reason), code: \(code)")
        case .text(let text):
            print("Received text: \(text)")
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

//    func sendWithDelay(_ text: String, delay: TimeInterval) {
//        DispatchQueue.global().async { [weak self] in
//            self?.messageSemaphore.wait()
//            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
//                self?.websocket.write(string: text)
//                self?.messageSemaphore.signal()
//            }
//        }
//    }
}

// WHY WONT YOU WORK Apples MultipeerConnectivity? (Is it because I'm in  Swift Cmd Line app trying to commune with an iOS app? :P)

//class LocalPeerConsole: NSObject, MCSessionDelegate {
//    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        print(" MCSession:peer peerID: MCPeerID, didChange \(peerID)")
//
//    }
//
//    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        print(" MCSession:didReceive \(peerID)")
//
//    }
//
//    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//        print("MCSession:didReceive \(peerID)")
//
//    }
//
//    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//        print("MCSession:didStartReceivingResourceWithName \(peerID)")
//
//    }
//
//    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
//        print("MCSession:didFinishReceivingResourceWithName \(peerID)")
//    }
//
//    var transceiver: MultipeerTransceiver!
//    var connectedPeers: [Peer] = []
//
//    static let localPeerConsole = LocalPeerConsole()
//    override init() {
//        super.init()
//
//        if !swiftSageIOSEnabled { print("not doing ios stuff ; see feat flag `let swiftSageIOSEnabled = true` for you brave souls") ; return }
//
//        let inviterScheme = MultipeerConfiguration.Invitation.none
//
//        let config = MultipeerConfiguration(serviceType: "ssage-service",
//                                            peerName: MCPeerID.defaultSageDisplayName,
//                                            defaults: .standard,
//                                            security: .default,
//                                            invitation: inviterScheme)
//
//
//
//
//        transceiver = MultipeerTransceiver(configuration: config, modes: [.transmitter])
//
//
//        transceiver.availablePeersDidChange = { peers in
//            print("peers changed, p=\(peers)")
//        }
//
//
//
//        transceiver.peerAdded = {  peer in
//            print("Connected to: \(peer.name)")
//            self.connectedPeers.append(peer)
//            print("Connected peers: \(self.connectedPeers.map { $0.name } )")
//        }
//
//        transceiver.peerRemoved = {  peer in
//            print("Disconnected from: \(peer.name)")
//            self.connectedPeers.removeAll { $0 == peer }
//            print("Connected peers: \(self.connectedPeers.map { $0.name } )")
//
//        }
//        transceiver.peerDisconnected = {  peer in
//            print("peerDisconnected from: \(peer.name)")
//
//        }
//
//        //DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
//        self.transceiver.resume()
//
//
//        transceiver.receive(YourDataType.self, using: { payload,sender  in
//            print("RECEIVED MESSAGE: \(payload)")
//        })
//        // TODO: figure out
//        //            do {
//        //                var cmdLinePeer = try Peer(peer: MCPeerID(displayName:  MCPeerID.defaultSagePhoneDisplayName), discoveryInfo: [:])
//        //                self.transceiver.invite(cmdLinePeer, with: nil, timeout: 5) { result in
//        //                    print("transceiver invite result  = \(result)")
//        //
//        //                }
//        //            }
//        //            catch {
//        //                print("error = \(error)")
//        //            }
//        // }
//    }
//
//
//    func sendLog(_ text: String) {
//        if !swiftSageIOSEnabled { return }
//        if connectedPeers.isEmpty { print("no peers to log too......"); return }
//
//        let yourData = YourDataType.text(text)
//        transceiver.broadcast(yourData)
//    }
//}
//
//enum YourDataType: Codable {
//    case text(String)
//}
