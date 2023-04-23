//
//  SwiftSageStatusBarXFace.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation
import AppKit

func runMacSage() {

    // TODO: Check running procs and kill all SwiftSageStatusBars to unify as one.
    let statusBarAppBundleIdentifier = "com.chrisswiftygpt.SwiftSageStatusBar" // Replace this with your status bar app's bundle identifier
    if !isStatusBarAppRunning(bundleIdentifier: statusBarAppBundleIdentifier) {
        do {
            let mainBundle = Bundle.main
            guard let macosAppURL = mainBundle.url(forResource: "SwiftSageStatusBar", withExtension: "") else {
                return print("Failed to locate the bundled macOS app.")
            }

            let task = Process()
            let pipeToChild = Pipe()
            let pipeFromChild = Pipe()

            task.executableURL = macosAppURL


            // Create a pipe to redirect the output
            let outputPipe = Pipe()
            task.standardOutput = outputPipe

            // Create a pipe to redirect the error output
            let errorPipe = Pipe()
            task.standardError = errorPipe

            try task.run()


//            // Write to child app
//             if let data = "Hello, child app!\n".data(using: .utf8) {
//                 pipeToChild.fileHandleForWriting.write(data)
//                 pipeToChild.fileHandleForWriting.closeFile()
//             }
//
//            // Read from child app
//            let data = pipeFromChild.fileHandleForReading.readDataToEndOfFile()
//            if let output = String(data: data, encoding: .utf8) {
//                print("Parent App Received: \(output)")
//            }


            task.terminationHandler = { success in
                print("terminated w \(success)")

            }
            // Read the output data
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let outputString = String(data: outputData, encoding: .utf8) {
                print("Output: \(outputString)")
                // This being printed seems to indicate the EOL for the taskbar app
            }
            
            // Read the error output data
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if let errorString = String(data: errorData, encoding: .utf8) {
                print("Error: \(errorString)")
            }

            //task.waitUntilExit()
        }
        catch {
            print("failure w e=\(error)")
        }
    }
    else {
        print("status bar alreadt rybbub")
    }
}
func sendNotification(buttonTapped: Bool? = nil, switchChanged: Bool? = nil) {
    let distributedNotificationCenter = DistributedNotificationCenter.default()

    var userInfo: [String: Bool] = [:]
    if let buttonTapped = buttonTapped {
        userInfo["buttonTapped"] = buttonTapped
    }
    if let switchChanged = switchChanged {
        userInfo["switchChanged"] = switchChanged
    }

    distributedNotificationCenter.post(name: NSNotification.Name(rawValue: "com.example.yourapp.notification"), object: nil, userInfo: userInfo)
}
func isStatusBarAppRunning(bundleIdentifier: String) -> Bool {
    let runningApps = NSWorkspace.shared.runningApplications
    for app in runningApps {
        if app.bundleIdentifier == bundleIdentifier {
            return true
        }
    }
    return false
}
