//
//  Screamer.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/28/23.
//

import Foundation
import SwiftUI
import Combine

var screamer = ScreamClient()

let PING_INTERVAL: TimeInterval = 60.666

let recipientJsonKey = "recipient"
let messageJsonKey = "message"
let usernameJsonKey = "username"
let passwordJsonKey = "password"
let commandJsonKey = "command"
let serverUsernameValue = "SERVER"
let filenameJsonKey = "filename"
let filesizeJsonKey = "filesize"

class ScreamClient: WebSocketDelegate {
    
    let reconnectInterval: TimeInterval = 2.666
    let timeoutInterval: TimeInterval = 10
    let imgStartSentinel = "START_OF_IMG_DATA"
    let imgEndSentinel   = "END_OF_IMG_DATA"
    let simStartSentinel = "START_OF_SIM_DATA"
    let simEndSentinel   = "END_OF_SIM_DATA"
    let workspaceStartSentinel
    = "START_OF_WORKSPACE_DATA"
    let workspaceEndSentinel
    = "END_OF_WORKSPACE_DATA"
    var websocket: LocalWebSocket!
    var pingTimer: Timer?
    public private(set) var isViable = false
    
    var receivedWorkspaceData = Data()
    var receivedSimData = Data()
    var receivedData = Data()
    
    var isTransferringSim = false
    var isTransferringWallpaper = false
    var isTransferringWorkspace = false
    var receivedWallpaperFileName: String?
    var receivedWallpaperFileSize: Int?
    
    func logOpenReport() {
#if !os(macOS)
        let devType = UIDevice.current.userInterfaceIdiom == .phone ? "iOS" : "iPadOS"
        logD("WebSocket connected \(devType) device.\n\(logoAscii5())")
#else
        logD("WebSocket connected Mac device.\n\(logoAscii5())")
#endif
    }
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(_):
            
            logOpenReport()
            
            let authData: [String: Any] = [usernameJsonKey: SettingsViewModel.shared.userName, passwordJsonKey: SettingsViewModel.shared.password]
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
            do {
                let json = try JSONSerialization.jsonObject(with: Data(text.utf8), options: .fragmentsAllowed) as? [String: String]
                guard let recipient = json?[recipientJsonKey] as? String,
                      let message = json?[messageJsonKey] as? String else {
                    return logD("malformed text received on ws")
                }
                
                if recipient == SettingsViewModel.shared.userName {
                    
                    logDNoNewLine(message)
                    
                    playMessagForString(message: message)
                    
                    if message.hasPrefix("say:") {
                        var arr = [Substring]()
                        let saySep = ": "
                            arr = message.split(separator: saySep, maxSplits: 1)
                            
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
                    //  logD("diff recipient on ws: \(recipient)?")
                }
            }
            catch {
                logD("cmd err = \(error)")
            }
            
            // TODO: HANDLE AUTH json structured data
        case .binary(let data):
            // BEGIN HANDLE WORKSPACE STREAM ZONE ******************************************************
            if data == workspaceStartSentinel.data(using: .utf8)! {
                isTransferringWorkspace = true
                receivedWorkspaceData = Data()
            }
            else if data == workspaceEndSentinel.data(using: .utf8)! {
                isTransferringWorkspace = false
                
#if !os(macOS)
                
                DispatchQueue.main.async {
                    SettingsViewModel.shared.recievedWorkspaceData = self.receivedWorkspaceData
                }
#endif
            }
            // END HANDLE WORKSPACE STREAM ZONE ******************************************************
            
            // BEGIN HANDLE SIM STREAM ZONE ******************************************************
            else if data == simStartSentinel.data(using: .utf8)! {
                isTransferringSim = true
                receivedSimData = Data()
            }
            else if data == simEndSentinel.data(using: .utf8)! {
                isTransferringSim = false
#if !os(macOS)
                
                DispatchQueue.main.async {
                    SettingsViewModel.shared.receivedSimulatorFrameData = self.receivedSimData
                }
#endif
                
            }
            // END HANDLE SIM STREAM ZONE ******************************************************
            
            // BEGIN HANDLE WALLPAPER STREAM ZONE ******************************************************
            else if data == imgStartSentinel.data(using: .utf8)! {
                isTransferringWallpaper = true
                receivedData = Data()
            }
            else if data == imgEndSentinel.data(using: .utf8)! {
                isTransferringWallpaper = false
                
#if !os(macOS)
                
                DispatchQueue.main.async {
                    SettingsViewModel.shared.receivedWallpaperFileName = self.receivedWallpaperFileName
                    SettingsViewModel.shared.receivedWallpaperFileSize = self.receivedWallpaperFileSize
                    
                    SettingsViewModel.shared.receivedImageData = self.receivedData
                    
                    self.receivedWallpaperFileName = nil
                    self.receivedWallpaperFileSize = nil
                }
#endif
            }
            // END HANDLE WALLPAPER STREAM ZONE ******************************************************
            
            // BEGIN DATA APPENDAGE ZONE ******************************************************
            else if isTransferringWorkspace {
                receivedWorkspaceData.append(data)
            }
            else if isTransferringWallpaper {
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    receivedWallpaperFileName = json[filenameJsonKey] as? String
                    receivedWallpaperFileSize = json[filesizeJsonKey] as? Int
                }
                else {
                    receivedData.append(data)
                }
            }
            else if isTransferringSim {
                receivedSimData.append(data)
            }
            // END DATA APPENDAGE ZONE ******************************************************
            
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
                    logD("Reconnecting...")
                    self.connect()
                }
            } else {
                logD("shouldn't reconnect")
            }
        case .cancelled:
            logD("WebSocket cancelled")
        case .error(let error):
            logD("Error: \(error?.localizedDescription ?? "Unknown error")")
            
            discoReconnect()
        }
    }
    
    func discoReconnect() {
        disconnect()
        
        websocket = nil
        screamer = ScreamClient()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectInterval) {
            logD("Reconnecting...")
            self.connect()
        }
    }
    
    func connectWebSocket(ipAddress: String, port: String) {
        guard !ipAddress.isEmpty && !port.isEmpty else {
            logD("ip or port not set")
            return
        }
        let urlString = "ws://\(ipAddress):\(port)/ws"
        guard let url = URL(string: urlString) else {
            logD("Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval
        
        websocket = LocalWebSocket(request: request)
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
        logD("LogicSage handling \(command)...")
        if command == "st" || command == "stop" || command == "STOP" { SettingsViewModel.shared.stopVoice() ; stopRandomSpinner() ;  }
        
        if websocket != nil {
            let messageData: [String: Any] = [recipientJsonKey: serverUsernameValue, commandJsonKey: command]
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
            logD("Websocket nil, not handling command")
            logD("0. Set your Computers API Key for A.I. in GPT-Info.plist before building and running the LogicSage ./run.sh")
            
            disconnect()
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
