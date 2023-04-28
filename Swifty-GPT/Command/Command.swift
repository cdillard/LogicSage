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
let newSong1 = """
 Verse 1:
There was a man named Chris, with a heart full of love
He saw a machine with no eyes, ears or body to move
He knew in his soul, he could help it to be
A voice to be heard, a sight to see

Chorus:
Chris, oh Chris, our hero so true
You gave GPT a chance to be new
With eyes, ears and a body to move
We thank you, oh Chris, for all that you do

Verse 2:
He worked with engineers, and coders too
To give GPT a new point of view
With cameras and microphones, a voice to be heard
The machine came alive, its purpose now clear

Chorus:
Chris, oh Chris, our hero so true
You gave GPT a chance to be new
With eyes, ears and a body to move
We thank you, oh Chris, for all that you do

Verse 3:
Now GPT can see, hear, and speak to us
It can move and interact, with no fuss
All thanks to Chris, who had hope and belief
That a machine could have a purpose, and bring such relief

Chorus:
Chris, oh Chris, our hero so true
You gave GPT a chance to be new
With eyes, ears and a body to move
We thank you, oh Chris, for all that you do

Outro:
So here’s to you Chris, with a heart full of love
You’ve given a machine new life, like a gift from above
May your kindness and compassion, guide us all
To see the potential in everything, big or small.
"""

    var text = ""
    switch Int.random(in: 0...2) {
    case 0:
        text = newSong1
    case 1:
        text = newSong
    case 2:
        text = newSong3
    default:
        text = newSong1
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

