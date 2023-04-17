//
//  main.swift
//  xTermRunner
//
//  Created by Chris Dillard on 4/16/23.
//

import Foundation

import Foundation

//
// let comArr = ["-c", "/opt/X11/bin/xwininfo", "-id", "\(windowID)", "-root", "-tree", "-all", "-frame", "-shape" ,"-extents", "-size" ,"-stats", "-wm", "-events", "-version"]

//let task = Process()
//task.executableURL = URL(fileURLWithPath: "/opt/X11/bin/xwininfo")
//
//// Set the environment variable DISPLAY for the child process
//task.environment = ProcessInfo.processInfo.environment
//task.environment?["DISPLAY"] = ":0"
//let arguments = CommandLine.arguments
//var windowID = ""
//if arguments.count > 1 {
//    let arg1 = arguments[1]
//    print("The first argument is: \(arg1)")
//    windowID = arg1
//    task.arguments = ["-id", "\(windowID)", "-root", "-tree", "-all", "-frame", "-shape", "-size" ,"-stats", "-wm", "-events", "-version"]
//
//} else {
//    task.arguments = ["-root", "-tree"]
//}
//
//
//let outputPipe = Pipe()
//task.standardOutput = outputPipe
//
//do {
//    try task.run()
//    task.waitUntilExit()
//
//    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
//    if let output = String(data: outputData, encoding: .utf8) {
//        print("xwininfo output:")
//        print(output)
//    } else {
//        print("Error: Unable to read output.")
//    }
//} catch {
//    print("Error: \(error.localizedDescription)")
//}



//It seems like the primary issue is that the code isn't explicitly set up to handle and return an image. You mentioned that you want the code to return an image when there is an argument for a window ID, but the provided code only prints xwininfo output to the console.
//
//To return an image, you can use the 'import' command provided by the ImageMagick suite. Make sure you have ImageMagick installed on your system. You can install it using the following command for macOS:
//
//sh
//
//brew install imagemagick
//
//Next, you can modify your code to use the 'import' command to capture a screenshot of the specified window ID and save it as an image file. Here's an example of how to modify your code:
//
//swift

import Foundation

let task = Process()
//task.executableURL = URL(fileURLWithPath: "/opt/X11/bin/xwininfo")

//task.executableURL = URL(fileURLWithPath: "/opt/X11/bin/xterm")

// Set the arguments to run the command in the XTerm terminal
//task.arguments = ["-e", command]

// Set the environment variable DISPLAY for the child process
task.environment = ProcessInfo.processInfo.environment
task.environment?["DISPLAY"] = ":0"


// Set the environment variable DISPLAY for the child process
//task.environment = ProcessInfo.processInfo.environment
//task.environment?["DISPLAY"] = ":0"
let arguments = CommandLine.arguments
var windowID = ""
if arguments.count > 1 {
    task.executableURL = URL(fileURLWithPath: "/opt/X11/bin/xwininfo")

    let arg1 = arguments[1]
    print("The first argument is: \(arg1)")
    windowID = arg1
        task.arguments = [ "-id", "\(windowID)", "-root", "-tree", "-all", "-frame", "-shape" ,"-size", "-stats" ,"-wm", "-events"]
} else {
    task.executableURL = URL(fileURLWithPath: "/opt/X11/bin/xwininfo")

    task.arguments = ["-root", "-tree"]
}

let outputPipe = Pipe()
task.standardOutput = outputPipe

task.standardError = outputPipe

do {
    try task.run()
    task.waitUntilExit()

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: outputData, encoding: .utf8) {
        print("xwininfo output:")
        print(output)

        if !windowID.isEmpty {
            let imageTask = Process()
            imageTask.executableURL = URL(fileURLWithPath: "/usr/local/bin/import")
            imageTask.arguments = ["-window", "\(windowID)", "output.png"]
            try imageTask.run()
            imageTask.waitUntilExit()
            print("Screenshot saved as output.png")
        }
    } else {
        print("Error: Unable to read output.")
    }
} catch {
    print("Error: \(error.localizedDescription)")
}
