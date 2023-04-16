//
//  Command.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation
import Foundation
import AVFoundation
import os.log
import AVFoundation
import CoreMedia

var commandTable: [String: (String) -> Void] = [
    "0": zeroCommand,
    "gpt:": gptCommand,
    "xcode:": xcodeCommand,
    "idea:": ideaCommand,
    "1": runAppDesc,
    "2": showLoadedPrompt,
    "3": openProjectCommand,
    "4": closeCommand,
    "5": fixItCommand,
    "6": openProjectCommand,
   // "7": blarg,

    "exit": exitCommand,
]


func ideaCommand(input: String) {
    let command = String(input.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines)

    let newPrompt = createIdeaPrompt(command: command)

    doPrompting(overridePrompt: newPrompt)
}

func zeroCommand(input: String) {
    // start voice capture
    if audioRecorder?.isRunning == false {
        print("Start voice capturer")
        textToSpeech(text: "listening")

        audioRecorder?.startRecording()
    } else if audioRecorder?.isRunning == true {
        print("Stop voice capturer")

        audioRecorder?.stopRecording()
        textToSpeech(text: "captured")

        guard let path = audioRecorder?.outputFileURL else { return print("failed to transcribe") }

        Task {
            await doTranscription(on: path)
        }

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
