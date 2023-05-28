//
//  LocalPeerConsole.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/23/23.
//

import Foundation
import Starscream

let localPeerConsole = LocalPeerConsole()

class LocalPeerConsole: NSObject {
    let webSocketClient = WebSocketClient()

    let chunkSize = 16384 // This is the maximum frame size for a WebSocket message
    let imgStartSentinel = "START_OF_IMG_DATA"
    let imgEndSentinel   = "END_OF_IMG_DATA"
    let simStartSentinel = "START_OF_SIM_DATA"
    let simEndSentinel   = "END_OF_SIM_DATA"
    let workspaceStartSentinel = "START_OF_WORKSPACE_DATA"
    let workspaceEndSentinel   = "END_OF_WORKSPACE_DATA"

    var isSendingSimulatorData = false
    var isSendingImageData = false
    var isSendingWorkspaceData = false

// SEND TEXT OVER WEBSOCKET ZONE ***************************************
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
        let logData: [String: String] = ["recipient": recipient, "command": command]
        do {
            let logJSON = try JSONSerialization.data(withJSONObject: logData, options: [.fragmentsAllowed])
            let logString = String(data: logJSON, encoding: .utf8)
            webSocketClient.websocket.write(string: logString ?? "")
        }
        catch {
            print( "error = \(error)")
        }
     }
// END TEXT OVER WEBSOCKET ZONE ***************************************

// SEND DATA OVER WEBSOCKET ZONE ***************************************
    // TODO: Fix binary data sending now that we have Auth
    func sendImageData(_ imageData: Data?, name: String = "image.heic") {
        guard !isSendingImageData else { return multiPrinter("busy can't image ")}
        guard !isSendingSimulatorData else { return multiPrinter("busy can't simulator ") }
        guard !isSendingWorkspaceData else { return multiPrinter("busy can't workspace ") }

        guard let data = imageData else {
            multiPrinter("failed to get img data")
            return
        }
        
        isSendingImageData = true
        let startMessage = imgStartSentinel.data(using: .utf8)!
        webSocketClient.websocket.write(data: startMessage)


        // Prepare and send JSON metadata
        let jsonMetadata: [String: Any] = ["filename": name, "filesize": data.count]
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonMetadata, options: []) {
            webSocketClient.websocket.write(data: jsonData)
        } else {
            multiPrinter("Failed to encode JSON")
            return
        }


        var offset = 0
        while offset < data.count {
            let chunk = data.subdata(in: offset..<min(offset + chunkSize, data.count))
            webSocketClient.websocket.write(data: chunk)
            offset += chunkSize
        }
        let endMessage = imgEndSentinel.data(using: .utf8)!
        webSocketClient.websocket.write(data: endMessage)

        isSendingImageData = false
    }
    func sendSimulatorData(_ simData: Data?) {
        guard !isSendingImageData else { return multiPrinter("busy can't image ")}
        guard !isSendingSimulatorData else { return multiPrinter("busy can't simulator ") }
        guard !isSendingWorkspaceData else { return multiPrinter("busy can't workspace ") }

        guard let data = simData else {
            multiPrinter("failed to get sim data")
            return
        }
        isSendingSimulatorData = true

        let startMessage = simStartSentinel.data(using: .utf8)!
        webSocketClient.websocket.write(data: startMessage)

        var offset = 0
        while offset < data.count {
            let chunk = data.subdata(in: offset..<min(offset + chunkSize, data.count))
            webSocketClient.websocket.write(data: chunk)
            offset += chunkSize
        }
        let endMessage = simEndSentinel.data(using: .utf8)!
        webSocketClient.websocket.write(data: endMessage)
        isSendingSimulatorData = false
    }
    func sendWorkspaceData(_ workspaceData: Data?) {
        guard !isSendingImageData else { return multiPrinter("busy can't image ")}
        guard !isSendingSimulatorData else { return multiPrinter("busy can't simulator ") }
        guard !isSendingWorkspaceData else { return multiPrinter("busy can't workspace ") }

        guard let data = workspaceData else {
            multiPrinter("failed to get workspace data")
            return
        }
        isSendingWorkspaceData = true

        let startMessage = workspaceStartSentinel.data(using: .utf8)!
        webSocketClient.websocket.write(data: startMessage)

        var offset = 0
        while offset < data.count {
            let chunk = data.subdata(in: offset..<min(offset + chunkSize, data.count))
            webSocketClient.websocket.write(data: chunk)
            offset += chunkSize
        }
        let endMessage = workspaceEndSentinel.data(using: .utf8)!
        webSocketClient.websocket.write(data: endMessage)
        isSendingWorkspaceData = false
    }
// END SEND DATA OVER WEBSOCKET ZONE ***************************************
}
