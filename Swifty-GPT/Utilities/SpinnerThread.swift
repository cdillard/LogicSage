//
//  SpinnerThread.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//
import Foundation

import Foundation

func spinners() -> [[String]] {
    switch loadMode {
    case .dots:
        return [["."]]
    case .waves:
        return [["▁", "▂", "▃", "▄", "▅", "▆", "▇", "▇", "▆", "▅", "▄", "▃", "▂", "▁"]]
    case .bar:
        return [["░", "▒", "▓", "█","░", "▒","▓", "█","░", "▒","░", "▒", "▓", "█","░"]]
    case .matrix:
        return [["."]]
    case .none:
        return [["."]]
    }
}

class LoadingSpinner {

    private var spinner: [String]
    private var index = 0
    private var thread: Thread?
    private let columnCount: Int

    init(columnCount: Int, spinDex: Int) {
        let index = Int.random(in: 0..<spinners().count)
        self.spinner = spinners()[index]
        self.columnCount = columnCount
    }

    func start() {
        guard thread == nil else { return }

        thread = Thread {
            while !Thread.current.isCancelled {
                let columnIndex = self.index % self.columnCount
                _ = String(repeating: " ", count: columnIndex)
                multiPrinter("\(self.spinner[self.index % self.spinner.count])", terminator: "")
                fflush(stdout)
                self.index = (self.index + 1) % (self.spinner.count * self.columnCount)
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        blockingInput = true

        if loadMode == .none { return }

        thread?.start()
    }

    func stop() {
        guard thread != nil else { return }
        
        blockingInput = false
        thread?.cancel()
        thread = nil
    }

    func getSpindex(input: String) -> Int {

        var spinDex = 0
        switch loadMode {
        case .dots:
            spinDex = 0
        case .waves:
            spinDex = 1
        case .bar:
            spinDex = 2
        case .matrix:
            spinDex = 3
        case .none:
            spinDex = 4

        }
        return spinDex


    }
}
