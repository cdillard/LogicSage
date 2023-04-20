//
//  Speak.swift
//  
//
//  Created by Chris Dillard on 4/15/23.
//

// Only say Swifty-GPT the fist time they open

// SPEAK

import Foundation

let wpm = "244"

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
    let hour = Calendar.current.component(.hour, from: Date())
    var greeting1 = "Welcome"
    switch hour {
    case 6..<12 : greeting1 = "Good Morning"
    case 12 : greeting1 = "It's Noon"
    case 13..<17 : greeting1 = "Good Afternoon"
    case 17..<22 : greeting1 = "Good Evening"
    default: greeting1 = "Good Night"
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h"
    // presise time setting let currentTime = dateFormatter.string(from: Date().round(precision: 60 * 60))
    textToSpeech(text: "\(welcomeWord()). \(greeting1)! I'm \( !customMaleName.isEmpty ? customMaleName : voice()) and I'm \(noun()).")
}

func noun() -> String {
    switch Int.random(in: 0...5)
    {
    case 0:
        return  "your A.I."
    case 1:
        return "online."
    case 2:
        return "ready."
    case 3:
        return "in the mood to code."
    case 4:
        return "here to help."
    default:
        return "here."
    }
}

public extension Date {

    func round(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .toNearestOrAwayFromZero)
    }
    
    private func round(precision: TimeInterval, rule: FloatingPointRoundingRule) -> Date {
        let seconds = (self.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision;
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
}

func textToSpeech(text: String, overrideVoice: String? = nil, overrideWpm: String? = nil) {

    addSpeakTask(text: text, overrideVoice: overrideVoice, overrideWpm: overrideWpm)
}

func welcomeWord() -> String {
    if Int.random(in: 0...1) == 0 {
        return "Hi"
    }
    else {
        return "Hello"
    }
}

func killAllVoices() {

    stopSayProcess()

    let killProcess = Process()
    killProcess.launchPath = "/bin/zsh"

    killProcess.arguments = ["-c", "killall", "say"]

    let outputPipe = Pipe()
    killProcess.standardOutput = outputPipe

    let errorPipe = Pipe()
    killProcess.standardError = errorPipe


    do {
        try killProcess.run()
    }
    catch {
        print("error = \(error)")
    }
}


func addSpeakTask(text: String, overrideVoice: String? = nil, overrideWpm: String? = nil){

            if !voiceOutputEnabled { return }

            if  concurrentVoices > concurrentVoicesLimit {
                stopSayProcess()
            }

            sayProcess = Process()
            sayProcess.executableURL = URL(fileURLWithPath: "/usr/bin/say")


            var voice = voice()
            if overrideVoice != nil && overrideVoice?.isEmpty == false {
                voice = overrideVoice!
            }
            var useWpm = wpm
            if overrideWpm != nil && overrideWpm?.isEmpty == false {
                useWpm = overrideWpm!
            }

            sayProcess.arguments = ["[[rate \(useWpm)]]\(text)", "-v", voice, "-r", useWpm]

            print("say: \(text)")
            let outputPipe = Pipe()
            sayProcess.standardOutput = outputPipe

            let errorPipe = Pipe()
            sayProcess.standardError = errorPipe


            do {
                try sayProcess.run()
                concurrentVoices += 1

                sayProcess.terminationHandler =  { result in
                    concurrentVoices -= 1

                }
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: outputData, encoding: .utf8) ?? ""


                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                // print("sayText: \(output), errorOutput: \(errorOutput)")

            } catch {
                print("Error running text-to-speech: \(error)")
            }
}
