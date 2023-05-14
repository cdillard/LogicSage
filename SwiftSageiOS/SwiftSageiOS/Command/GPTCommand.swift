//
//  GPTCommand.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/2/23.
//

import Foundation

// we can use "g end" to stop that particular gpt conversation and exit conversational mode.
func gptCommand(input: String) {
    gptCommand(input: input, useGoogle: true, useLink: true, qPrompt: true)
}

func gptCommand(input: String, useGoogle: Bool = false, useLink: Bool = false, qPrompt: Bool = false) {

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

    sendPromptToGPT(prompt: config.manualPromptString, currentRetry: 0) { content, success in

        if !success {
            SettingsViewModel.shared.speak("A.P.I. error, try again.")
            return
        }

        // multiPrinter("\n🤖: \(content)")
        logD("say: \(content)")
        SettingsViewModel.shared.speak(content)

        refreshPrompt(appDesc: config.appDesc)

        logD(generatedOpenLine())
        openLinePrintCount += 1


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

func logD(_ text: String) {
#if !os(macOS)
    consoleManager.print(text)
#endif
    print(text)

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
    let appName = config.appName ?? "DefaultName"
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


                gptCommand(input: results, useGoogle: false, useLink: true)

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
    logD("Searching it... \(query)")
    // TODO: Implement
    search(query: query, apiKey: "GOOGLE_KEY", searchEngineId: "GOOGLE_ID") { result in
        switch result {
        case .success(let searchItems):
//            for item in searchItems {
//                logD("Title: \(item.title ?? "none")")
//                logD("Link: \(item.link ?? "none")")
//                logD("Snippet: \(item.snippet ?? "none")")
//                logD("\n")
//            }

            func searchItemsToJSONString(_ searchItems: [SearchItem]) -> String? {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted

                do {
                    let jsonData = try encoder.encode(searchItems)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        return jsonString
                    }
                } catch {
                    logD("Error encoding SearchItem array to JSON: \(error.localizedDescription)")
                }

                return nil
            }

            completion(searchItemsToJSONString(searchItems))
        case .failure(let error):
            logD("Error: \(error.localizedDescription)")
            completion(nil)
        }
    }
}

