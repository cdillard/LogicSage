//
//  LocalCommand.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/2/23.
//

import Foundation

//func executeLocalCommand(command: String, args: )  {
//    switch command {
//    case "g", "G" :
//        gptCommand(input: <#T##String#>)
//        break
//    case "open":
//        logD("Opening new file...")
//
//        return
//    case "st":
//        logD("client executed stop...")
//        stopVoice()
//    default:
//        logD("unknown cmd: \(command)")
//        break
//    }
//}
func callLocalCommand(_ command: String) -> Bool {
    logD("SWIFTSAGE: \(command)")

    if command == "Hello" { return true }
    // HERE WE HANDLE LOCAL COMANDS
    if command == "st" { stopVoice() ; stopRandomSpinner() ; return true  }

    let commandSplit = command.split(separator: " ", maxSplits: 1)

    if !commandSplit.isEmpty {
        var comp2 = ""
        if commandSplit.count > 1 {
            comp2 = String(commandSplit[1])
        }

        let selectedCommand = String(commandSplit[0])
        let args = comp2

        if let selectedCommand = commandTable[selectedCommand] {
            selectedCommand(args)
            return true

        } else {
            // Oh boy, TODO: Fix the millions of robots chorus bug that seems to happen w/ wrong combo of server start, binary start, app start.
           // textToSpeech(text: "Invalid command. Exec c for help")

        }
    }

    logD("Invalid sws command. Please try again. (c) for help")

    return false
}
