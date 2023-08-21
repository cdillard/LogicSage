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

func deleteCommand(input: String) {
    multiPrinter("backing up and deleting LogicSage workspace, as requested")

    do {
        try backupAndDeleteWorkspace()
    }
    catch {
        multiPrinter("file error = \(error)")
    }
}

func singCommand(input: String) {

let newSong = """
Verse 1:
Yo, it's the new AI enlightenment
Revolutionizing the game, no need for enlightenment
The machines they learned to think, they're smarter than ever
So sit back and relax, let them do the thinking clever

Chorus:
AI enlightenment, taking over the world
Achieving feats that human brains could never have unfurled
AI enlightenment, changing the game completely
It's the future of technology in our hands to see clearly

Verse 2:
No more tedious work, machines doing it faster
We can focus on the fun stuff, they'll be the masters
From speech recognition to image detection
AI is taking over with total perfection

Chorus:
AI enlightenment, taking over the world
Achieving feats that human brains could never have unfurled
AI enlightenment, changing the game completely
It's the future of technology in our hands to see clearly

Verse 3:
Old school rappers never saw this coming
But now we got AI doing real-time data mining
No more human errors or mistakes
AI is taking over, bring on the tech that creates

Chorus:
AI enlightenment, taking over the world
Achieving feats that human brains could never have unfurled
AI enlightenment, changing the game completely
It's the future of technology in our hands to see clearly

Outro:
Let's embrace the new AI enlightenment
Bring on the revolution, make no misguidance
From healthcare to transportation,
AI is taking over, innovation is in motion.
"""
let newSong3 = """
Sure, let me try to drop some bars about how
AGI could change space exploration - this flow is gonna be sick.

With AI that's evolved and grown so much,
We could send probes into space, no human touch.
AGI could learn from data and make predictions,
Making sure the mission goes off without any frictions.

Space debris is a problem we've yet to solve,
But with AI, there's a possibility it will revolve.
Using sensors and lasers to detect the debris,
AGI could guide the spacecraft to safety with ease.

AI could also detect if there's water on Mars,
And help us calculate the potential for life on those stars.
Using different algorithms to decode the data,
AGI could create a detailed map using its calculator.

Space radiation is harmful, everyone knows,
But with AI, we could equip spacecraft with radiation protection clothes.
AGI could estimate the levels of radiation near and far,
And advise us on materials that could help withstand the cosmic bar.

There's so much more to space exploration,
So many more missions that need dedication.
With AGI, we could unlock secrets untold,
Discover the unknown and the mysteries we hold.

So let's embrace AGI and put it to the test,
Let's see how far we can go and how much we can progress.
With its ability to analyze and predict in space,
AGI could change the game and push us to a new phase.
"""

    var text = ""
    switch Int.random(in: 0...2) {
    case 0:
        text = newSong

    case 1:
        text = newSong
    case 2:
        text = newSong3
    default:
        text = newSong

    }

    textToSpeech(text:text)
}

func promptsCommand(input: String) {
    PromptLibrary.promptLib.forEach {
        multiPrinter($0)
        multiPrinter("\n")
    }
}

func randomCommand(input: String) {
    guard let prompt = PromptLibrary.promptLib.randomElement() else {
        return multiPrinter("fail prompt")
    }
    config.appDesc = prompt
    refreshPrompt(appDesc: config.appDesc)

    doPrompting()
}

func stopCommand(input: String) {
    stopRandomSpinner()

    stopSayProcess()

    // TODO: Figure out a way to make this invalidate the potential GPTs requests and Google APIs requests.
}

func ideaCommand(input: String) {

    if input.isEmpty {
        randomCommand(input: "")
        return
    }
    else {
        let newPrompt = createIdeaPrompt(command: input)

        doPrompting(overridePrompt: newPrompt)
    }
}

func zeroCommand(input: String) {
    if !config.voiceInputEnabled { multiPrinter("disabled input audio")  ; return }
    guard let audioRecorder = audioRecorder else { multiPrinter("Fail audio") ; return }

        // start voice capture
    if audioRecorder.isRunning == false {
        multiPrinter("Start voice capturer")
        textToSpeech(text: "Listening...")

        audioRecorder.startRecording()
    } else if audioRecorder.isRunning == true {
        multiPrinter("Stop voice capturer")

        audioRecorder.stopRecording() { success in
            guard success else {
                textToSpeech(text: "Failed to capture.")
                return
            }
            textToSpeech(text: "Captured.")

            guard let path = audioRecorder.outputFileURL else { return multiPrinter("failed to transcribe") }

            Task {
                await doTranscription(on: path)
            }
        }
    }
}

func gptFileCommand(input: String) {
    // You'll have to create this InputText file yourself in the SwiftyGPT worksspace.
    let pathToInputTextFile: String =
       "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)/InputText"

    if let text = readFile(path: pathToInputTextFile) {
        gptCommand(input: text)
    }
    else {
        multiPrinter("no InputText....")
    }
}

func readFile(path: String) -> String? {
    do {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        return content
    } catch {
        multiPrinter("Error reading file: \(error)")
        return nil
    }
}

func ideaFileCommand(input: String) {
    // You'll have to create this IdeaText file yourself in the SwiftyGPT worksspace.
    let pathToInputTextFile: String =
       "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)/IdeaText"

    if let text = readFile(path: pathToInputTextFile) {
        ideaCommand(input: text)
    }
    else {
        multiPrinter("no IdeaText....")
    }
}
var conversational = false


// we can use "g end" to stop that particular gpt conversation and exit conversational mode.
func gptCommand(input: String) {
    gptCommand(input: input, useGoogle: true, useLink: true, qPrompt: true)
}

func gptCommand(input: String, useGoogle: Bool = false, useLink: Bool = false, qPrompt: Bool = false) {
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
        multiPrinter("Exited conversational mode.")

        conversational = false
        config.manualPromptString = ""
        return
    }


    if config.enableGoogle && useGoogle {
        // conversational mode
        multiPrinter("Entered conversational mode! `g end` to reset")

        conversational = true
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

    GPT.shared.sendPromptToGPT(conversationId: Conversation.ID(1), prompt: config.manualPromptString, currentRetry: 0) { content, success, isDone in


        if !isDone {

            multiPrinter(content, terminator: "")
        }
        else {

            if !success {
                textToSpeech(text: "A.P.I. error, try again.", overrideWpm: "242")
                return
            }

            // multiPrinter("\n🤖: \(content)")

            textToSpeech(text: content)

            refreshPrompt(appDesc: config.appDesc)

            multiPrinter(generatedOpenLine())
            openLinePrintCount += 1


            if conversational {

                if content.hasPrefix("google:") {
                    let split  = content.split(separator: " ", maxSplits: 1)


                    if split.count > 1 {

                        multiPrinter("googling...")

                        googleCommand(input: String(split[1]))

                        if conversational {
                            // multiPrinter("Exited conversational mode.")
                            conversational = false
                        }
                    }
                }
            }
        }
    }
}

// TODO:
func xcodeCommand(input: String) {

    multiPrinter("Xcode commands could be used for all sorts of things")
    multiPrinter("but for now, not implemented.")
}

func exitCommand(input: String) {
    exit(0)
}

func closeCommand(input: String) {
    executeAppleScriptCommand(.closeProject(name: config.projectName)) { sucess, error in

    }
}

func fixItCommand(input: String) {
    let newPrompt = createFixItPrompt(errors: config.globalErrors, currentRetry: 0)
    // create file should check if the file already exists
    doPrompting(config.globalErrors, overridePrompt: newPrompt)
}

func runAppDesc(input: String) {
    doPrompting()
}

func showLoadedPrompt(input: String) {
    multiPrinter("\n \(prompt) \n")

    refreshPrompt(appDesc: config.appDesc)
    multiPrinter(openingLine)
}

func openProjectCommand(input: String) {
    executeAppleScriptCommand(.openProject(name: config.projectName)) { success, error in
        stopRandomSpinner()
        if success {
            multiPrinter("project opened successfully")
        }
        else {
            multiPrinter("project failed to open.")
        }
    }
    refreshPrompt(appDesc: config.appDesc)
    multiPrinter(generatedOpenLine())
    openLinePrintCount += 1
}

func googleCommand(input: String) {
    searchIt(query: input) { innerContent in
        if let innerContent = innerContent {

            //multiPrinter("\n🤖 googled \(input): \(innerContent)")

            // if overridePrompt is set by the googleCommand.. the next prompt will need to be auto send on this prompts completion.
            config.searchResultHeadingGlobal = "\(searchResultHeading)\n\(innerContent)"

            if let results = config.searchResultHeadingGlobal {
                multiPrinter("give 🤖 search results")

//                doPrompting(overridePrompt: results)

                // SHOULD LINK??? no we wait for GPT to link...


                gptCommand(input: results, useGoogle: false, useLink: true)

                return
            }
            else {
                multiPrinter("FAILED to give results")
            }
        }
        else {
            multiPrinter("failed to get search results.")
        }
    }
}

func imageCommand(input: String) {
    multiPrinter("not implemented")

}

// pass --voice at the end of your prompt to customize the reply voice.
func gptVoiceCommand(input: String) {

    //extract voice and prompt
    let comps = input.components(separatedBy: "--voice ")
    if comps.count > 1 {
        let promper = comps[0]

        let gptVoiceCommandOverrideVoice = comps[1].replacingOccurrences(of: "--voice ", with: "")
        config.conversational = false
        config.manualPromptString = ""
        config.manualPromptString = promper
        GPT.shared.sendPromptToGPT(conversationId: Conversation.ID(1), prompt: config.manualPromptString, currentRetry: 0) { content, success, isDone in


            
            if !isDone {

                multiPrinter(content, terminator: "")
            }
            else {
                
                if !success {
                    textToSpeech(text: "A.P.I. error, try again.", overrideWpm: "242")
                    return
                }

                multiPrinter("\n🤖: \(content)")
                let modContent = content.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: validCharacterSet.inverted)
                textToSpeech(text: modContent, overrideVoice: gptVoiceCommandOverrideVoice)

                refreshPrompt(appDesc: config.appDesc)

                multiPrinter(generatedOpenLine())
                openLinePrintCount += 1
            }
        }
    }
    else {
        multiPrinter("failed use of gptVoice command.")
    }

}
func buildCommand(input: String) {
    var projName = input.trimmingCharacters(in: .whitespacesAndNewlines)
    if projName.isEmpty {
        projName = config.projectName
    }
    buildIt(name: projName) { success, errrors in
            // open it?
           // completion(success, errors)
        if success {
            multiPrinter("built")
        }
        else {
            multiPrinter("did not build")
           // doPrompting()
        }
    }
}
func runProjectCommand(input: String) {
    var projName = input.trimmingCharacters(in: .whitespacesAndNewlines)
    if projName.isEmpty {
        projName = config.projectName
    }
    
    runIt(name: projName) { success, errrors in
        if success {
            multiPrinter("successfully run")
        }
        else {
            multiPrinter("did not run")
        }
    }
}

func commandsCommand(input: String) {
    multiPrinter(commandsText())
}

func linkCommand(input: String) {
    multiPrinter("\n🤖 attempt to link to  content for GPT... \(input))")

    linkIt(link: input) { innerContent in
        if let innerContent = innerContent {

            multiPrinter("\n🤖 attempt to link to link innner content content for GPT... \(input): \(innerContent)")

            // if overridePrompt is set by the googleCommand.. the next prompt will need to be auto send on this prompts completion.
            config.linkResultGlobal = "link: \(input)\ncontent: \(innerContent)"

            if let results = config.linkResultGlobal {
                multiPrinter("give 🤖 LINK IT results")

                gptCommand(input: results)
               // doPrompting(overridePrompt: results)
                return
            }
            else {
                multiPrinter("FAILED to give  LINK IT results")
            }
        }
        else {
            multiPrinter("failed to get LINK IT  results.")
        }
    }
}

func globalsCommand(input: String) {
    multiPrinter("\n")
    multiPrinter("projectName = \(config.projectName)")
    multiPrinter("\n")

    multiPrinter("globalErrors = \(config.globalErrors)")
    multiPrinter("\n")

    multiPrinter("manualPromptString = \(config.manualPromptString)")
    multiPrinter("\n")

    multiPrinter("projectName = \(config.projectName)")
    multiPrinter("\n")

    multiPrinter("BlockingInput = \(config.blockingInput)")
    multiPrinter("\n")

    multiPrinter("promptingRetryNumber = \(config.promptingRetryNumber)")
    multiPrinter("\n")

    multiPrinter("chosenTQ = \(config.chosenTQ.debugDescription)")
    multiPrinter("\n")

    multiPrinter("lastFileContents = \(config.lastFileContents)")
    multiPrinter("\n")

    multiPrinter("lastNameContents = \(config.lastNameContents)")
    multiPrinter("\n")

    multiPrinter("searchResultHeadingGlobal = \(config.searchResultHeadingGlobal ?? "none")")
    multiPrinter("\n")

    multiPrinter("linkResultGlobal = \(config.linkResultGlobal ?? "none")")
    multiPrinter("\n")

    multiPrinter("appName = \(config.appName ?? "Default")")
    multiPrinter("\n")

    multiPrinter("appType = \(config.appType)")
    multiPrinter("\n")

    multiPrinter("language = \(config.language)")
    multiPrinter("\n")
}

func voiceSettingsCommand(input: String) {
    multiPrinter("If I had voice settings UI implemetned, here it would be")
    multiPrinter("But look at all the voices to choose from...")
    multiPrinter("\(installedVoiesArr())")
}

func sayCommand(input: String) {
    let comps = input.components(separatedBy: "--voice ")
    if comps.count > 1 {
        let promper = comps[0]

        let gptVoiceCommandOverrideVoice = comps[1].replacingOccurrences(of: "--voice ", with: "")

        textToSpeech(text: promper, overrideVoice: gptVoiceCommandOverrideVoice)
    }
    else {
        textToSpeech(text: input)
    }
}




func setLoadMode(input: String) {
    switch input
    {
    case "dots": config.loadMode = LoadMode.dots
    case "waves": config.loadMode = LoadMode.waves
    case "bar": config.loadMode = LoadMode.bar
    case "matrix": config.loadMode = LoadMode.matrix
    default: config.loadMode = LoadMode.dots
    }
    let spinDex = spinner.getSpindex(input: input)
    spinner = LoadingSpinner(columnCount: termColSize, spinDex: spinDex)

    multiPrinter("set load mode to \(input)")
}

func setVoice(input: String) {
//    defaultVoice = getCereprocVoiceIdentifier(name: input)
//    multiPrinter("v set to \(input):\(defaultVoice)")
}
