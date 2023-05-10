//
//  Terminal.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation
import Darwin
func getTerminalWidth() -> Int? {
    var windowSize = winsize()
    if ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &windowSize) == 0 {
        return Int(windowSize.ws_col)
    } else {
        return nil
    }
}
