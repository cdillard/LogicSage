//
//  TextAnimator.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//


import Foundation

class TextAnimator {
    private let text: String

    var stopped = true

    init(text: String) {
        self.text = text
    }

    func start() {
        stopped = false
        animateAscii()
    }

    func stop() {
        stopped = true
    }

    func animateAscii(frameDelay: TimeInterval = 0.03, repetitions: Int = 1, consoleHeight: Int = 25) {
        for _ in 0..<repetitions {
            for char in text {
                print(char, terminator: "")
                fflush(stdout)
                usleep(useconds_t(frameDelay * 1_000_000))

                if stopped { return }
            }
            print(String(repeating: "\n", count: consoleHeight))
        }
    }
}

