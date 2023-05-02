//
//  Multiprinter.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 5/1/23.
//

import Foundation
func multiPrinter(_ items: Any...,  separator: String = " ", terminator: String = "\n") {
    multiPrinter3(items, separator: separator, terminator: terminator)
    multiPrinter2(items, separator: separator, terminator: terminator)
     for username in [ "hackerman"] {

        if !swiftSageIOSEnabled {
            print(items, separator: separator, terminator: terminator)
            return
        }

        if items.count == 1, let singleString = items.first as? String {
            print(items, separator: separator, terminator: terminator)
            localPeerConsole.sendLog(to: username, text: singleString)
            return
        }
        // Otherwise, handle the items as a collection of strings
        for item in items {
            if let str = item as? String {
                print(str, separator: separator, terminator: terminator)
                localPeerConsole.sendLog(to: username, text: str)
            }
        }
    }
}
func multiPrinter2(_ items: Any...,  separator: String = " ", terminator: String = "\n") {
     for username in [ "chris"] {

        if !swiftSageIOSEnabled {
            print(items, separator: separator, terminator: terminator)
            return
        }

        if items.count == 1, let singleString = items.first as? String {
            print(items, separator: separator, terminator: terminator)
            localPeerConsole.sendLog(to: username, text: singleString)
            return
        }
        // Otherwise, handle the items as a collection of strings
        for item in items {
            if let str = item as? String {
                print(str, separator: separator, terminator: terminator)
                localPeerConsole.sendLog(to: username, text: str)
            }
        }
    }
}

func multiPrinter3(_ items: Any...,  separator: String = " ", terminator: String = "\n") {
     for username in [ "chuck"] {

        if !swiftSageIOSEnabled {
            print(items, separator: separator, terminator: terminator)
            return
        }

        if items.count == 1, let singleString = items.first as? String {
            print(items, separator: separator, terminator: terminator)
            localPeerConsole.sendLog(to: username, text: singleString)
            return
        }
        // Otherwise, handle the items as a collection of strings
        for item in items {
            if let str = item as? String {
                print(str, separator: separator, terminator: terminator)
                localPeerConsole.sendLog(to: username, text: str)
            }
        }
    }
}
