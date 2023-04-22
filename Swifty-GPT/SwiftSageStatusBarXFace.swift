//
//  SwiftSageStatusBarXFace.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation


func runMacSage() {
    do {

        // TODO: Check running procs and kill all SwiftSageStatusBars to unify as one.


        let mainBundle = Bundle.main
        guard let macosAppURL = mainBundle.url(forResource: "SwiftSageStatusBar", withExtension: "") else {
            print("Failed to locate the bundled macOS app.")
            exit(1)
        }

        let task = Process()
        task.executableURL = macosAppURL


        // Create a pipe to redirect the output
        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        // Create a pipe to redirect the error output
        let errorPipe = Pipe()
        task.standardError = errorPipe

        try task.run()


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
