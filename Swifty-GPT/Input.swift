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

func handleUserInput() {
    DispatchQueue.global(qos: .userInteractive).async {
        while true {
            guard let input = readLine(strippingNewline: true) else { continue }

            if input.lowercased() == "exit" {
                sema.signal()
                break
            } else if input.lowercased().hasPrefix("gpt:") {
                let prompt = String(input.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
                manualPromptString = prompt
                sendPromptToGPT(prompt: prompt, currentRetry: 0) { content, success in
                    print("\n\n🤖: \(content)")

                    refreshPrompt()

                    print(openingLine)
                }
            } else if input.lowercased().hasPrefix("xcode:") {
                let command = String(input.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
               // runXcodeCommand(command: command)
            } else if input.lowercased().hasPrefix("idea:") {
                let command = String(input.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)
                appDesc = command

                refreshPrompt()


                doPrompting()

            }
            else if input.lowercased().hasPrefix("1") {
                doPrompting()
            }
            else if input.lowercased().hasPrefix("2") {
                print("\n\(appDesc) \n \(prompt)")

                refreshPrompt()
                print(openingLine)
            }
            else if input.lowercased().hasPrefix("3") {
                executeAppleScriptCommand(.openProject(name: projectName))
                refreshPrompt()
                print(openingLine)

            }
            else if input.lowercased().hasPrefix("4") {
                executeAppleScriptCommand(.closeProject(name: projectName))
            }
            else {
                print("Unknown command. Please start your command with 'gpt:' or 'xcode:'.")
            }
        }
    }
}
