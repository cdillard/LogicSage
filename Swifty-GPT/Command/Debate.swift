//
//  Debate.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation
var depthLimit = 6 // turn it up too


// UNDO THIS BEFORTE CHECKING IN
//let personalityA = alexVoice // male voice
//let personalityB = allisonVoice // female voice
//let personAsName = "Alex"
//let personBsName = "Allison"


// DO NOT CHECK IN THE CEREPROC STUF, those nice voices aren't strictly eneded for this.
//let personalityA = alexVoice // male voice
//let personalityB = allisonVoice // female voice
//let personAsName = "Alex"
//let personBsName = "Allison"
//// CEREPROC VOICES SETUP
//// Don't check this in -- Chris
//let personalityA = katherineVoice
//let personalityB = laurenVoice
//let personAsName = "Katherine"
//let personBsName = "Lauren"
//let personalityA = samVoice // male voice
//let personalityB = hannahVoice
//let personAsName = "Sam"
//let personBsName = "Hannah"
let personalityA = laurenVoice
let personalityB = samVoice
let personAsName = "Hannah"
let personBsName = "Sam"

//  let defaultVoice = carolynVoice//hannahVoice//heatherVoice//carolynVoice//samVoice


func randomDebate() -> String {
    switch Int.random(in: 0...13) {
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
        return debatePrompt8
    case 8:
        return debatePrompt0
    case 9:
        return plutoPrompt
    case 10:
        return cokePrompt
    case 11:
        return eurovisionPrompt
    case 12:
        return dressPrompt
    case 13:
        return emuwwarPrompt
    default:
        return debatePrompt
    }
}
let usePrePrompt = true
func debateCommand(input: String) {

    config.promptMode = .debate

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


func debatesCommand(input: String) {

    // PRINT WHEN EMPTY
    if input.isEmpty {

        multiPrinter("Call `debates subject` to do your specific built in debate")
        //print debates and allow choosing
        for (index, debate) in [    debatePrompt,
                                    debatePrompt2,
                                    debatePrompt3,
                                    debatePrompt4,
                                    debatePrompt5,
                                    debatePrompt6,
                                    debatePrompt7,
                                    debatePrompt8,
                                    debatePrompt9,
                                    debatePrompt0,
                                    plutoPrompt,
                                    cokePrompt,
                                    eurovisionPrompt,
                                    dressPrompt,
                                    emuwwarPrompt].enumerated() {
            multiPrinter("subject: \(debateSubject(promptDex: index))")
            multiPrinter("Matter: \(debate)")

        }
    }


    if !input.isEmpty {
        var chosenDebate = ""
        // get chosen debate
        for (index, debate) in [    debatePrompt,
                                    debatePrompt2,
                                    debatePrompt3,
                                    debatePrompt4,
                                    debatePrompt5,
                                    debatePrompt6,
                                    debatePrompt7,
                                    debatePrompt8,
                                    debatePrompt9,
                                    debatePrompt0,
                                    plutoPrompt,
                                    cokePrompt,
                                    eurovisionPrompt,
                                    dressPrompt,
                                    emuwwarPrompt].enumerated() {
            let debateSubjectForIndex = debateSubject(promptDex: index)
            multiPrinter("subject: \(debateSubjectForIndex)")
            multiPrinter("Matter: \(debate)")
            if debateSubjectForIndex == input {
                chosenDebate = debate
                break
            }
            else {
                print("not this one")
            }
        }


        if !chosenDebate.isEmpty {
            config.promptMode = .debate
                multiPrinter("DEBATE STAGE:")
                deepConversation(currentPersonality: personalityA, initialPrompt: chosenDebate, depth: depthLimit)
// DO we need a new command that simply does the same thing debate does randomly ????
        }
        else {
            multiPrinter("Failed to debate.")

        }
    }

}

// debate subject for promptDex.
func debateSubject(promptDex: Int) -> String {
    switch promptDex {
    case 0:
        return "capitalPunish"
    case 1:
        return "recDrugs"
    case 2:
        return "catsVDogs"
    case 3:
        return "zombieVAlien"
    case 4:
        return "worklife"
    case 5:
        return "religion"
    case 6:
        return "assistDying"
    case 7:
        return "agiEmp"
    case 8:
        return "govAI"
    case 9:
        return "agiLearn"
    case 10:
        return "pluto"
    case 11:
        return "coke"
    case 12:
        return "eurovision"
    case 13:
        return "dress"
    case 14:
        return "emuWar"
    default:
        return "capitalPunish"
    }
}

func debateMatter(promptDex: Int) -> String {
    switch promptDex {
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
        return debatePrompt8
    case 8:
        return debatePrompt0
    case 9:
        return plutoPrompt
    case 10:
        return cokePrompt
    case 11:
        return eurovisionPrompt
    case 12:
        return dressPrompt
    case 13:
        return emuwwarPrompt
    default:
        return debatePrompt
    }
}
