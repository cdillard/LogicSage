//
//  TextAnimator.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//


import Foundation

class TextAnimator {
    private let asciiArt: [String]
    private let animationDuration: TimeInterval
    private var characterDelays: [[TimeInterval]]
    private var displayGrid: [[Character]]
    private let animationInterval: TimeInterval = 0.05
    private let startTime: TimeInterval
    private var timer: Timer?

    init(asciiArt: String, animationDuration: TimeInterval) {
        self.asciiArt = asciiArt.split(separator: "\n").map(String.init)
        self.animationDuration = animationDuration
        self.startTime = Date().timeIntervalSinceReferenceDate

        let rowCount = self.asciiArt.count
        let columnCount = self.asciiArt.map { $0.count }.max() ?? 0
        self.characterDelays = Array(repeating: Array(repeating: 0.0, count: columnCount), count: rowCount)
        self.displayGrid = Array(repeating: Array(repeating: " ", count: columnCount), count: rowCount)

        let totalCharacters = self.asciiArt.map { $0.count }.reduce(0, +)
        let delayStep = animationDuration / TimeInterval(totalCharacters)
        var currentDelay: TimeInterval = 0

        for (rowIndex, row) in self.asciiArt.enumerated() {
            for (columnIndex, _) in row.enumerated() {
                self.characterDelays[rowIndex][columnIndex] = currentDelay
                currentDelay += delayStep
            }
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

        for (rowIndex, row) in asciiArt.enumerated() {
            for (columnIndex, character) in row.enumerated() {
                if elapsedTime >= characterDelays[rowIndex][columnIndex] {
                    displayGrid[rowIndex][columnIndex] = character
                }
            }
        }

        print("\u{001B}[2J", terminator: "") // Clear console
        for row in displayGrid {
            print(String(row))
        }
    }
}
