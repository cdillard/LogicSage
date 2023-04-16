//
//  TextAnimator.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//


import Foundation

class TextAnimator {
    private let text: String
    private let animationDuration: TimeInterval
    private var characterDelays: [TimeInterval]
    private var displayString: [Character]
    private let animationInterval: TimeInterval = 0.1
    private let startTime: TimeInterval
    private var timer: Timer?

    init(text: String, animationDuration: TimeInterval) {
        self.text = text
        self.animationDuration = animationDuration
        self.startTime = Date().timeIntervalSinceReferenceDate

        let characterCount = self.text.count
        self.characterDelays = Array(repeating: 0.0, count: characterCount)
        self.displayString = Array(repeating: " ", count: characterCount)

        let delayStep = animationDuration / TimeInterval(characterCount)
        var currentDelay: TimeInterval = 0

        for (index, _) in self.text.enumerated() {
            self.characterDelays[index] = currentDelay
            currentDelay += delayStep
        }
    }

    func start() {
        timer = Timer.scheduledTimer(timeInterval: animationInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: animationDuration + animationInterval))
        stop()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func update(timer: Timer) {
        let elapsedTime = Date().timeIntervalSinceReferenceDate - startTime

        for (index, character) in text.enumerated() {
            if elapsedTime >= characterDelays[index] {
                displayString[index] = character
            }
        }

//        print("\u{001B}[2J", terminator: "") // Clear console
        print(String(displayString))

        fflush(stdout)
    }
}
