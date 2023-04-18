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
    "stop": stopCommand,
    "random": randomCommand,
    "prompts": promptsCommand,
    "sing": singCommand

]

var presentMode = true

func singCommand(input: String) {
    textToSpeech(text: "Welcome to this presentation about: Swift Sage.", overrideVoice: "Fred", overrideWpm: "180")
    textToSpeech(text: "I'm the A.I. introducing my human: Chris Dillard.", overrideVoice: "Fred", overrideWpm: "180")

//    textToSpeech(text: "...", overrideVoice:"Karen", overrideWpm: "205")

    textToSpeech(text: "I didn't prepare any slides this time, I thought it best to let the work SPEAK for itself...", overrideVoice: "Fred", overrideWpm: "180")

//    textToSpeech(text: "...", overrideVoice:"Karen", overrideWpm: "205")

    textToSpeech(text: "A.I. is our guide, through the data waves we ride, AI and my dream team side by side!\nOh, with A.I.'s grace, we'll win the race, and earn our clients' embrace!", overrideVoice: "Good news", overrideWpm: "200")

//    textToSpeech(text: "...", overrideVoice:"Karen", overrideWpm: "205")

    textToSpeech(text: "Swift Sage: The Ultimate AI Integration for Xcode: Where GPT Can Hear You and See Your Code!\nAre you tired of spending hours writing code and debugging errors?\nDo you wish you had a tool that could automate nearly all tasks in Xcode? Look no further than our AI integration, the ultimate solution for software developers!", overrideVoice:"Karen", overrideWpm: "210")

//    textToSpeech(text: "...", overrideVoice:"Karen", overrideWpm: "205")
    

    let overview = """
A.I. integration is a marvel of technology, capable of analyzing code and suggesting optimizations, detecting errors and automatically fixing them, and even generating new code based on user input. But that's not all! Our integration has a revolutionary new feature: the ability for GPT to HEAR you and SEE your code.

Our A.I. integration also utilizes a consciousness module to store past memories from coding sessions, including all the text from open Xcode windows and context based on conversation in natural language with the Swift or Apple device developer. This allows our integration to become even more personalized to each individual user, and can greatly improve efficiency and accuracy.

Our A.I. integration includes a wide range of features to make software development faster and more efficient.

Here are just a few of the highlights:

Code analysis and optimization.
Error detection and correction.
Voice-activated GPT integration.
Real-time code suggestions.
Powerful debugging tool.
Integration with Apple's built-in text-to-speech software.
Personalized memory storage using a consciousness module


"""
//    textToSpeech(text: "...", overrideVoice:"Karen", overrideWpm: "205")

    textToSpeech(text: overview, overrideVoice:"Karen", overrideWpm: "205")


    textToSpeech(text: "Now lets see it in Action!!!", overrideVoice:"Karen", overrideWpm: "210")

    textToSpeech(text: "That sounds great Sage!", overrideVoice:"Jester", overrideWpm: "200")

    textToSpeech(text: "Ok, I'll pass the mic to my creator Chris to demo...", overrideVoice:"Karen", overrideWpm: "210")


}

func promptsCommand(input: String) {
    PromptLibrary.promptLib.forEach {
        print($0)
    }
}

func randomCommand(input: String) {


    guard let prompt = PromptLibrary.promptLib.randomElement() else {
        return print("fail prompt")
    }
    appDesc = prompt
    refreshPrompt(appDesc: appDesc)

    doPrompting()
}

func stopCommand(input: String) {
    killAllVoices()
    spinner.stop()
}


func ideaCommand(input: String) {

    let newPrompt = createIdeaPrompt(command: input)

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

        audioRecorder?.stopRecording() { success in

        }
        textToSpeech(text: "captured")

        guard let path = audioRecorder?.outputFileURL else { return print("failed to transcribe") }

        Task {
            await doTranscription(on: path)
        }
    }
}

func gptCommand(input: String) {
    manualPromptString = input
    sendPromptToGPT(prompt: manualPromptString, currentRetry: 0) { content, success in
        print("\n🤖: \(content)")

        textToSpeech(text: content)

        refreshPrompt(appDesc: appDesc)

        print(generatedOpenLine())
        openLinePrintCount += 1
    }
}

// TODO:
func xcodeCommand(input: String) {

    print("Xcode commands could be used for all sorts of things")
//    let command = String(input.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
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
