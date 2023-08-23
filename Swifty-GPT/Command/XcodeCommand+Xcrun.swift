//
//  XcodeCommand+Xcrun.swift
//  LogicSageCommandLine
//
//  Created by Chris Dillard on 8/21/23.
//

import Foundation

func installApp(appPath: String, simUUID: String, completion: @escaping (Bool, [String]) -> Void) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")


    task.arguments = [ "simctl", "install", simUUID, "./"+appPath.trimmingCharacters(in: .whitespacesAndNewlines)]

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
