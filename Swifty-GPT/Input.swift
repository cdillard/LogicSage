//
//  Input.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation
import Darwin.POSIX.termios

func promptUserInput(message: String) -> String? {
    print(message, terminator: "")
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

/*
 func setRawMode() -> termios {
     var raw = termios()
     tcgetattr(STDIN_FILENO, &raw)

     let original = raw

     raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON)
     raw.c_oflag &= ~OPOST
     raw.c_cflag |= CS8
     raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG)
     raw.c_cc.16 = UInt8(1)
     raw.c_cc.17 = UInt8(0)

     tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
     return original
 }

 */


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
                print("input disabled (you can `q`). Plese file a github Issue. *with logs or else (shakesfist)*")


                var input = ""
                while let char = readChar(), char != "\n" {
                    input += String(char)
                }

               if input == "q" {
                    print("\nYou've entered the special lettr!")
                    stopCommand(input: "")

                    // Execute the desired command
                } else {
                    print("\nIncorrect special lettr.")
                }

                // ONLY capture "q"
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
                print("\r", terminator: "")
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
                print(String(validCommand) + "" + String(validParameter), terminator: "")
                fflush(stdout)

                continue
            }


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
                    selectedCommand(parameter.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: validCharacterSet.inverted))
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
