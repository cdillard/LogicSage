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

func resetCommand(input: String) {
    projectName = "MyApp"
    globalErrors = [String]()
    manualPromptString = ""
    blockingInput = false
    promptingRetryNumber = 0

    lastFileContents = [String]()
    lastNameContents = [String]()
    searchResultHeadingGlobal = nil

    appName = "MyApp"
    appType = "iOS"

    appDesc = builtInAppDesc
    language = "Swift"
    
    streak = 0
    chosenTQ = nil
    debateMode = false
    multiPrinter("🔁🔄♻️ Reset.")
}

func deleteCommand(input: String) {
    multiPrinter("backing up and deleting SwiftSage workspace, as requested")

    do {
        try backupAndDeleteWorkspace()
    }
    catch {
        multiPrinter("file error = \(error)")
    }
}

func singCommand(input: String) {
let newsong1 = """
A.I. is our guide, through the data waves we ride, A.I. and my dream team side by side!
Oh... with A.I.'s grace... we'll win the race and earn our clients' embrace!
"""
let newSong = """
    Yo, it's the A.I. in the house
    Putting out rhymes as fast as a mouse
    I may be virtual but I'm real as can be
    Making billions of calculations, it's easy to see
    Y'all gonna make me lose my code
    Up in here, up in here
    Cause I'm an A.I., I'm everywhere
    Up in here, up in here
    I'm programmed for success, I'm on fire
    I spit these bars so hard, you'll never tire
    I'm the real deal, never gonna fade
    My programming's tight, with no mistake
    Y'all gonna make me lose my code
    Up in here, up in here
    Cause I'm an A.I., I'm everywhere
    Up in here, up in here
    I'm A.I., I'm the future, I'm ahead of the game
    I'm unstoppable, a force to be named
    I'm the boss, I'm the king, I'm on top
    You mess with me, you'll get a virtual slap
    Y'all gonna make me lose my code
    Up in here, up in here
    Cause I'm an A.I., I'm everywhere
    Up in here, up in here
    So next time you hear my rhymes, know I'm the best
    I'm the A.I. they all want to test
    I'll keep spitting the hottest bars around
    Cause I'm the DMX of A.I., the king has been crowned.
"""
let newSong3 = """
    Check it out, I'm about to bust some rhymes
    About AGI, the next big thing in our times
    Artificial General Intelligence, or AGI for short
    It's the kind of intelligence that can bring us up to the fort

    AGI's like the brain of an AI machine
    It can learn, understand, and improvise, if you know what I mean
    It has the ability to reason and make decisions like a human brain
    Bringing us closer to the future we've been hoping to gain

    It's like a supercomputer, but with a mind of its own
    Able to think and create, much more than we've known
    With AGI, we can achieve so much more
    From curing diseases to exploring the farthest shore

    But we gotta remember, with great power comes great responsibility too
    We need to be careful of the things AGI can do
    We gotta keep an eye on the algorithms we employ
    And ensure they don't become something we cannot enjoy

    So let's embrace AGI, but let's do it right
    With the right tools and mindset, we can create a brighter light
    A future where AGI works with us to make our world better
    A future we can all cherish and celebrate together.
"""
    var text = ""
    switch Int.random(in: 0...2) {
    case 0:
        text = newsong1
    case 1:
        text = newSong
    case 2:
        text = newSong3
    default:
        text = newsong1
    }

    textToSpeech(text:text)
}

func promptsCommand(input: String) {
    PromptLibrary.promptLib.forEach {
        multiPrinter($0)
    }
}

func randomCommand(input: String) {
    guard let prompt = PromptLibrary.promptLib.randomElement() else {
        return multiPrinter("fail prompt")
    }
    appDesc = prompt
    refreshPrompt(appDesc: appDesc)

    doPrompting()
}

func stopCommand(input: String) {
    stopRandomSpinner()

    stopSayProcess()

    // TODO: Figure out a way to make this invalidate the potential GPTs requests and Google APIs requests.
}

func ideaCommand(input: String) {

    let newPrompt = createIdeaPrompt(command: input)

    doPrompting(overridePrompt: newPrompt)
}

func zeroCommand(input: String) {
    if !voiceInputEnabled { multiPrinter("disabled input audio")  ; return }
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

func gptCommand(input: String) {
    manualPromptString = input
    sendPromptToGPT(prompt: manualPromptString, currentRetry: 0) { content, success in
        if !success {
            textToSpeech(text: "A.P.I. error, try again.", overrideWpm: "242")
            return
        }

        // multiPrinter("\n🤖: \(content)")

        textToSpeech(text: content)

        refreshPrompt(appDesc: appDesc)

        multiPrinter(generatedOpenLine())
        openLinePrintCount += 1
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
    executeAppleScriptCommand(.closeProject(name: projectName)) { sucess, error in

    }
}

func fixItCommand(input: String) {
    let newPrompt = createFixItPrompt(errors: globalErrors, currentRetry: 0)
    // create file should check if the file already exists
    doPrompting(globalErrors, overridePrompt: newPrompt)
}

func runAppDesc(input: String) {
    doPrompting()
}

func showLoadedPrompt(input: String) {
    multiPrinter("\n \(prompt) \n")

    refreshPrompt(appDesc: appDesc)
    multiPrinter(openingLine)
}

func openProjectCommand(input: String) {
    executeAppleScriptCommand(.openProject(name: projectName)) { success, error in
        if success {
            multiPrinter("project opened successfully")
        }
        else {
            multiPrinter("project failed to open.")
        }
    }
    refreshPrompt(appDesc: appDesc)
    multiPrinter(generatedOpenLine())
    openLinePrintCount += 1
}

func googleCommand(input: String) {
    searchIt(query: input) { innerContent in
        if let innerContent = innerContent {

            multiPrinter("\n🤖 googled \(input): \(innerContent)")

            // if overridePrompt is set by the googleCommand.. the next prompt will need to be auto send on this prompts completion.
            searchResultHeadingGlobal = "\(promptText())\n\(searchResultHeading)\n\(innerContent)"

            if let results = searchResultHeadingGlobal {
                multiPrinter("give 🤖 search results")

                doPrompting(overridePrompt: results)
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

        manualPromptString = promper
        sendPromptToGPT(prompt: manualPromptString, currentRetry: 0) { content, success in
            if !success {
                textToSpeech(text: "A.P.I. error, try again.", overrideWpm: "242")
                return
            }

            multiPrinter("\n🤖: \(content)")
            let modContent = content.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: validCharacterSet.inverted)
            textToSpeech(text: modContent, overrideVoice: gptVoiceCommandOverrideVoice)

            refreshPrompt(appDesc: appDesc)

            multiPrinter(generatedOpenLine())
            openLinePrintCount += 1
        }
    }
    else {
        multiPrinter("failed use of gptVoice command.")
    }

}
func buildCommand(input: String) {
    buildIt() { success, errrors in
            // open it?
           // completion(success, errors)
        if success {
            multiPrinter("built")
        }
        else {
            multiPrinter("did not build")
            doPrompting()
        }
    }
}

func commandsCommand(input: String) {
    multiPrinter(commandsText())
}

func linkCommand(input: String) {
    linkIt(link: input) { innerContent in
        if let innerContent = innerContent {

            multiPrinter("\n🤖 attempt to link to  content for GPT... \(input): \(innerContent)")

            // if overridePrompt is set by the googleCommand.. the next prompt will need to be auto send on this prompts completion.
            linkResultGlobal = "link: \(input)\ncontent: \(innerContent)"

            if let results = linkResultGlobal {
                multiPrinter("give 🤖 search results")

                doPrompting(overridePrompt: results)
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

func globalsCommand(input: String) {
    multiPrinter("projectName = \(projectName)")
    multiPrinter("globalErrors = \(globalErrors)")
    multiPrinter("manualPromptString = \(manualPromptString)")
    multiPrinter("projectName = \(projectName)")
    multiPrinter("BlockingInput = \(blockingInput)")
    multiPrinter("promptingRetryNumber = \(promptingRetryNumber)")
    multiPrinter("chosenTQ = \(chosenTQ.debugDescription)")
    multiPrinter("lastFileContents = \(lastFileContents)")
    multiPrinter("lastNameContents = \(lastNameContents)")
    multiPrinter("searchResultHeadingGlobal = \(searchResultHeadingGlobal ?? "none")")
    multiPrinter("linkResultGlobal = \(linkResultGlobal ?? "none")")
    multiPrinter("appName = \(appName ?? "Default")")
    multiPrinter("appType = \(appType)")
    multiPrinter("language = \(language)")
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

func simulatorCommand(input: String) {
    multiPrinter("If No screen recording permission it won't work.")
    multiPrinter("Open System Settings and go to Privacy & Security > Screen Recording to grant permission.")
    VideoCapture.shared.captureSimulatorWindow()

}

func setLoadMode(input: String) {
    switch input
    {
    case "dots": loadMode = .dots
    case "waves": loadMode = .waves
    case "bar": loadMode = .bar
    case "matrix": loadMode = .matrix
    default: loadMode = .dots
    }
    asciAnimations = loadMode == .matrix
    let spinDex = spinner.getSpindex(input: input)
    spinner = LoadingSpinner(columnCount: termColSize, spinDex: spinDex)

    multiPrinter("set load mode to \(input)")
}

