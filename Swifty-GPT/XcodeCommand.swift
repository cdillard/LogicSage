//
//  XcodeCommand.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/10/23.
//

import Foundation

enum XcodeCommand {
    case openProject(name: String)
    case createProject(name: String)
    case closeProject(name: String)
    case buildProject(name: String)

    case createFile(fileName: String, fileContents: String)
    // Add other cases here

    var appleScript: String {
        switch self {
        case .openProject(let name):
            let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(name).xcodeproj"

            return """
            tell application "Xcode"
                activate
                set projectPath to "\(projectPath)"
                open projectPath
            end tell
            """

        case .closeProject(let name):
            return """
            tell application "Xcode"
                activate
                set projectNameToClose to "\(name)"

                repeat with i from 1 to (count documents)
                    set documentPath to path of document i
                    if documentPath contains projectNameToClose then
                        close document i
                        exit repeat
                    end if
                end repeat
            end tell
            """
        case .createProject(name:  _):
            return ""
        case .createFile(fileName:  _, fileContents:  _):
            return ""
        case .buildProject(name:  _):
            return ""
        }
    }
}


func buildProject(projectPath: String, scheme: String, completion: @escaping (Bool) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")

    let projectArgument = "-project"
    let schemeArgument = "-scheme"
    task.arguments = [projectArgument, projectPath, schemeArgument, scheme, "-sdk", "iphonesimulator", "-destination", "name=iPhone 14", "-verbose"]
 //  "-IDEBuildingContinueBuildingAfterErrors=YES",

    
    let outputPipe = Pipe()
    task.standardOutput = outputPipe

    let errorPipe = Pipe()
    task.standardError = errorPipe

    let dispatchSemaphore = DispatchSemaphore(value: 1)
    var successful = false
    task.terminationHandler = { process in
        let success = process.terminationStatus == 0
        successful = success
        dispatchSemaphore.signal()
    }

    do {
        try task.run()
    } catch {
        print("Error running xcodebuild: \(error)")
        completion(false)
        dispatchSemaphore.signal()
    }

    // Wait for the terminationHandler to be called
    dispatchSemaphore.wait()


    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8)
    print("Output: \(output ?? "")")

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8)
    print("Error: \(errorOutput ?? "")")

    completion(successful)

}
