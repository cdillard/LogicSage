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

                    refreshPrompt(appDesc: appDesc)

                    print(generatedOpenLine())
                    openLinePrintCount += 1

                }
            } else if input.lowercased().hasPrefix("xcode:") {
                let command = String(input.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
               // runXcodeCommand(command: command)
            } else if input.lowercased().hasPrefix("idea:") {
                let command = String(input.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)

                appDesc = command

                let newPrompt = createIdeaPrompt(command: command)

                doPrompting(overridePrompt: newPrompt)

            } else if input.hasPrefix("0") {
                // doPrompting()

                // start voice capture
                if audioProcessor?.isRunning == false {
                    print("Start voice capturer")

                    audioProcessor?.start()
                } else if audioProcessor?.isRunning == true {
                    audioProcessor?.stop()

                }

            }
            // Run appDesc GPT prompt
            else if input.hasPrefix("1") {
                doPrompting()
            }
            // show loaded prompt
            else if input.hasPrefix("2") {
                print("\n \(prompt) \n")

                refreshPrompt(appDesc: appDesc)
                print(openingLine)
            }
            // Open Project
            else if input.hasPrefix("3") {
                executeAppleScriptCommand(.openProject(name: projectName))
                refreshPrompt(appDesc: appDesc)
                print(generatedOpenLine())
                openLinePrintCount += 1

            }
            // Close Proj
            else if input.hasPrefix("4") {
                executeAppleScriptCommand(.closeProject(name: projectName))
            }
            // Fix errors
            else if input.hasPrefix("5") {

                let newPrompt = createFixItPrompt(errors: globalErrors, currentRetry: 0)

                doPrompting(globalErrors, overridePrompt: newPrompt)

            }
            // Feature dev
            else if input.hasPrefix("6") {
                // executeAppleScriptCommand(.closeProject(name: projectName))

                // execute fix it prompt
//
//                let newPrompt = createFixItPrompt(errors: globalErrors, currentRetry: 0)
//
//                doPrompting(overridePrompt:newPrompt)

            }
            else {
                print("Unknown command. Please start your command with valid command.")
            }
        }
    }
}
