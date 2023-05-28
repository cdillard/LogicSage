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

func buildProject(projectPath: String, scheme: String, completion: @escaping (Bool, [String]) -> Void) {
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
        multiPrinter("Error running xcodebuild: \(error)")
        completion(false, [])
        dispatchSemaphore.signal()
    }

    // Wait for the terminationHandler to be called
    dispatchSemaphore.wait()

    func getErrorLines(_ input: String) -> [String] {
        let lines = input.split(separator: "\n")
        let errorLinePattern = "^(\\/[^\\s]+):(\\d+):(\\d+):\\s+error:\\s+(.+)$"
        let regex = try! NSRegularExpression(pattern: errorLinePattern, options: [])

        var errorLines: [String] = []

        for line in lines {
            let nsLine = line as NSString
            let matches = regex.matches(in: nsLine as String, options: [], range: NSRange(location: 0, length: nsLine.length))

            if !matches.isEmpty {
                errorLines.append(nsLine as String)
            }
        }

        return errorLines
    }

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8) ?? ""
    let errors = getErrorLines(output)


    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

    let errors2 = getErrorLines(errorOutput)
    if !errors2.isEmpty {
        multiPrinter("Build Errors: \(  errors2)")
    }
    else {
        if !errors.isEmpty {
            multiPrinter("Error: \(errorOutput)")
        }
    }
    if !errors.isEmpty {
        multiPrinter("Build ❌ : \(  errors)")
    }
    else {
       // multiPrinter("Build Output: \(  output)")
    }
    var errorsCopy = Array(errors)
    errorsCopy = errorsCopy.map {
        $0.replacingOccurrences(of: getWorkspaceFolder(), with: "")
    }
    .map {
        $0.replacingOccurrences(of: "\(swiftyGPTWorkspaceName)/\(config.projectName)/Sources/", with: "")
    }
    
    config.globalErrors += Array(errorsCopy)
    completion(successful, config.globalErrors)
}


func executeXcodeCommand(_ command: XcodeCommand, completion: @escaping (Bool, [String]) -> Void) {
    switch command {
    case let .openProject(name):
        executeAppleScriptCommand(.openProject(name: config.projectName)) {
            success, errors in
            completion(success, config.globalErrors)
        }
    case let .createProject(name):
        multiPrinter("Creating project with name: \(name)")
        config.projectName = name.isEmpty ? "MyApp" : name
        config.projectName = preprocessStringForFilename(config.projectName)
        multiPrinter("set current name")
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/"

        createNewProject(projectName: name, projectDirectory: projectPath) { success in
            completion(success, config.globalErrors)
        }

    case .closeProject(name: let name):
        executeAppleScriptCommand(.closeProject(name: name)) { success, errors in

        }
        completion(true, config.globalErrors)

    case .createFile(fileName: let fileName, fileContents: let fileContents):
        if config.projectName.isEmpty {
            multiPrinter("missing proj, creating one... ****danger****")
            config.projectName = "MyApp"

            // MIssing projecr gen// create a proj
            executeXcodeCommand(.createProject(name: config.projectName)) { success, errors in
                if success {
                    completion(true, [])
                } else {
                    multiPrinter("createProject failed")

                    completion(false, errors)
                }
            }
        }
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(config.projectName)"
        let filePath = "\(projectPath)/Sources/\(fileName)"
        multiPrinter("Adding file w/ path: \(filePath) w/ contents w length = \(fileContents.count) to p=\(projectPath)")
        let added = createFile(projectPath: "\(projectPath).xcodeproj", projectName: config.projectName, targetName: config.projectName, filePath: filePath, fileContent: fileContents)
        completion(added, [])

    case .buildProject(name: let name):
        multiPrinter("buildProject project with name: \(name)")
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(config.projectName).xcodeproj"

        buildProject(projectPath: projectPath, scheme: config.projectName) { success, errors in
            if success {
                completion(true, [])
            } else {
                completion(false, errors)
            }
        }
    }
}
