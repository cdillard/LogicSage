//
//  ApplescriptCommand.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/19/23.
//

import Foundation


// Function to execute an high level Xcode Shell/ Ruby / AppleScript command
func executeAppleScriptCommand(_ command: XcodeCommand, completion: @escaping (Bool, [String]) -> Void) {
    if !command.appleScript.isEmpty {

        let appleScriptCommand = command.appleScript
        let script = NSAppleScript(source: appleScriptCommand)
        var errorDict: NSDictionary? = nil
        multiPrinter("Executing AppleScript: \(command)")

        script?.executeAndReturnError(&errorDict)
        if let error = errorDict {
            multiPrinter("AppleScript Error: \(error)")
            completion(false,[error.description])
        }
        else {
            completion(true, [])
        }
    } else {
        multiPrinter("Unsupported command")
        completion(false, config.globalErrors)
    }
}
