//
//  Debate.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation

var depthLimit = 20
var personalityA = aaronVoice
var personalityB = sageVoice

let debatePrompt7 = """
Prompt: "Personality A believes that assisted suicide is a compassionate option for terminally ill patients who are suffering, while Personality B opposes assisted suicide on ethical and moral grounds. Engage in a civil and respectful debate on the ethics of assisted suicide, discussing its potential benefits, risks, and the moral implications. Personality A and Personality B are having a debate. Please provide a single response for one personality per message.
"""

let debatePrompt6 = """
Different religious beliefs: Personality A: An atheist Personality B: A theist Topic: Discuss the role of religion in modern society. Personality A and Personality B are having a debate. Only provide one response per reply.
"""
let debatePrompt5 = """
Divergent views on work-life balance: Personality A: A workaholic Personality B: A believer in work-life balance Topic: Discuss the impact of long working hours on personal well-being and productivity. Personality A and Personality B are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt4 = """
Topic: Zombies vs. Aliens, Personality A: A zombie apocalypse enthusiast, Personality B: An alien invasion enthusiast, Context: Debate which hypothetical scenario would be more entertaining or disastrous. Prompt: "Personality A is fascinated by the idea of a zombie apocalypse and believes it would be the ultimate survival challenge, while Personality B is captivated by the prospect of an alien invasion and the potential for interstellar diplomacy or conflict. Engage in a humorous debate discussing which hypothetical scenario would be more entertaining or disastrous." Personality A and Personality B are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt3 = """
Topic: Cats vs. Dogs, Personality A: A cat lover, Personality B: A dog lover, Context: Debate which pet is superior and why. Prompt: "Personality A is a devoted cat lover and believes cats are the superior pet, while Personality B is a dog enthusiast who thinks dogs are the best companions. Engage in a humorous debate over which pet is superior and why." Personality A and Personality B are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt2 = """
Topic: Legalization of recreational drugs, Personality A: A proponent of legalizing recreational drugs, Personality B: An opponent of legalizing recreational drugs, Context: Discuss the health, social, and economic implications of legalizing recreational drugs, and debate the merits of prohibition versus regulation. Personality A and Personality B are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt = """
Personality A supports capital punishment as a necessary means of justice, while Personality B opposes it on moral and ethical grounds. Engage in a civil debate discussing the moral, ethical, and practical implications of capital punishment. Personality A and Personality B are having a debate. Please provide a single response for one personality per message.
"""

func randomDebate() -> String {
    switch Int.random(in: 0...6) {
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

    default:
        return debatePrompt

    }
}

func debateCommand(input: String) {
    debateMode = true
    print("DEBATE STAGE:")
    deepConversation(currentPersonality: personalityA, initialPrompt: randomDebate(), depth: depthLimit)
}

func deepConversation(currentPersonality: String, initialPrompt: String, depth: Int) {
    if depth <= 0 {
        return
    }

    let array = initialPrompt.components(separatedBy: "\n")
    guard !array.isEmpty else {
        print("Failed to think deeply")
        return
    }

    let newPrompt = array[0]

    print("Debate p = \(newPrompt)")

    sendPromptWithPersonality(prompt: newPrompt, currentRetry: 0, personality: currentPersonality) { content, success in
        if success {
            let nextPersonality = currentPersonality == personalityA ? personalityB : personalityA
            deepConversation(currentPersonality: nextPersonality, initialPrompt: content, depth: depth - 1)
        } else {
            print("Failed to think deeply")
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

        let name = personality == personalityA ? "Personality A:" : "Personality B:"
        print("Debate personality = \(personality), p = \(prompt)")

        let array = content.components(separatedBy: "\n")
        guard !array.isEmpty else {
            print("Failed to think deeply")
            return
        }

        let newResponse = array[0]
                            .replacingOccurrences(of: "Personality A:", with: "")
                            .replacingOccurrences(of: "Personality B:", with: "")
        let duration = textToSpeech(text: newResponse, overrideVoice: personality)

        DispatchQueue.global().asyncAfter(deadline: .now() + duration) {
            completionHandler(newResponse, true)
        }
    }
}
