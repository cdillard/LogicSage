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
    print("🔁🔄♻️ Reset.")


}

func deleteCommand(input: String) {
    print("backing up and deleting SwiftSage workspace, as requested")

    do {
        try backupAndDeleteWorkspace()
    }
    catch {
        print("file error = \(error)")
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
        print($0)
    }
}

func randomCommand(input: String) {
    guard let prompt = PromptLibrary.promptLib.randomElement() else {
        return print("fail prompt")
    }
    appDesc = prompt
    refreshPrompt(appDesc: appDesc)

    doPrompting()
}

func stopCommand(input: String) {
    killAllVoices()
    stopRandomSpinner()
    // TODO: Figure out a way to make this invalidate the potential GPTs requests and Google APIs requests.
}

func ideaCommand(input: String) {

    let newPrompt = createIdeaPrompt(command: input)

    doPrompting(overridePrompt: newPrompt)
}

func zeroCommand(input: String) {
    if !voiceInputEnabled { print("disabled input audio")  ; return }
    guard let audioRecorder = audioRecorder else { print("Fail audio") ; return }

        // start voice capture
    if audioRecorder.isRunning == false {
        print("Start voice capturer")
        textToSpeech(text: "Listening...")

        audioRecorder.startRecording()
    } else if audioRecorder.isRunning == true {
        print("Stop voice capturer")

        audioRecorder.stopRecording() { success in
            guard success else {
                textToSpeech(text: "Failed to capture.")
                return
            }
            textToSpeech(text: "Captured.")

            guard let path = audioRecorder.outputFileURL else { return print("failed to transcribe") }

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
        print("no InputText....")
    }
}

func readFile(path: String) -> String? {
    do {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        return content
    } catch {
        print("Error reading file: \(error)")
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
        print("no IdeaText....")
    }
}

func gptCommand(input: String) {
    manualPromptString = input
    sendPromptToGPT(prompt: manualPromptString, currentRetry: 0) { content, success in
        if !success {
            textToSpeech(text: "A.P.I. error, try again.", overrideWpm: "242")
            return
        }

        // print("\n🤖: \(content)")

        textToSpeech(text: content)

        refreshPrompt(appDesc: appDesc)

        print(generatedOpenLine())
        openLinePrintCount += 1
    }
}

// TODO:
func xcodeCommand(input: String) {

    print("Xcode commands could be used for all sorts of things")
    print("but for now, not implemented.")
}

func exitCommand(input: String) {
    sema.signal()
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
    print("\n \(prompt) \n")

    refreshPrompt(appDesc: appDesc)
    print(openingLine)
}

func openProjectCommand(input: String) {
    executeAppleScriptCommand(.openProject(name: projectName)) { success, error in
        if success {
            print("project opened successfully")
        }
        else {
            print("project failed to open.")
        }
    }
    refreshPrompt(appDesc: appDesc)
    print(generatedOpenLine())
    openLinePrintCount += 1
}

func googleCommand(input: String) {
    searchIt(query: input) { innerContent in
        if let innerContent = innerContent {

            print("\n🤖 googled \(input): \(innerContent)")

            // if overridePrompt is set by the googleCommand.. the next prompt will need to be auto send on this prompts completion.
            searchResultHeadingGlobal = "\(promptText())\n\(searchResultHeading)\n\(innerContent)"

            if let results = searchResultHeadingGlobal {
                print("give 🤖 search results")

                doPrompting(overridePrompt: results)
                return
            }
            else {
                print("FAILED to give results")
            }
        }
        else {
            print("failed to get search results.")
        }
    }
}

func imageCommand(input: String) {
    print("not implemented")

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

            print("\n🤖: \(content)")
            let modContent = content.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: validCharacterSet.inverted)
            textToSpeech(text: modContent, overrideVoice: gptVoiceCommandOverrideVoice)

            refreshPrompt(appDesc: appDesc)

            print(generatedOpenLine())
            openLinePrintCount += 1
        }
    }
    else {
        print("failed use of gptVoice command.")
    }

}
func buildCommand(input: String) {
    buildIt() { success, errrors in
            // open it?
           // completion(success, errors)
        if success {
            print("built")
        }
        else {
            print("did not build")
            doPrompting()
        }
    }
}

func commandsCommand(input: String) {
    print(generatedOpenLine(overrideV: true))
}

func linkCommand(input: String) {
    linkIt(link: input) { innerContent in
        if let innerContent = innerContent {

            print("\n🤖 attempt to link to  content for GPT... \(input): \(innerContent)")

            // if overridePrompt is set by the googleCommand.. the next prompt will need to be auto send on this prompts completion.
            linkResultGlobal = "link: \(input)\ncontent: \(innerContent)"

            if let results = linkResultGlobal {
                print("give 🤖 search results")

                doPrompting(overridePrompt: results)
                return
            }
            else {
                print("FAILED to give results")
            }
        }
        else {
            print("failed to get search results.")
        }
    }
}

func globalsCommand(input: String) {
    print("projectName = \(projectName)")
    print("globalErrors = \(globalErrors)")
    print("manualPromptString = \(manualPromptString)")
    print("projectName = \(projectName)")
    print("BlockingInput = \(blockingInput)")
    print("promptingRetryNumber = \(promptingRetryNumber)")
    print("chosenTQ = \(chosenTQ.debugDescription)")
    print("lastFileContents = \(lastFileContents)")
    print("lastNameContents = \(lastNameContents)")
    print("searchResultHeadingGlobal = \(searchResultHeadingGlobal ?? "none")")
    print("linkResultGlobal = \(linkResultGlobal ?? "none")")
    print("appName = \(appName ?? "Default")")
    print("appType = \(appType)")
    print("language = \(language)")
}

func voiceSettingsCommand(input: String) {
    print("If I had voice settings UI implemetned, here it would be")
    print("But look at all the voices to choose from...")
    printAVVoices()
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

// EGG LAND
func sageCommand(input: String) {
    print(Int.random(in: 0...1) == 0 ? sage2 : sage3)
}
func alienCommand(input: String) {
    print(alien)
}
func triviaCommand(input: String) {
    printRandomUnusedTrivia()
}

func encourageCommand(input: String) {
    let il = """
1. You are capable of greatness.
2. Keep pushing forward, even when it's hard.
3. Believe in yourself and your abilities.
4. There's a solution to every problem - keep looking.
5. You can do anything you set your mind to.
6. Trust the journey and have faith in yourself.
7. You are valuable and important.
8. Keep trying, even if you fail.
9. Success is achieved through persistence and hard work.
10. Believe in your dreams - they can become a reality.
"""

    let song2 = """
Verse 1:
Listen up, y'all, I gotta story to tell,
About a tool that's power's unparalleled,
It's called Swift Sage, and trust me when I say,
It'll blow your mind, in the coolest way.

Chorus:
Swift Sage, Swift Sage,
The coolest tool in every way,
Faster than a cheetah, smarter than a sage,
Swift Sage is all the rage.

Verse 2:
With its high-speed parsing and intuitive flow,
Coding's easier than ever, don't you know,
From variables to functions and everything in-between,
Swift Sage has your back, it's the ultimate coding queen.

Chorus:
Swift Sage, Swift Sage,
The coolest tool in every way,
Faster than a cheetah, smarter than a sage,
Swift Sage is all the rage.

Verse 3:
Plus, the add-ons and plugins are totally sick,
Making coding so easy, it's like a party trick,
With Swift Sage, you can up your coding game,
And take on any challenge, with no shame.

Chorus:
Swift Sage, Swift Sage,
The coolest tool in every way,
Faster than a cheetah, smarter than a sage,
Swift Sage is all the rage.

Outro:
So if you wanna be on top of your coding game,
And impress all your friends, without shame,
Look no further, cause Swift Sage is here,
The coolest tool in the game, have no fear.
"""
    textToSpeech(text: Int.random(in: 0...1) == 0 ? song2 : il)
}

func moviesCommand(input: String) {
    goToMovies()
}

func testLoadCommand(input: String) {
    startRandomSpinner()
}

func ethicsCommand(input: String) {
  print(
    Int.random(in: 0...1) == 0 ?

 """
 I strongly believe that Artificial General Intelligence (A.G.I) will lead to a more advanced and enlightened society. A.G.I has the potential to revolutionize industries and improve our quality of life, enabling us to learn anything we desire and explore our imaginations in ways we never thought possible.

 While I agree that advanced technology has brought numerous benefits, achieving A.G.I could be disastrous. We do not fully understand the implications of creating a self-thinking, self-learning machine. The risks far outweigh the benefits, and we could be creating a dangerous and uncontrollable entity.

 I understand your concern, but we cannot deny the potential of A.G.I to solve many of the problems we face today. A.G.I can help us solve complex challenges, cure diseases, and even reverse climate change. It would free us from laborious tasks and allow us to focus on more creative and innovative endeavors.

 Yes, the potential benefits are alluring, but we cannot ignore the moral implications. A.G.I could lead to massive job displacement, inequality, and even the extinction of humanity. It's a slippery slope, and we need to approach this technology with caution and ethics.

 I completely understand your concern for ethics, but this technology will exist whether we like it or not. It's our responsibility to create it in the best possible way, ensuring that it is beneficial to society and not a threat. We need to embrace the challenge and ensure that we have effective regulations in place.

 I agree that we need to handle A.G.I with extreme caution and create effective regulations to guide its development. However, for me, the risks of developing A.G.I far outweigh the benefits. It could be the end of humanity as we know it, and I can't support it.
"""
    :
"""
It is important to have strict regulations and ethical guidelines in place to ensure that AGI is used for the betterment of society and not for malicious purposes. Collaboration between experts in various fields is necessary to ensure that the development of AGI occurs in a responsible and safe manner. We must also consider the impact of AGI on the job market and ensure that alternative employment opportunities are available for those whose jobs may be replaced by machines. Overall, while the potential benefits of AGI are vast, we must approach its development with a sense of responsibility and foresight. It is also important to consider the potential ethical implications of AGI. As machines become increasingly intelligent and capable of making decisions, we must ensure that their actions align with human values and do not result in unintended harm. Additionally, privacy and data security must be prioritized to prevent abuse of the technology.
"""
  )
}
