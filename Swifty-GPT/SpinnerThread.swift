//
//  SpinnerThread.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//
import Foundation

import Foundation

struct LoadingSpinner {
    static let spinners: [[String]] = [
        ["🔺", "🔻", "◀️", "▶️", "🔼", "🔽", "⏪", "⏩"],
        ["🔴", "🟠", "🟡", "🟢", "🔵", "🟣", "🟤", "⚫️"],
        ["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"],
        ["◢", "◣", "◤", "◥"],
        ["○", "◔", "◑", "◕", "●"],
        ["⢿", "⡿", "⣿", "⣯", "⣷", "⣾", "⣽", "⢻"],
        ["░", "▒", "▓", "█"],
        ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "▇", "▆", "▅", "▄", "▃", "▂", "▁"],
        ["▖", "▘", "▝", "▗"],
        ["△", "▶", "▽", "◀"],
        ["⚀", "⚁", "⚂", "⚃", "⚄", "⚅"],
        ["◢", "⭘", "◣", "⭘", "◤", "⭘", "◥", "⭘", "◢", "⭘", "◣", "⭘", "◣", "⭘", "◥",],
        ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "☺️", "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "😘", "😗", "😙", "😚", "😋", "😜", "😝", "😛", "🤑", "🤗", "🤔", "🤐", "😐", "😑", "😶", "😏", "😒", "😰", "😱", "🥵", "😳", "🤪", "😵", "😡", "😠", "🤬", "😷", "🤒", "🤕", "🤢", "🤮", "🤧", "😇", "🥴", "🥺", "🤠", "🥳", "😎", "🤓", "🧐", "😕", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳", "🥺", "😦", "😧", "😨", "😰", "😥", "😢", "😭", "😩", "😖", "😣", "😞", "😓", "😩", "😫", "😤", "😡", "😠", "🤬", "😈", "👿", "👹", "👺", "💀", "☠️", "👻", "👽", "👾", "🤖", "😺"].shuffled(),  ["🌈", "🎉", "🎆", "🚀", "🌠", "💥", "🌞", "🌛", "⭐️", "🌟", "✨", "💫", "🌍", "💎", "🔥", "🍭", "🍄", "🍀", "🌻", "🌸", "💐", "🌺", "🌷", "🌼", "🌹", "🐬", "🦋", "🐳", "🦄", "🐉", "🐲", "🌈", "🎉", "🎆", "🚀", "🌠", "💥", "🌞", "🌛", "⭐️", "🌟", "✨", "💫", "🌍", "💎", "🔥", "🍭", "🍄", "🍀", "🌻", "🌸", "💐", "🌺", "🌷", "🌼", "🌹", "🐬", "🦋", "🐳", "🦄", "🐉", "🐲"].shuffled(),
    ]

    private var spinnerArray: [String]
    private let columnCount: Int

    init(columnCount: Int, spinnerIndex: Int? = nil) {
        let index = spinnerIndex ?? Int.random(in: 0..<Self.spinners[spinnerIndex!].count)
        self.spinnerArray = Self.spinners[index]
        self.columnCount = columnCount
    }

    func start() {
        guard spinnerTherad == nil else { return }

        spinnerTherad = Thread {
            while !Thread.current.isCancelled {
                let columnIndex = spinnerIndex % self.columnCount
                _ = String(repeating: " ", count: columnIndex)
                print("\(self.spinnerArray[spinnerIndex % self.spinnerArray.count])", terminator: "")
                fflush(stdout)
                spinnerIndex = (spinnerIndex + 1) % (self.spinnerArray.count * self.columnCount)
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        spinnerTherad?.start()
    }

    mutating func stop() {
        spinnerTherad?.cancel()
        spinnerTherad = nil
        spinner = LoadingSpinner(columnCount: 5)

    }
}
var spinnerIndex = 0
var spinnerTherad: Thread?
