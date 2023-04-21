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
    var matrixAnim: MatrixAnimation?
    init(text: String) {
        self.text = text
    }

    func start() {
        blockingInput = true
        stopped = false

        // Randomly choose between ASCII gifs
        //animateAscii()

        matrixAnim = MatrixAnimation()
        matrixAnim?.start()
    }

    func stop() {
        stopped = true
        matrixAnim?.stop()
        matrixAnim = nil

        blockingInput = false
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




    class MatrixAnimation {
        private let timer: DispatchSourceTimer
        private var isRunning: Bool

        init() {
            timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            isRunning = false
        }

        func generateRandomCharacter() -> String {
            let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
            let randomIndex = Int(arc4random_uniform(UInt32(characters.count)))
            let randomCharacter = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            return String(randomCharacter)
        }

        func generateMatrixLine() -> String {
            let screenWidth = 160
            var line = ""

            for _ in 0..<screenWidth {
                if arc4random_uniform(100) < 10 {
                    line += generateRandomCharacter()
                } else {
                    line += " "
                }
            }

            return line
        }

        func start() {
            guard !isRunning else { return }
            isRunning = true

            let delay: TimeInterval = 0.25

            timer.schedule(deadline: .now(), repeating: delay)
            timer.setEventHandler { [weak self] in
                guard let self = self else { return }

                if !self.isRunning {
                    return
                }

                let line = self.generateMatrixLine()
                print("\(line)")
            }

            timer.resume()
        }

        func stop() {
            isRunning = false
        }
    }
}

