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
    case runProject(name: String)

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
        case .runProject(name:  _):
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
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(name).xcodeproj"
        
        let nameSchemeComps = name.split(separator: "/")
        var scheme = name
        if nameSchemeComps.count > 1 {
            scheme = String(nameSchemeComps.last ?? "")
        }


        buildProject(projectPath: projectPath, scheme: scheme) { success, errors in
            if success {
                completion(true, [])
            } else {
                completion(false, errors)
            }
            // TODO: Fix this, its a hack, if it takes longer than 0.5 seconds to sync workspace, it will fail with 0 or old projectArray results.
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {

                // attempt to parse the project structure.
                parseProjectStructure(name: name)
            }
        }
    case .runProject(name: let name):
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(name).xcodeproj"

        let nameSchemeComps = name.split(separator: "/")
        var scheme = name
        if nameSchemeComps.count > 1 {
            scheme = String(nameSchemeComps.last ?? "")
        }

        runProject(projectPath: projectPath, scheme: scheme) { success, errors in
            if success {
                completion(true, [])
            } else {
                completion(false, errors)
            }

        }
    }
}

func runProject(projectPath: String, scheme: String, completion: @escaping (Bool, [String]) -> Void) {

    runXCRUNProject(projectPath: projectPath, scheme: scheme) { success, errors in
        if success {
            completion(true, [])

        } else {
            completion(false, errors)
        }

    }


}

struct Simulator {
    var UUID: String
    var name: String
    var iOSVersion: String
    var state: String
}

func parseSimulators(from output: String) -> [Simulator] {
    var simulators: [Simulator] = []
    var currentVersion: String?

    let lines = output.split(separator: "\n")
    for line in lines {
        if line.hasPrefix("--") {
            currentVersion = String(line.dropFirst(3).dropLast(3))
        } else if let version = currentVersion, !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let regex = try? NSRegularExpression(pattern: "\\s*(.+) \\(([^\\)]+)\\) \\(([^\\)]+)\\)", options: [])
            let nsLine = line as NSString

            if let match = regex?.firstMatch(in: String(line), options: [], range: NSRange(location: 0, length: nsLine.length)) {
                let name = nsLine.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
                let UUID = nsLine.substring(with: match.range(at: 2)).trimmingCharacters(in: .whitespaces)
                let state = nsLine.substring(with: match.range(at: 3)).trimmingCharacters(in: .whitespaces)

                let simulator = Simulator(UUID: UUID, name: name, iOSVersion: version, state: state)
                simulators.append(simulator)
            }
        }
    }

    return simulators
}


func runXCRUNProject(projectPath: String, scheme: String, completion: @escaping (Bool, [String]) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    
    
    task.arguments = [ "simctl", "list", "devices"]
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
        multiPrinter("Error running xcrun: \(error)")
        completion(false, [])
        dispatchSemaphore.signal()
    }
    
    // Wait for the terminationHandler to be called
    dispatchSemaphore.wait()
    
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8) ?? ""
    print("xcodebuild 1 output = " + output)
    
    
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    
    print("xcodebuild 1 error output = " + errorOutput)
    
    
    
    let simulators = parseSimulators( from: output)
    
    defer {
        completion(successful, config.globalErrors)
    }
    
    if simulators.isEmpty {
        print("No simulators found.")
        
    }
    else {
        for simulator in simulators {
            
            if simulator.name == "iPhone 14" {
                print("UUID for the device is: \(simulator.UUID)")

                openSimulatorApp { success, errors in
                    runXCRUNSimulatorProject(projectPath: projectPath, scheme: scheme, deviceUUID: simulator.UUID)  { success, errors in

                        buildProjectForSimulatorDestination(projectPath: projectPath, scheme: scheme, simUUID: simulator.UUID) { success, errors in
                            if success {
                                findApp(projectPath: projectPath, scheme: scheme) { appPath, errors in
                                    if !appPath.isEmpty {

                                        // FOUND BUILT APP NAME
                                        installApp(appPath: appPath, simUUID: simulator.UUID) { success, errors in
                                            if success {
                                                // completion(true, [])
                                                print("Successfully installed \(appPath) in \(simulator.UUID)")
                                            } else {
                                                print("Failed to install")
    //                                            return
                                            }
                                            // TODO: Fix to pass bundleID from on higher.
                                            let bundleId = "com.example.\(scheme)"
                                           // getBundleId(appPath: appPath, scheme: scheme) { bundleId, errors in
                                             //   if !bundleId.isEmpty {
                                                    print("Successfully RAN \(appPath) in \(simulator.UUID) and found bundleIO = \(bundleId)")

                                                    runApp(appPath: appPath, simUUID: simulator.UUID, bundleId: bundleId)  { success, errors in
                                                        if success {
                                                            completion(true, [])
                                                            print("Successfully RAN \(appPath) in \(simulator.UUID)")


                                                            // if we get here... try to show simulator
                                                            simulatorCommand(input: "")
                                                        } else {
                                                            completion(false, errors)

                                                            print("Failed to run.")

                                                        }
                                                    }
    //                                            }
    //                                            else {
    //                                                print("Failed to run simulator .app -- failing run")
    //                                                return
    //
    //                                            }



                                           // }
                                        }
                                    }
                                    else {
                                        print("failed to find .app -- failing run")
                                        return

                                    }
                                }
                            }
                            else {
                                print("failed to build project, failing run")
                                return

                            }

                        }
                    }
                }


                return

            }
            
        }
        
    }
    func runXCRUNSimulatorProject(projectPath: String, scheme: String, deviceUUID: String, completion: @escaping (Bool, [String]) -> Void) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        
        
        task.arguments = [ "simctl", "boot", deviceUUID]
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
            print("Error running xcrun boot sim: \(error)")
            completion(false, [])
            dispatchSemaphore.signal()
        }
        
        // Wait for the terminationHandler to be called
        dispatchSemaphore.wait()
        
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        
        print("xcrun output = " + output)
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        
        print("xcrun error output = " + errorOutput)
        
        completion(successful, config.globalErrors)
    }
    
    
    
    // RUN BUILD FOR SIMULATOR 2 //
    
    func buildProjectForSimulatorDestination(projectPath: String, scheme: String, simUUID: String, completion: @escaping (Bool, [String]) -> Void) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")
        
        let projectArgument = "-project"
        let schemeArgument = "-scheme"
        task.arguments = [projectArgument, projectPath, schemeArgument, scheme, "-sdk", "iphonesimulator", "-destination", "id=\(simUUID)", "-verbose", "-derivedDataPath", "build", "clean", "build"]

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
        
        print("sim build output = " + output)
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
        print("sim build error output = " + errorOutput)
        
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
}

// *.app file name must match Xcode project name and scheme name for now.
// TODO: Double check the case that the app name does not match the scheme name.
func findApp(projectPath: String, scheme: String, completion: @escaping (String, [String]) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/find")

    task.arguments = [ "build", "-name", scheme+".app"]

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
        completion("", [])
        dispatchSemaphore.signal()
    }

    // Wait for the terminationHandler to be called
    dispatchSemaphore.wait()


    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8) ?? ""

    print("FIND build output = " + output)

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    print("FIND build error output = " + errorOutput)

    completion(output, config.globalErrors)
}

func installApp(appPath: String, simUUID: String, completion: @escaping (Bool, [String]) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")


    task.arguments = [ "simctl", "install", simUUID, "./"+appPath.trimmingCharacters(in: .whitespacesAndNewlines)]
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
        print("Error running xcrun boot sim: \(error)")
        completion(false, [])
        dispatchSemaphore.signal()
    }

    // Wait for the terminationHandler to be called
    dispatchSemaphore.wait()


    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8) ?? ""

    print("xcrun INSTALL output = " + output)

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

    print("xcrun INSTALL error output = " + errorOutput)

    completion(successful, config.globalErrors)
}

func runApp(appPath: String, simUUID: String, bundleId: String, completion: @escaping (Bool, [String]) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")


    // TODO: FIx to pass the correct Info.plist bundleID fore the chosen Project.
    task.arguments = [ "simctl", "launch", simUUID, bundleId]
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
        print("Error running xcrun RUN: \(error)")
        completion(false, [])
        dispatchSemaphore.signal()
    }

    // Wait for the terminationHandler to be called
    dispatchSemaphore.wait()


    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8) ?? ""

    print("xcrun RUN output = " + output)

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

    print("xcrun RUN error output = " + errorOutput)

    completion(successful, config.globalErrors)
}


func getBundleId(appPath: String, scheme: String, completion: @escaping (String, [String]) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/libexec/PlistBuddy")
    
    let infoPlistPath = appPath.trimmingCharacters(in: .whitespacesAndNewlines)+"/Info.plist"

    task.arguments = [ "-c", "\"Print CFBundleIdentifier\"", infoPlistPath]

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
        completion("", [])
        dispatchSemaphore.signal()
    }

    // Wait for the terminationHandler to be called
    dispatchSemaphore.wait()


    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8) ?? ""

    print("FIND PLIST output = " + output)

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    print("FIND PLIST error output = " + errorOutput)

    completion(output, config.globalErrors)
}


func openSimulatorApp(completion: @escaping (String, [String]) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/open")

    task.arguments = [ "-a", "Simulator"]

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
        completion("", [])
        dispatchSemaphore.signal()
    }

    // Wait for the terminationHandler to be called
    dispatchSemaphore.wait()


    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8) ?? ""

    print("OPENSIM output = " + output)

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    print("OPENSIM error output = " + errorOutput)

    completion(output, config.globalErrors)
}



func parseProjectStructure(name: String) {
    let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(name).xcodeproj"
    do {
        let results = try processXcodeProject(path: projectPath)

        config.projectArray = results
        multiPrinter("Parsed project w result count = \(config.projectArray.count)")

        do {
            let jsonData = try JSONEncoder().encode(config.projectArray)
            localPeerConsole.sendProjectData(jsonData)
        }
        catch {
            print("error serializing projectArray")
        }
    }
    catch {
        print("error loading: \(error)")
    }
}
