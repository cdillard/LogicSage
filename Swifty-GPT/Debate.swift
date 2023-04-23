//
//  Debate.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation

var depthLimit = 11 // turn it up too
let personalityA = aaronVoice // male voice
let personalityB = sageVoice // female voice
let personAsName = "Aaron"
let personBsName = "Sage"

let debatePrompt9 = """
Debate Topic: "Should the government regulate and limit the use of artificial intelligence in daily life?" In this debate, Aaron and Sage will present opposing viewpoints on the role of government in regulating and limiting the use of artificial intelligence (AI) in daily life. Aaron will argue in favor of government regulation and limitation of AI usage, emphasizing the potential negative consequences of unregulated AI, such as job displacement, loss of privacy, and ethical concerns. He will advocate for strict regulations to ensure that AI is developed and implemented responsibly, prioritizing the well-being and safety of the general public. Sage, on the other hand, will argue against government intervention in the AI sector, emphasizing the importance of technological innovation and the potential benefits of AI in improving efficiency, productivity, and overall quality of life. She will argue that limiting AI development could stifle progress and hinder society from fully realizing the benefits of this transformative technology. Instead, Sage will advocate for a more laissez-faire approach, allowing the market and individual choice to determine the extent and direction of AI usage. You can include Moderator text with "Moderator Says:" Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
let debatePrompt8 = """
Broad subject: Technology, Narrowed down issue: The impact of artificial intelligence on employment, Clear statement: "Artificial intelligence poses a significant threat to the job market and will lead to mass unemployment.", Different perspectives: Participants can either argue in favor of the statement, supporting the idea that AI will cause job loss, or argue against it, stating that AI will create new job opportunities and boost the economy. Aaron believes that A.G.I will lead to a more enlightened society where people can learn anything and their only limits are their imagination, while Sage opposes Artificial Intelligence and thinks that acheiving A.G.I would be horrible and a doomsday scenario. Engage in a civil and respectful debate on the ethics of artificial intelligence and Artificial General Intelligence, discussing its potential benefits, risks, and the moral implications. Aaron and Sage are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses
"""
let debatePrompt7 = """
Prompt: "Aaron believes that assisted suicide is a compassionate option for terminally ill patients who are suffering, while Sage opposes assisted suicide on ethical and moral grounds. Engage in a civil and respectful debate on the ethics of assisted suicide, discussing its potential benefits, risks, and the moral implications. Aaron and Sage are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
let debatePrompt6 = """
Different religious beliefs: Aaron: An atheist Sage: A theist Topic: Discuss the role of religion in modern society. Aaron and Sage are having a debate. Only provide one response per reply.
"""
let debatePrompt5 = """
Divergent views on work-life balance: Aaron: A workaholic Sage: A believer in work-life balance Topic: Discuss the impact of long working hours on personal well-being and productivity. Aaron and Sage are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt4 = """
Topic: Zombies vs. Aliens, Aaron: A zombie apocalypse enthusiast, Sage: An alien invasion enthusiast, Context: Debate which hypothetical scenario would be more entertaining or disastrous. Prompt: "Aaron is fascinated by the idea of a zombie apocalypse and believes it would be the ultimate survival challenge, while Sage is captivated by the prospect of an alien invasion and the potential for interstellar diplomacy or conflict. Engage in a humorous debate discussing which hypothetical scenario would be more entertaining or disastrous." Aaron and Sage are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt3 = """
Topic: Cats vs. Dogs, Aaron: A cat lover, Sage: A dog lover, Context: Debate which pet is superior and why. Prompt: "Aaron is a devoted cat lover and believes cats are the superior pet, while Sage is a dog enthusiast who thinks dogs are the best companions. Engage in a humorous debate over which pet is superior and why." Aaron and Sage are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt2 = """
Topic: Legalization of recreational drugs, Aaron: A proponent of legalizing recreational drugs, Sage: An opponent of legalizing recreational drugs, Context: Discuss the health, social, and economic implications of legalizing recreational drugs, and debate the merits of prohibition versus regulation. Aaron and Sage are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt = """
Aaron supports capital punishment as a necessary means of justice, while Sage opposes it on moral and ethical grounds. Engage in a civil debate discussing the moral, ethical, and practical implications of capital punishment. Aaron and Sage are having a debate. Please provide a single response for one personality per message.
"""
let debatePrompt0 = """
Prompt: "Aaron believes that A.G.I will lead to a more enlightened society where people can learn anything and their only limits are their imagination, while Sage opposes Artificial Intelligence and thinks that acheiving A.G.I would be horrible and a doomsday scenario. Engage in a civil and respectful debate on the ethics of artificial intelligence and Artificial General Intelligence, discussing its potential benefits, risks, and the moral implications. Aaron and Sage are having a debate. Please provide a single response for one personality per message. Do not use the new line character in your responses.
"""
func prePrompt(_ subject: String? = nil) -> String {
"""
give me a very interesting and detailed debate topic \(subject != nil ? "about \(subject!)" : "") including two distinct personalities named \(personAsName) and \(personBsName)
"""
}

func randomDebate() -> String {
    debatePrompt9
    //    switch Int.random(in: 0...6) {
    //    case 0:
    //        return debatePrompt
    //    case 1:
    //        return debatePrompt2
    //
    //    case 2:
    //        return debatePrompt3
    //
    //    case 3:
    //        return debatePrompt4
    //
    //    case 4:
    //        return debatePrompt5
    //
    //    case 5:
    //        return debatePrompt6
    //
    //    case 6:
    //        return debatePrompt7
    //
    //    default:
    //        return debatePrompt
    //
    //    }
}
let usePrePrompt = true
func debateCommand(input: String) {
    debateMode = true
    print("DEBATE STAGE:")
    if (input.isEmpty || !usePrePrompt) {
        deepConversation(currentPersonality: personalityA, initialPrompt: debatePrompt0, depth: depthLimit)

    }
    else if (usePrePrompt) {
        print("DEBATE STAGE:")

        sendPromptToGPT(prompt: input.isEmpty ? prePrompt() : prePrompt(input), currentRetry: 0, disableSpinner: false) { content, success in
            if !success { return print("Failed to think of debating...") }
            deepConversation(currentPersonality: personalityA, initialPrompt: content, depth: depthLimit)

        }
    }
}

func deepConversation(currentPersonality: String, initialPrompt: String, depth: Int) {
    if depth <= 0 {
        textToSpeech(text: "This concludes the debate.", overrideVoice: personalityA)

        return
    }

    print("debate depth: \(depth)")

    let array = initialPrompt.components(separatedBy: "\n")
    guard !array.isEmpty else {
        print("Failed to think deeply")
        return
    }

    let newPrompt = array[0]


    sendPromptWithPersonality(prompt: newPrompt, currentRetry: 0, personality: currentPersonality) { content, success in
        if success {
            //let nextPersonality = currentPersonality == personalityA ? "Personality B:" : "Personality A:"

            print("*** Check for persona: Debate p = \(newPrompt) and reply = \(content)")


            var nextPersonality = personalityB

            if currentPersonality == personalityA {
                nextPersonality = personalityB
            } else {
                nextPersonality = personalityA
            }


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

        print("Debate personality = \(personality), p = \(prompt)")


        let array = content.components(separatedBy: "\n")
        guard !array.isEmpty else {
            print("Failed to think deeply")
            return
        }

        let newPrompt = array[0]

        let personalityPrefix = personality == "Aaron" ?  "Sage: " : "Aaron: "
        let newResponse = newPrompt
//            .replacingOccurrences(of: "Aaron:", with: "")
//            .replacingOccurrences(of: "Sage:", with: "")


        // avg loading for prompt duration for session.... (MIGHT BE 1 righ???)
        let duration = textToSpeech(text: newPrompt, overrideVoice: personality) - 1

        DispatchQueue.global().asyncAfter(deadline: .now() + duration) {
            completionHandler(personalityPrefix + newResponse, true)
        }
    }
}
