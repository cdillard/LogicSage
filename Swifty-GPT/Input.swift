//
//  Input.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

func promptUserInput(message: String) -> String? {
    print(message, terminator: "")
    return readLine()
}

import Foundation
import Darwin

func setRawMode(file: UnsafeMutablePointer<FILE>) {
    var raw: termios = termios()
    tcgetattr(fileno(file), &raw)
    raw.c_lflag &= ~(UInt(ECHO | ICANON))
    tcsetattr(fileno(file), TCSAFLUSH, &raw)
}

func unsetRawMode(file: UnsafeMutablePointer<FILE>) {
    var raw: termios = termios()
    tcgetattr(fileno(file), &raw)
    raw.c_lflag |= (UInt(ECHO | ICANON))
    tcsetattr(fileno(file), TCSAFLUSH, &raw)
}

func readCharacter() -> Character? {
    setRawMode(file: stdin)
    let c = fgetc(stdin)
    unsetRawMode(file: stdin)

    if c == EOF {
        return nil
    }
    return Character(UnicodeScalar(UInt32(bitPattern: c))!)
}

func handleUserInput() {
    var command = ""
    var parameter = ""

    let inputQueue = DispatchQueue(label: "inputQueue")

    inputQueue.async {
        while let char = readCharacter() {
            if char >= "0" && char <= "6" {
                command = String(char)
                if let selectedCommand = commandTable[command] {
                    selectedCommand(parameter.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    print("Invalid command. Please try again:")
                }
                command = ""
                parameter = ""
            } else if char == " " {
                // command prefix is complete, start reading parameter
                while let nextChar = readCharacter() {
                    if nextChar == "\n" {
                        break
                    }
                    if nextChar != "\"" { // Ignore double quotes
                        parameter.append(nextChar)
                    }
                }

                if let selectedCommand = commandTable[command] {
                    selectedCommand(parameter.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    print("Invalid command. Please try again:")
                }

                command = ""
                parameter = ""
            } else if char == "\n" {
                if let selectedCommand = commandTable[command] {
                    selectedCommand(parameter.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    print("Invalid command. Please try again:")
                }

                command = ""
                parameter = ""
            } else {
                command.append(char)
            }
        }
    }
}

