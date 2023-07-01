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
var eventSource: EventSource?
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
func gptCommand(conversationId: Conversation.ID, input: String, useGoogle: Bool = false, useLink: Bool = false, qPrompt: Bool = false) {
    config.conversational = false
    config.manualPromptString = ""

    let googleTextSegment = """
        1. Use the google command to find more information or if it requires information past your knowledge cutoff.
        2. The "google: query" query command can be used if you need help or to look up any bugs you encounter, this way you can find fixes on sites like stackoverflow.com. I will reply with a message containing the search results in a JSON section labeled "Search Results:". Example: "google: drawing hands" would google for the query "drawing hands"
"""

    let linkTextSegment = """
3. The Link url command can be used to get more information by accessing a link. Pass the link: {"command": "Link","name": "www.nytimes.com"}. I will reply with a message containing the text from the link.
"""
    if input == "end" {
        logD("Exited conversational mode.")

        config.conversational = false
        config.manualPromptString = ""
        return
    }

    if config.enableGoogle && useGoogle {
        // conversational mode
        logD("Entered conversational mode! `g end` to reset")

        config.conversational = true
        config.manualPromptString += """
Using the listed tools below, answer the question below "Question to Answer".
"""
        if !config.manualPromptString.contains(googleTextSegment) {
            config.manualPromptString += !useGoogle ? "" : googleTextSegment
        }
    }
    if !config.manualPromptString.contains(linkTextSegment) && config.enableLink {

        config.manualPromptString += !useLink ? "" : linkTextSegment
    }
    if config.enableGoogle {
        config.manualPromptString += !qPrompt ? "" : """
Question to Answer:
"""
    }
    config.manualPromptString += "\n\(input)"

    playMediunImpact()


    //        if "accessToken" not in self.session:
    //            yield (
    //                "Your ChatGPT session is not usable.\n"
    //                "* Run this program with the `install` parameter and log in to ChatGPT.\n"
    //                "* If you think you are already logged in, try running the `session` command."
    //            )
    //            return

    if USE_CHATGPT && SettingsViewModel.shared.chatGPTAuth {
        if SettingsViewModel.shared.accessToken.isEmpty {
            logD("Attempting to send GPT msg without accessToken -- please")

        }
    }

    if !SettingsViewModel.shared.accessToken.isEmpty && USE_CHATGPT && SettingsViewModel.shared.chatGPTAuth {
        logD("Attempting to load via chatGPT accessToken")

        doChatGPT(conversationId: conversationId)
    }
    else {
        GPT.shared.sendPromptToGPT(conversationId: conversationId, prompt: config.manualPromptString, currentRetry: 0) { content, success, isDone in

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

                SettingsViewModel.shared.requestReview()

                if config.conversational {

                    if content.hasPrefix("google:") {
                        let split  = content.split(separator: " ", maxSplits: 1)

                        if split.count > 1 {

                            logD("googling...")

                            googleCommand(input: String(split[1]))

                            if config.conversational {
                                // multiPrinter("Exited conversational mode.")
                                config.conversational = false
                            }
                        }
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
    updatePrompt(appDesc2: appDesc)
    updateOpeningLine()
}

func updatePrompt(appDesc2: String) {
    appDesc = appDesc2
    prompt = promptText(noGoogle: !config.enableGoogle, noLink: !config.enableLink)
}


var appDesc = builtInAppDesc

func promptText(noGoogle: Bool = true, noLink: Bool = true) -> String {

    let googleStringInclude = !noGoogle ? "{\"command\": \"Google\",\"name\": \"EXC_BAD_ACCESS\"}," : ""

    let googleString =
    """
    - The Google query command can be used if you need help or to look up any bugs you encounter, this way you can find fixes on sites like stackoverflow.com. (In the example above EXC_BAD_ACCESS represents the search term you want more info for or the failing line you are trying to fix. I will reply with a message containing the search results in a JSON array below "Search Results:"
    """

    let linkStringInclude = !noLink ? "{\"command\": \"Link\",\"name\": \"www.nytimes.com\"}," : ""
    let linkString =
    """
    - The Link url command can be used to get more information by accessing a link. Pass the link: {\"command\": \"Link\",\"name\": \"www.nytimes.com\"}. I will reply with a message containing the text from the link.
    """
    let appName = config.appName
    let googSteps = !noGoogle  ? "Google, Link," : ""
    return """
    Develop an iOS app in \(config.language) for a SwiftUI-based \(config.appDesc). Name it \(aiNamedProject ? "a unique name" : appName). Return necessary, valid, and formatted Swift code files as a JSON array. It is essential you return your response as a JSON array matching the structure:. [\(googleStringInclude)\(linkStringInclude){"command": "Create project","name": "UniqueName"}, {"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}, {"command": "Open project", "name": "\(aiNamedProject ? "UniqueName" : appName)"},{"command": "Close project", "name": "UniqueName"}]
    Example SWIFT_FILE_CONTENTS = "import SwiftUI\\nstruct UniqueGameView: View { var body: some View { Spinner() } }\nstruct Spinner: View { var body: some View {a } }". Follow this order: \(googSteps) Create project, Create Swift files (including App file), Build Project, Open Project. Minimize command usage.
    - It is essential you return your response as a JSON array.
    - It is essential you include a Swift `App` file.
    \(!noGoogle ? googleString : "")
    \(!noLink ? linkString : "")
    - Implement all needed code. Do not use files other than .swift files. Use Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn or .dae files.

    """
}
let searchResultHeading = """
Search Results:

"""


// Nex't w'll consider adding source code summarization when passing it back and forth aka

// fileContents is substituted with this format placeholder.

// [SymbolDetail.swift source code]

// [Symbol.swift source code]


var prompt = promptText()


func googleCommand(input: String) {
    searchIt(query: input) { innerContent in
        if let innerContent = innerContent {

            //multiPrinter("\n🤖 googled \(input): \(innerContent)")

            // if overridePrompt is set by the googleCommand.. the next prompt will need to be auto send on this prompts completion.
            config.searchResultHeadingGlobal = "\(searchResultHeading)\n\(innerContent)"

            if let results = config.searchResultHeadingGlobal {
                logD("give 🤖 search results")

//                doPrompting(overridePrompt: results)

                // SHOULD LINK??? no we wait for GPT to link...

                let convo = SettingsViewModel.shared.createConversation()
                gptCommand(conversationId: convo, input: results, useGoogle: false, useLink: true)

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

func searchIt(query: String, completion: @escaping (String?) -> Void) {
//    logD("Searching it... \(query)")
//    // TODO: Implement
//    search(query: query, apiKey: "GOOGLE_KEY", searchEngineId: "GOOGLE_ID") { result in
//        switch result {
//        case .success(let searchItems):
////            for item in searchItems {
////                logD("Title: \(item.title ?? "none")")
////                logD("Link: \(item.link ?? "none")")
////                logD("Snippet: \(item.snippet ?? "none")")
////                logD("\n")
////            }
//
//            func searchItemsToJSONString(_ searchItems: [SearchItem]) -> String? {
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = .prettyPrinted
//
//                do {
//                    let jsonData = try encoder.encode(searchItems)
//                    if let jsonString = String(data: jsonData, encoding: .utf8) {
//                        return jsonString
//                    }
//                } catch {
//                    logD("Error encoding SearchItem array to JSON: \(error.localizedDescription)")
//                }
//
//                return nil
//            }
//
//            completion(searchItemsToJSONString(searchItems))
//        case .failure(let error):
//            logD("Error: \(error.localizedDescription)")
//            completion(nil)
//        }
//    }
}

func doChatGPT(conversationId: Conversation.ID) {
    let serverURL = URL(string:  "https://chat.openai.com/backend-api/conversation")!

    var headas =  ["Authorization": "Bearer \(SettingsViewModel.shared.accessToken)",
                  "Content-Type":  "application/json"]

    eventSource = EventSource(url: serverURL, headers: headas)

    guard let conversationIndex = SettingsViewModel.shared.conversations.firstIndex(where: { $0.id == conversationId }) else {
        logD("Unable to find conversations id == \(conversationId) ... failing")

        return
    }

    Task {
        let myNewPrompt = config.manualPromptString.trimmingCharacters(in: .whitespacesAndNewlines)

        SettingsViewModel.shared.appendMessageToConvoIndex(index: conversationIndex, message: Message(
            id: SettingsViewModel.shared.idProvider(),
            role: .user,
            content:  myNewPrompt,
            createdAt: SettingsViewModel.shared.dateProvider()
        ))

        var newChatId = conversationId.lowercased() //UUID().uuidString.lowercased()
        var newParentId = UUID().uuidString.lowercased()

        logD("Prompting \(myNewPrompt.count)...\n🐑🐑🐑\n")

        let reqString = """
        {
            "action": "next",
            "messages": [
                {
                    "id": "\(newChatId)",
                    "author": { "role": "user" },

                    "content": {
                        "content_type": "text",
                        "parts": ["\(myNewPrompt)"]
                    }
                }
            ],
            "model": "gpt-4-mobile",
            "parent_message_id": "\(newParentId)",
            "history_and_training_disabled": false
        }
        """
        // Experimenting with adding this to get around 403's and cloudflare anti-bot mechanisms (i'm not a bot)
        //        "arkose_token": "\(getArkoseToken() ?? "fail")",

        // we'll need to add this with our existing generated chatID to cont a convo.
        //     "conversation_id": "\(newChatId)",

        logD("Using reqString = \(reqString)")

        eventSource?.onOpen {
            logD("eventSource CONNECTED")
        }

        eventSource?.onComplete { statusCode, reconnect, error in

            if let error {
                logD("statusCode = \(statusCode): eventSource disco w/ error = \(error)")
            }
            else {
                logD("statusCode = \(statusCode): eventSource DISCONNECTED")
            }
            guard reconnect ?? false else { return }

            let retryTime = eventSource?.retryTime ?? 3000
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) {
                logD("eventSource RECONNECT")

                eventSource?.connect()
            }
        }

        eventSource?.onMessage { id, event, data in
            //logD("event - \(event ?? "") | \(data ?? "")")


            if data == "[DONE]" {
                logD("CHATGPT RESPONSE DONE = \(event)")

            }
            // TODO: Is this needed?
            // else if regex.test(event.data))
            else {
                switch event {
                case "message":
                    guard let dict = convertToDictionary(text: data ?? "") else {
                        logD("message Error")

                        return
                    }

                    logD("\(dict)")

                    //                    this.setChatContext({
                    //                      conversationId: data.conversation_id,
                    //                      parentMessageId: data.message.id,
                    //                    });

                    let contentTypeKey = "content_type"
                    guard let msgDict = dict["message"] as? [String: [String: [String: String]]],
                          let contentDict = msgDict["content"] as? [String: String],
                        let contentType = contentDict[contentTypeKey] else { return logD("massive fail") }

                    if  contentType == "code" ||
                            contentType == "system_error"
                    {
                        let existingMessages = SettingsViewModel.shared.conversations[conversationIndex].messages
                        let theContent = contentDict["text"] ?? ""
                        let messageId = (dict["message"] as? [String: String])?["id"] ?? ""

                        let message = Message(
                            id: messageId,
                            role:  .assistant, //choice.delta.role ??
                            content: theContent,
                            createdAt: Date()
                        )

                        if let existingMessageIndex = existingMessages.firstIndex(where: { $0.id == messageId }) {
                            // Meld into previous message
                            let previousMessage = existingMessages[existingMessageIndex]
                            let combinedMessage = Message(
                                id: message.id, // id stays the same for different deltas
                                role: message.role,
                                content: previousMessage.content + message.content,
                                createdAt: message.createdAt
                            )
                            //logD("melding to existing msg")

                            SettingsViewModel.shared.setMessageAtConvoIndex(index: conversationIndex, existingMessageIndex: existingMessageIndex, message: combinedMessage)

                        } else {
                            //logD("append to existing msg")

                            SettingsViewModel.shared.appendMessageToConvoIndex(index: conversationIndex, message: message)
                        }




                        //                        // Preprocessing info
                        //                                      onUpdateResponse(callbackParam, {
                        //                                        content:
                        //                                          "```python\n" +
                        //                                          preInfo.join("\n") +
                        //                                          (preInfo.length > 0 ? "\n" : "") +
                        //                                          content.text +
                        //                                          "\n```",
                        //                                        done: false,
                        //                                      });
                        //                                      if (data.message.status === "finished_successfully")
                        //                                        preInfo.push(content.text);

                    }
                    else if contentType == "text" {

                        let text = (msgDict["content"] as? [String: [String]])?["parts"]?.first ?? ""

                        logD("completed message w/ \(text)")

                        // The final response
                        //                         let text = content.parts[0];
                        //
                        //                         if (preInfo.length > 0)
                        //                           text = "```python\n" + preInfo.join("\n") + "\n```\n" + text;
                        //
                        //                         const citations = data.message.metadata?.citations;
                        //                         if (citations) {
                        //                           citations.forEach((element) => {
                        //                             text += `\n> 1. [${element.metadata.title}](${element.metadata.url})`;
                        //                           });
                        //                         }
                        //
                        //                         onUpdateResponse(callbackParam, {
                        //                           content: text,
                        //                           done: false,
                        //                         });



                    }

                default:
                    logD("unhandled onmessage = \(event)")
                }
            }
        }

        SettingsViewModel.shared.nilOutConversationErrorsAt(convoId: conversationId)



        eventSource?.connect(reqString: reqString)
    }
}

func getArkoseToken() -> String? {
    var arkoseToken: String? = nil
        var part1 = ""
        for _ in 0..<16 {
            let rand = Int.random(in: 0..<16)
            part1 += String(rand, radix: 16)
        }
        while part1.count < 15 {
            part1 = "0" + part1
        }
        let part2 = String(format: "%.10f", Double.random(in: 0..<10))
        arkoseToken = "\(part1)\("\(part2)")|r=us-west-2|meta=3|meta_width=300|metabgclr=transparent|metaiconclr=%23555555|guitextcolor=%23000000|pk=35536E1E-65B4-4D96-9D97-6ADB7EFF8147|at=40|sup=1|rid=44|ag=101|cdn_url=https%3A%2F%2Ftcr9i.chat.openai.com%2Fcdn%2Ffc|lurl=https%3A%2F%2Faudio-us-west-2.arkoselabs.com|surl=https%3A%2F%2Ftcr9i.chat.openai.com|smurl=https%3A%2F%2Ftcr9i.chat.openai.com%2Fcdn%2Ffc%2Fassets%2Fstyle-manager"
    return arkoseToken
}
