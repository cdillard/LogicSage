//
//  Input.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

import Foundation

func promptUserInput(message: String) -> String? {
    print(message, terminator: "")
    return readLine()
}

let commands: [String: (String) -> Void] = [
    "0": zeroCommand,
    "gpt:": gptCommand,
    "xcode:": xcodeCommand,
    "idea:": exitCommand,
    "1": runAppDesc,
    "2": showLoadedPrompt,
    "3": openProjectCommand,
    "exit": exitCommand,
]

func handleUserInput() {
    DispatchQueue.global(qos: .userInteractive).async {

        while true {
            if let char = readCharacter() {
                if char.isLetter { continue }

                if char == "0" {
                    commands["0"]!("")
                   // print("\nPlease enter another command prefix (or type '0' to execute immediately):")
                } else {
                    var commandString = String(char)
                    var parameterString = ""

                    while let nextChar = readCharacter(), nextChar != " " && nextChar != "\n" {
                        commandString.append(nextChar)
                    }

                    while let nextChar = readCharacter(), nextChar != "\n" {
                        parameterString.append(nextChar)
                    }

                    if let selectedCommand = commands[commandString.replacingOccurrences(of: "\\n", with: "")] {
                        selectedCommand(parameterString)
                        //print("\nPlease enter another command prefix (or type '0' to execute immediately):")
                    } else {
                        print("Invalid command. Please try again:")
                    }
                }
            }
        }
    }
}

func ideaCommand(input: String) {
    let command = String(input.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)

    appDesc = command

    let newPrompt = createIdeaPrompt(command: command)

    doPrompting(overridePrompt: newPrompt)
}

func zeroCommand(input: String) {
    // start voice capture
    if audioProcessor?.isRunning == false {
        print("Start voice capturer")
        textToSpeech(text: "listening")

        audioProcessor?.start()
    } else if audioProcessor?.isRunning == true {
        print("Stop voice capturer")

        audioProcessor?.stop()
        textToSpeech(text: "captured")

    }
}
func gptCommand(input: String) {
    let prompt = String(input.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
    manualPromptString = prompt
    sendPromptToGPT(prompt: prompt, currentRetry: 0) { content, success in
        print("\n🤖: \(content)")

        textToSpeech(text: content)

        refreshPrompt(appDesc: appDesc)

        print(generatedOpenLine())
        openLinePrintCount += 1

    }

}
// TODO:
func xcodeCommand(input: String) {
    let command = String(input.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
   // runXcodeCommand(command: command)
}

func exitCommand(input: String) {
    sema.signal()
    
}

func closeCommand(input: String) {
    executeAppleScriptCommand(.closeProject(name: projectName))
}


func fixItCommand(input: String) {
    let newPrompt = createFixItPrompt(errors: globalErrors, currentRetry: 0)

    doPrompting(globalErrors, overridePrompt: newPrompt)
}

func runAppDesc(input: String) {
    doPrompting()
}

func showLoadedPrompt(input: String) {
    print("\n \(prompt) \n")

    refreshPrompt(appDesc: appDesc)
    print(openingLine)
}


func openProjectCommand(input: String) {
    executeAppleScriptCommand(.openProject(name: projectName))
    refreshPrompt(appDesc: appDesc)
    print(generatedOpenLine())
    openLinePrintCount += 1
}

func readCharacter() -> Character? {
    let input = FileHandle.standardInput
    let data = input.readData(ofLength: 1)
    guard !data.isEmpty, let char = String(data: data, encoding: .utf8)?.first else {
        return nil
    }
    return char
}

func readCommand() -> (String, String) {
    var commandString = ""
    var parameterString = ""

    while let char = readCharacter() {
        if char == "0" {
            return ("0", "")
        } else if char == " " || char == "\n" {
            break
        } else {
            commandString.append(char)
        }
    }

    while let char = readCharacter() {
        if char == "\n" {
            break
        } else {
            parameterString.append(char)
        }
    }

    return (commandString, parameterString)
}
