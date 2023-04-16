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

func runTest() {

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    let currentTime = dateFormatter.string(from: Date())

    textToSpeech(text: "\((Int.random(in: 0...1) != 0) ? "Hi" : "Hello")! Welcome! It's about \(currentTime). I'm \(voice()) and I'll be your A.I.")
}

func textToSpeech(text: String) {
    if !voiceOutputEnabled { return }

    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/say")
    task.arguments = ["[[rate \(wpm)]]\(text)", "-v", voice(), "-r", wpm]

    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        print("Error running text-to-speech: \(error)")
    }
}
