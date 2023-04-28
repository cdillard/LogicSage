//
//  Debate.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation

var depthLimit = 6 // turn it up too
let personalityA = alexVoice // male voice
let personalityB = allisonVoice // female voice
let personAsName = "Alex"
let personBsName = "Allison"

// CEREPROC VOICES SETUP
//Don't check this in -- Chris
//let personalityA = hannahVoice // male voice
//let personalityB = heatherVoice // female voice
//let personAsName = "Hannah"
//let personBsName = "Heather"


func randomDebate() -> String {
        switch Int.random(in: 0...11) {
        case 0:
            return debatePrompt
        case 1:
            return debatePrompt2

        case 2:
            return debatePrompt3

        case 3:
            return debatePrompt4

        case 4:
            return debatePrompt5

        case 5:
            return debatePrompt6

        case 6:
            return debatePrompt7
        case 7:
            return plutoPrompt
        case 8:
            return cokePrompt
        case 9:
            return eurovisionPrompt
        case 10:
            return dressPrompt
        case 11:
            return emuwwarPrompt

        default:
            return debatePrompt

        }
}
let usePrePrompt = true
func debateCommand(input: String) {
    debateMode = true
    if (input.isEmpty || !usePrePrompt) {
        multiPrinter("DEBATE STAGE:")
        deepConversation(currentPersonality: personalityA, initialPrompt: randomDebate(), depth: depthLimit)

    }
    else if (usePrePrompt) {
        multiPrinter("DEBATE STAGE:")
        let usePrompt = input.isEmpty ? prePrompt() : prePrompt(input)
        sendPromptToGPT(prompt: usePrompt, currentRetry: 0, disableSpinner: false) { content, success in
            if !success { return multiPrinter("Failed to think of debating...") }

            // put content into template


            deepConversation(currentPersonality: personalityA, initialPrompt: content, depth: depthLimit)

        }
    }
}

func deepConversation(currentPersonality: String, initialPrompt: String, depth: Int) {
    if depth <= 0 {
        textToSpeech(text: "This concludes the debate.", overrideVoice: personalityA)

        return
    }

    multiPrinter("debate depth: \(depth)")

    let array = initialPrompt.components(separatedBy: "\n")
    guard !array.isEmpty else {
        multiPrinter("Failed to think deeply")
        return
    }

    let newPrompt = array[0]
    sendPromptWithPersonality(prompt: newPrompt, currentRetry: 0, personality: currentPersonality) { content, success in
        if success {
            var nextPersonality = personalityB

            if currentPersonality == personalityA {
                nextPersonality = personalityB
            } else {
                nextPersonality = personalityA
            }
            deepConversation(currentPersonality: nextPersonality, initialPrompt: content, depth: depth - 1)
        } else {
            multiPrinter("Failed to think deeply")
        }
    }
}

func sendPromptWithPersonality(prompt: String, currentRetry: Int, personality: String, completionHandler: @escaping (String, Bool) -> Void) {
    sendPromptToGPT(prompt: prompt, currentRetry: currentRetry, disableSpinner: false) { content, success in
        if !success {
            textToSpeech(text: "A.P.I. error, try again.", overrideWpm: "242")
            completionHandler("", false)
            return
        }

        let array = content.components(separatedBy: "\n")
        guard !array.isEmpty else {
            multiPrinter("Failed to think deeply")
            return
        }

        let newPrompt = array[0]

        let personalityPrefix = personality == "\(personAsName)" ?  "\(personBsName): " : "\(personAsName): "
        let newResponse = newPrompt
            .replacingOccurrences(of: "\(personAsName):", with: "")
            .replacingOccurrences(of: "\(personBsName):", with: "")


        // avg loading for prompt duration for session.... (MIGHT BE 1 righ???)
        let duration = textToSpeech(text: newResponse, overrideVoice: personality) - 0.6

        DispatchQueue.global().asyncAfter(deadline: .now() + duration) {
            completionHandler(personalityPrefix + newPrompt, true)
        }
    }
}
