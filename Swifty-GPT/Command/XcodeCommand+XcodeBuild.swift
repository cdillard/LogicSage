//
//  XcodeCommand+XcodeBuild.swift
//  LogicSageCommandLine
//
//  Created by Chris Dillard on 8/21/23.
//

import Foundation

func buildProject(projectPath: String, scheme: String, device: String = "iPhone 15 Pro Max", completion: @escaping (Bool, [String]) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")

    let projectArgument = "-project"
    let schemeArgument = "-scheme"
    task.arguments = [projectArgument, projectPath, schemeArgument, scheme, "-sdk", "iphonesimulator", "-destination", "name=\(device)", "-verbose"]
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
       // if !errors.isEmpty {
            multiPrinter("Error: \(errorOutput)")
       // }
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



func testProjectForSimulatorDestination(projectPath: String, scheme: String, simUUID: String, completion: @escaping (Bool, [String]) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")

    let projectArgument = "-project"
    let schemeArgument = "-scheme"
    task.arguments = [projectArgument, projectPath, schemeArgument, scheme, "-sdk", "iphonesimulator", "-destination", "id=\(simUUID)", "-verbose", "-derivedDataPath", "build", "clean", "test"]

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


    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8) ?? ""
    let errors = getErrorLines(output)

    print("sim TEST output = " + output)

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    print("sim TEST error output = " + errorOutput)

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
