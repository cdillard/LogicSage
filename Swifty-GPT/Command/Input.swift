//
//  Input.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation
import Darwin.POSIX.termios



// We should have an enum defining the "MODE" swift sage cmd is in,
// for instance, during .trivia mode we have special input criteria and it must be exited to get back to the "main menu" cmd prompt.
// for instance, during .debate we have special input criteria and need to allow bailing out of debate depths when user hits stop.


func promptUserInput(message: String) -> String? {
    multiPrinter(message, terminator: "")
    return readLine()
}
let validCharacterSet = CharacterSet(charactersIn: UnicodeScalar(0x20)!...UnicodeScalar(0x7E)!)

import Foundation
import Darwin

func enableRawMode(fileDescriptor: Int32) -> termios {
    var raw: termios = termios()

    tcgetattr(fileDescriptor, &raw)
    let original = raw

    // Apply raw mode flags
    raw.c_lflag &= ~(UInt(ECHO | ICANON))
    raw.c_cc.16 = 1 // VMIN
    raw.c_cc.17 = 0 // VTIME

    tcsetattr(fileDescriptor, TCSAFLUSH, &raw)

    return original
}

func disableRawMode(fileDescriptor: Int32, originalTermios: termios) {
    var term = originalTermios
    tcsetattr(fileDescriptor, TCSAFLUSH, &term)
}


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

let BACKSPACE: UInt8 = 0x7F // ASCII value of the backspace character

// HERE BE DRAGONS OF C INPUT HANDLING :*(
func handleUserInput() {
    var command = ""
    var parameter = ""

    let inputQueue = DispatchQueue(label: "inputQueue")

    let STDIN_FILENO = FileHandle.standardInput.fileDescriptor
    let BACKSPACE: UInt8 = 0x7F // ASCII value of the backspace character

    let originalTermios = enableRawMode(fileDescriptor: STDIN_FILENO)
    defer {
        disableRawMode(fileDescriptor: STDIN_FILENO, originalTermios: originalTermios)
    }

    inputQueue.async {
        while true {

            guard let char = readChar() else {
                continue
            }
            if blockingInput {
                multiPrinter("input disabled (you can `q`). Plese file a github Issue. *with logs or else (shakesfist)*")


                var input = ""
                while let char = readChar(), char != "\n" {
                    input += String(char)
                }

               if input == "q" {
                    multiPrinter("\nYou've entered the special lettr!")
                    stopCommand(input: "")

                    // Execute the desired command
                } else {
                    multiPrinter("\nIncorrect special lettr.")
                }

                // ONLY capture "q"
                continue

            }

            if let tq = chosenTQ {
                // Appearenlty questions have up to 8 multiple choice options.
                if char >= "1" && char <= "8" {
                    if Int(String(char)) ?? 0  == tq.correctOptionIndex + 1 {
                        multiPrinter(" was correct! YAY")
                        streak += 1
                        printRandomUnusedTrivia()
                    }
                    else {
                        if streak > 1 {
                            multiPrinter("Incorrect! You better keep studying... you had a \(streak) q winning run!!!! GONE")

                        }
                        else if streak > 0 {
                            multiPrinter("Incorrect! Keep studying...")

                        }
                        else {
                            multiPrinter("Incorrect! Keep studying...")
                        }
                        streak = 0


                    }
                    chosenTQ = nil

                }
                else if char == "q" {
                    multiPrinter("Exiting trivia...")

                    chosenTQ = nil
                }
                else {
                    multiPrinter("You are in trivia mode... exit with `q`")

                }
                continue
            }

            if char == Character(UnicodeScalar(BACKSPACE)) {
                if !parameter.isEmpty {
                    // Remove the last character from the parameter
                    parameter.removeLast()
                } else if !command.isEmpty {
                    // Remove the last character from the command
                    command.removeLast()
                }
                multiPrinter("\r", terminator: "")
                fflush(stdout)

                // Remove the last character from the parameter or command
                if !parameter.isEmpty {
                    parameter.removeLast()
                } else if !command.isEmpty {
                    command.removeLast()
                }

                // Reprint the updated command and parameter
                let validCommand = command.unicodeScalars.filter { validCharacterSet.contains($0) }
                let validParameter = parameter.unicodeScalars.filter { validCharacterSet.contains($0) }
                multiPrinter(String(validCommand) + "" + String(validParameter), terminator: "")
                fflush(stdout)

                continue
            }
            // HANDLE 0 COMMAND
            if char >= "0" && char <= "0" {
                command = String(char)
                callCommandCommand(command,
                                   parameter.trimmingCharacters(in: .whitespacesAndNewlines))
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
                callCommandCommand(command,
                                   parameter.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: validCharacterSet.inverted))
                command = ""
                parameter = ""
            } else if char == "\n" {
                callCommandCommand(command,
                                   parameter.trimmingCharacters(in: .whitespacesAndNewlines))
                command = ""
                parameter = ""
            } else {
                command.append(char)
            }
        }
    }
}

func callCommandCommand(_ command: String, _ arg: String) {
    DispatchQueue.global(qos: .userInitiated).async {
        multiPrinter("SWIFTSAGE: \(command)")

        if command == "Hello" { return }

        if let selectedCommand = commandTable[command] {
            selectedCommand(arg)

        } else {
            // Oh boy, TODO: Fix the millions of robots chorus bug that seems to happen w/ wrong combo of server start, binary start, app start.
           // textToSpeech(text: "Invalid command. Exec c for help")

            multiPrinter("Invalid command. Please try again. (c) for help")
        }
    }
}
