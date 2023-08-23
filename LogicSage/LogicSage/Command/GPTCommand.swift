//
//  GPTCommand.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/2/23.
//

import Foundation

func gptCommand(input: String) {
    let convo = SettingsViewModel.shared.createConversation()
    gptCommand(conversationId: convo, input: input, useGoogle: true, useLink: true, qPrompt: true)
}
func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
func gptCommand(conversationId: Conversation.ID, input: String, useGoogle: Bool = false, useLink: Bool = false, qPrompt: Bool = false, supressPromptLog: Bool = false) {

    config.manualPromptString = ""


    let hasAddedToolPromptBefore = SettingsViewModel.shared.getHasAddedToolPrompt(conversationId)
    var didAddToolPrompt = hasAddedToolPromptBefore
    if SettingsViewModel.shared.openAIModel == "gpt-4-0314-ls-web-browsing" && !hasAddedToolPromptBefore {
        let googleTextSegment = """
        - The google query command can be used if you need help or to find more information or if it requires information past your knowledge cutoff, this way you can find fixes on sites like stackoverflow.com. I will reply with a message containing the search results in a JSON section labeled "Search Results:". Example: "google: drawing hands" would google for the query "drawing hands"
        - The link url command can be used to get more information by accessing a link. Example: "link: https://www.nytimes.com" would result in a message containing the text from the link. Send the link and google commands one at a time please
        """
        
        if config.enableGoogle && useGoogle {
            
            config.manualPromptString += """
Using the listed tools below, answer the question below "Question to Answer". Think step by step.\n
"""
            if !config.manualPromptString.contains(googleTextSegment) {
                config.manualPromptString += !useGoogle ? "" : googleTextSegment
            }

            didAddToolPrompt = true
        }
//        if !config.manualPromptString.contains(linkTextSegment) && config.enableLink {
//            
//            config.manualPromptString += !useLink ? "" : linkTextSegment
//        }
        if config.enableGoogle {
            config.manualPromptString += !qPrompt ? "" : """
\nQuestion to Answer:
"""
        }

    }
    
    config.manualPromptString += "\n\(input)"

    playMediunImpact()

    GPT.shared.sendPromptToGPT(conversationId: conversationId, prompt: config.manualPromptString, currentRetry: 0, manualPrompt: true, supressPromptLog: supressPromptLog) { content, success, isDone in

        if !success {
            SettingsViewModel.shared.speak("A.P.I. error, try again.")
            return
        }

        if !isDone {
            playMessagForString(message: content)
        }
        else {
            playSoftImpact()

            SettingsViewModel.shared.speak(content)

            refreshPrompt(appDesc: config.appDesc)

            SettingsViewModel.shared.saveConvosToDisk()
            SettingsViewModel.shared.setHasAddedToolPrompt(conversationId, added: didAddToolPrompt)

            Task {
                let tokenCount = await SettingsViewModel.shared.tokens(conversationId)
                logD("chat token count now = \(tokenCount)..")
                SettingsViewModel.shared.updateConvoTokenCount(conversationId, tokenCount:tokenCount)
                await SettingsViewModel.shared.cullToXTokens(conversationId, limit:5000)
                SettingsViewModel.shared.saveConvosToDisk()

            }

            SettingsViewModel.shared.requestReview()

            SettingsViewModel.shared.genTitle(conversationId) { success in
                if success {
                    logD("successfully genn title")

                }
                else {
                    logD("fail gen title")
                }
            }

            if config.conversational {
                let lastLine = content.lines.last ?? ""

                let json = try? JSONSerialization.jsonObject(with: Data(lastLine.utf8), options: .fragmentsAllowed) as? [String: String]
                if let command = json?["command"] as? String,
                   let name = json?["name"] as? String {
                    if command == "google" || command == "Google" {
                        logD("googling...")

                        googleCommand(input: name, conversationId: conversationId)

                    }
                    else if command == "link" || command == "Link" {
                        logD("linking...")

                        linkCommand(input: name, conversationId: conversationId)

                    }
                }
                else if lastLine.hasPrefix("google:") || lastLine.hasPrefix("Google:") {
                    let split  = lastLine.split(separator: " ", maxSplits: 1)

                    if split.count > 1 {

                        logD("googling...")

                        googleCommand(input: String(split[1]), conversationId: conversationId)
                    }
                }
                else if lastLine.hasPrefix("link:") || lastLine.hasPrefix("Link:") {
                    let split  = lastLine.split(separator: " ", maxSplits: 1)

                    if split.count > 1 {

                        logD("linking...")

                        linkCommand(input: String(split[1]), conversationId: conversationId)
                    }
                }
            }
        }
    }
}

func logD(_ text: String) {
    SettingsViewModel.shared.logText(text)
    print(text)
}

func logDNoNewLine(_ text: String) {
    SettingsViewModel.shared.logText(text, terminator: "")
    print(text, terminator: "")
}

func refreshPrompt(appDesc: String) {
    //updatePrompt(appDesc2: appDesc)
//    updateOpeningLine()
}

func updatePrompt(appDesc2: String) {
    //appDesc = appDesc2
   // prompt = promptText(noGoogle: !config.enableGoogle, noLink: !config.enableLink)
}

var appDesc = builtInAppDesc

let searchResultHeading = """
Search Results:

"""

func googleCommand(input: String, conversationId: Conversation.ID) {
    searchIt(query: input.replacingOccurrences(of: "\"", with: "")) { innerContent in
        if let innerContent = innerContent {

            //multiPrinter("\n🤖 googled \(input): \(innerContent)")

            // if overridePrompt is set by the googleCommand.. the next prompt will need to be auto send on this prompts completion.
            config.searchResultHeadingGlobal = "\(searchResultHeading)\n\(innerContent)"

            if let results = config.searchResultHeadingGlobal {
                logD("give 🤖 search results")

                //                doPrompting(overridePrompt: results)

                // SHOULD LINK??? no we wait for GPT to link...


                gptCommand(conversationId: conversationId, input: results, useGoogle: false, useLink: true)

                return
            }
            else {
                logD("FAILED to give results")
            }
        }
        else {
            logD("failed to get search results.")
        }
    }
}
func linkCommand(input: String, conversationId: Conversation.ID) {
    logD("\n🤖 attempt to link to  content for GPT... \(input))")

    linkIt(link: input.replacingOccurrences(of: "\"", with: "")) { innerContent in
        if let innerContent = innerContent {

            logD("\n🤖 attempt to link to link innner content content for GPT...")

            // if overridePrompt is set by the googleCommand.. the next prompt will need to be auto send on this prompts completion.
            config.linkResultGlobal = "link: \(input)\ncontent: \(innerContent)"

            if let results = config.linkResultGlobal {
                logD("give 🤖 LINK IT results")

                gptCommand(conversationId: conversationId, input: results, supressPromptLog: true)
                return
            }
            else {
                logD("FAILED to give  LINK IT results")
            }
        }
        else {
            logD("failed to get LINK IT  results.")
        }
    }
}

