//
//  SpinnerThread.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//
import Foundation

import Foundation

class LoadingSpinner {
    static let spinners: [[String]] = [
        ["░", "▒", "▓", "█","░", "▒","▓", "█","░", "▒","░", "▒", "▓", "█","░"],
        ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "▇", "▆", "▅", "▄", "▃", "▂", "▁"],
    ]

    private var spinner: [String]
    private var index = 0
    private var thread: Thread?
    private let columnCount: Int

    init(columnCount: Int) {
        let index = Int.random(in: 0..<Self.spinners.count)
        self.spinner = Self.spinners[index]
        self.columnCount = columnCount
    }

    func start() {
        guard thread == nil else { return }

        thread = Thread {
            while !Thread.current.isCancelled {
                let columnIndex = self.index % self.columnCount
                _ = String(repeating: " ", count: columnIndex)
                print("\(self.spinner[self.index % self.spinner.count])", terminator: "")
                fflush(stdout)
                self.index = (self.index + 1) % (self.spinner.count * self.columnCount)
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        blockingInput = true
        thread?.start()
    }

    func stop() {
        guard thread != nil else { return }
        
        blockingInput = false
        thread?.cancel()
        thread = nil
    }
}
