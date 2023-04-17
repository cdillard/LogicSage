//
//  Speak.swift
//  
//
//  Created by Chris Dillard on 4/15/23.
//

// Only say Swifty-GPT the fist time they open

// SPEAK

import Foundation

let wpm = "200"

let concurrentVoicesLimit = 2
var concurrentVoices = 0

let customFemaleName = "Sage"
let customMaleName = "Data"

var sayProcess = Process()

func stopSayProcess() {
    // Send the signal to the process
    kill(sayProcess.processIdentifier, SIGTERM)
}

func runTest() {

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    let currentTime = dateFormatter.string(from: Date())
    let greeting = welcomeWord()

    textToSpeech(text: "\(greeting). Welcome! It's \(currentTime). I'm \(voice()) and I'm your A.I.")
}

func textToSpeech(text: String) {

    if !voiceOutputEnabled { return }

    if  concurrentVoices > concurrentVoicesLimit {
        stopSayProcess()
    }


    sayProcess = Process()
    sayProcess.executableURL = URL(fileURLWithPath: "/usr/bin/say")
    sayProcess.arguments = ["[[rate \(wpm)]]\(text)", "-v", voice(), "-r", wpm]

    let outputPipe = Pipe()
    sayProcess.standardOutput = outputPipe

    let errorPipe = Pipe()
    sayProcess.standardError = errorPipe

    
    do {
        try sayProcess.run()
        concurrentVoices += 1
        sayProcess.waitUntilExit()

        sayProcess.terminationHandler =  { result in
            concurrentVoices -= 1

        }
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""


        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

    } catch {
        print("Error running text-to-speech: \(error)")
    }
}

func welcomeWord() -> String {
    if Int.random(in: 0...1) == 0 {
        return "Hi"
    }
    else {
        return "Hello"
    }
}
