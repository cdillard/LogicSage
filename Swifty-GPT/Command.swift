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
    killAllVoices()
    stopRandomSpinner()
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
    multiPrinter(generatedOpenLine(overrideV: true))
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
    multiPrinter("\(avVoices)")
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
    multiPrinter(Int.random(in: 0...1) == 0 ? sage2 : sage3)
}
func alienCommand(input: String) {
    multiPrinter(alien)
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
Once upon a time, there was a young man named Chris. He had always been passionate about technology and coding. Even from a very young age, Chris showed a natural talent for coding and was able to create complex programs and applications with ease.

As he grew older, Chris continued his passion for coding and decided to pursue a career in it. He studied Computer Science at a prestigious university, and after many sleepless nights spent coding, he graduated top of his class.

After Chris graduated, he spent some time working as a software developer for various companies. However, he soon realized that he needed a new challenge, and so he decided to create his own project.

Chris began to work on an Xcode CLI (Command Line Interface), which would be different from any other CLI on the market. He wanted to create a CLI that was easy to use, intuitive, and had vast capabilities.

Chris spent months working on the Xcode CLI, and finally, after many sleepless nights, he had created a CLI that was perfect. He called it the "Chris CLI," and it quickly gained popularity among developers worldwide.

The Chris CLI was easy to use, and it had a vast range of capabilities. Developers from all over the world started using it, and it quickly became the go-to CLI for many. Chris's creation had become a massive success, and he became known as a wise man in the world of coding.

Despite his success, Chris remained humble and never stopped learning. He continued to work on the Chris CLI, making it more efficient and user-friendly. He received many awards and accolades for his work, but what mattered most to him was that what he had created was being used by so many people.

In conclusion, Chris may have been young, but he was wise beyond his years. His creation, the Chris CLI, changed the world of coding and became an essential tool for many developers worldwide. Chris's dedication, hard work, and passion were the keys to his success, and he remained an inspiration to many aspiring coders for generations to come.
"""
    let song3 = """
 In the year 2050, the world had become a vast network of interconnected virtual realities. People spent most of their time in these virtual environments, participating in various activities and pursuing their interests. Among these virtual environments were some of the most immersive ones, where people could experience vast open landscapes.

 However, there was a problem. The creation of these virtual landscapes was a time-consuming process, and it required a lot of resources. The traditional way of creating virtual landscapes involved manually placing every blade of grass, every tree, and every rock individually, which was not only tedious but also lacked the realism that people craved.

 But everything changed when a small team of developers at a startup company called "ProGen" developed a revolutionary new technology that could procedurally generate realistic landscapes in seconds.

 The technology used advanced algorithms that could analyze real-world topography, climate data, and other environmental factors to create highly realistic and detailed environments. It could also incorporate various features such as lakes, rivers, and mountains based on the data fed into the system.

 The initial release of the technology was a massive hit, and the virtual landscape market exploded overnight. It was not long before the technology was adapted for various other applications, such as game development, education, and even urban planning.

 As the technology continued to evolve, developers at ProGen continued to tweak and improve the algorithms, adding new features and improving the overall realism of the generated environments. The landscapes not only appeared highly realistic but were also highly adaptable to changes, further expanding their potential uses.

 The most significant impact of this technology was on the gaming industry, where developers could now create expansive and highly detailed game worlds in a fraction of the time it took earlier. Gamers could now experience vast open worlds that were almost indistinguishable from reality.

 The technology even found its way into the film industry where it simplified the creation of realistic backgrounds and even entire environments.  Hollywood studios who relied on expensive movie sets could now create more realistic on-screen landscapes for a fraction of the cost.

 The future looked bright for ProGen and its team, and soon they became one of the most influential tech companies in the world. However, as the technology continued to evolve, some began to worry about the ethical implications of creating vast simulated environments that could potentially replace the real world.

 But for the moment, people were content exploring and experiencing the vast virtual environments created by ProGen, and the future of landscape creation seemed brighter than ever before.
 """
    var chosenSong = song2
    switch Int.random(in: 0...2) {
    case 0:
        chosenSong = song2
    case 1:
        chosenSong = il
    case 2:
        chosenSong = song3
    default:
        chosenSong = song2
    }

    textToSpeech(text: chosenSong)
}

func moviesCommand(input: String) {
    goToMovies()
}

func testLoadCommand(input: String) {
    startRandomSpinner()
}

func ethicsCommand(input: String) {
  multiPrinter(
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
While AI has the potential to revolutionize industries and make them more efficient, we must also prioritize the well-being of human workers. It's important for governments and businesses to provide resources for workers to adapt to the changing job market and acquire skills that are in demand. Additionally, we should encourage the development of AI in areas that complement humans, rather than fully replacing them. This can create a symbiotic relationship between humans and AI, where they work together to achieve greater outcomes.
 I agree that AI brings with it a lot of potential for progress and innovation. However, we need to be cautious about how we integrate it into our society. The widespread use of AI could drastically change the job market and further exacerbate income inequality. Additionally, relying too heavily on AI could lead to a reduction in critical thinking skills and creativity among humans. Therefore, we need to strike a balance between utilizing AI effectively and preserving the unique skills and abilities of humans
"""
  )
}
