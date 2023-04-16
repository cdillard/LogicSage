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

//func readCharacter() -> Character? {
//    setRawMode(file: stdin)
//    let c = fgetc(stdin)
//    unsetRawMode(file: stdin)
//
//    if c == EOF {
//        return nil
//    }
//    return Character(UnicodeScalar(UInt32(bitPattern: c))!)
//}

func setupTermios() -> termios {
    var term = termios()
    tcgetattr(STDIN_FILENO, &term)

    let oldTerm = term
    term.c_lflag &= ~(UInt(ECHO | ICANON))
    term.c_cc.0 = 1
    term.c_cc.1 = 0

    tcsetattr(STDIN_FILENO, TCSANOW, &term)

    return oldTerm
}

func restoreTermios(oldTerm: termios) {
    var term = oldTerm
    tcsetattr(STDIN_FILENO, TCSANOW, &term)
}

func readChar() -> Character? {
    let oldTerm = setupTermios()
    defer {
        restoreTermios(oldTerm: oldTerm)
    }

    var buffer = [UInt8](repeating: 0, count: 1)
    let bytesRead = read(STDIN_FILENO, &buffer, 1)

    if bytesRead > 0 {
        return Character(UnicodeScalar(buffer[0]))
    }

    return nil
}


func handleUserInput() {
    var command = ""
    var parameter = ""

    let inputQueue = DispatchQueue(label: "inputQueue")

    inputQueue.async {
        while let char = readChar() {
            if char >= "0" && char <= "6" {
                command = String(char)
                print("attmpt to parse cmd name = \(command)")
                if let selectedCommand = commandTable[command] {
                    selectedCommand(parameter.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    print("Invalid command. Please try again:")
                }
                command = ""
                parameter = ""
            } else if char == " " {
                // command prefix is complete, start reading parameter
                while let nextChar = readChar() {
                    if nextChar == "\n" {
                        break
                    }
                    if nextChar != "\"" { // Ignore double quotes
                        parameter.append(nextChar)
                    }
                }
                // attempt to parse cmd named
                print("attmpt to parse cmd name = \(command)")
                if let selectedCommand = commandTable[command] {
                    selectedCommand(parameter.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    print("Invalid command. Please try again:")
                }

                command = ""
                parameter = ""
            } else if char == "\n" {
                print("attmpt to parse cmd name = \(command)")
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

