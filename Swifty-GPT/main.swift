//
//  main.swift
//  SwiftSage
//
//  Created by Chris Dillard on 4/8/23.
//

import Foundation
import AVFAudio
import AppKit

// Note you must have xcodegen brew and gem xcodeproj installed.
// https://github.com/f/awesome-chatgpt-prompts
// Note the Xcode Console works w/ stdin the way this input works but iTerm and the Terminal app won't allow entering input
// I'm looking into it with GPT.

// Main function to run the middleware
func main() {
    // Try to preload voice synth
    textToSpeech(text: "  ", overrideVoice: defaultVoice, skipLog: true)


    resetCommandWithConfig(config: &config)

    // Tesitn when best time to initialize websock log
   // UserDefaults.resetStandardUserDefaults()
//    print(localPeerConsole.webSocketClient.websocket)

    multiPrinter("SwiftSage is loading...")

    startRandomSpinner()

    // TODOD:
    // check for whisper files
    // check for tessarect training files
    // cause a more elegant failure if issues are detected wit xcodegen or xcodeproj

    refreshPrompt(appDesc: appDesc)

    // Parse command-line arguments
    let arguments = CommandLine.arguments
    config.appName = arguments.contains("--name") ? arguments[arguments.firstIndex(of: "--name")! + 1] : "MyApp"
    config.appType = arguments.contains("--type") ? arguments[arguments.firstIndex(of: "--type")! + 1] : "iOS"
    config.language = arguments.contains("--language") ? arguments[arguments.firstIndex(of: "--language")! + 1] : "Swift"

    do {
        try backupAndDeleteWorkspace()
    }
    catch {
        multiPrinter("file error = \(error)")
    }

    // Reset the global stuff
    config.globalErrors.removeAll()
    config.lastFileContents.removeAll()
    config.lastNameContents.removeAll()

   // XcodeCommand impls TODO:
    /*
     3. Run project
     5. Test project
     6. Commit changes
     7. Push changes
     8. Send Slack message
     */

    if config.interactiveMode {

        handleUserInput()
    }
    else {
        doPrompting()
    }

    // BEGIN AUDIO PROCESSING
    let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)"
    let audioFilePath = "\(projectPath)/audio-\(UUID())\(audioRecordingFileFormat)"
    let audioOut = URL(fileURLWithPath: audioFilePath)
    audioRecorder = AudioRecorder(outputFileURL: audioOut)

    if config.voiceInputEnabled {
        requestMicrophoneAccess { granted in
            if granted {
                multiPrinter("Microphone access granted.")
                // Start audio capture or other operations that require microphone access.
            } else {
                multiPrinter("Microphone access denied.")
                config.voiceInputEnabled = false
                // Handle the case where microphone access is denied.
            }
        }
    }
    else {
        multiPrinter("Voice output disabled in sws")

    }

    DispatchQueue.global().asyncAfter(deadline: .now() + 3) {

        _ = localPeerConsole.webSocketClient.websocket

        stopRandomSpinner()

        if config.interactiveMode {

            multiPrinter(generatedOpenLine())
            openLinePrintCount += 1
            refreshPrompt(appDesc: appDesc)
        }

        if triviaEnabledSwift || triviaEnabledObjc {
            loadTriviaSystem()
        }

        if enableAEyes {
            startEyes()
        }

        // Roight time?
        if enableMacSage {
            runMacSage()
        }
    }

}

func doPrompting(_ errors: [String] = [], overridePrompt: String = "") {

    if !overridePrompt.isEmpty {
        prompt = overridePrompt
    }

    generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit, currentRetry: config.promptingRetryNumber, errors: errors) { response in

        // Generations
        multiPrinter("Retry another generation...?")

        if response != nil, let response {

            multiPrinter("Response non nil, another generation...")

            parseAndExecuteGPTOutput(response, errors) { success, errors in

                stopRandomSpinner()

                if success {
                    multiPrinter("Parsed and executed code successfully. Opening project...")

                    //textToSpeech(text: "Opening project...")

                    executeAppleScriptCommand(.openProject(name: config.projectName)) { success, errors in
                        stopRandomSpinner()
                        if success {
                            multiPrinter("opened successfully")
                        }
                        else {
                            textToSpeech(text: "Failed to open project.")

                            multiPrinter("failed to open")
                        }
                    }
                }
                else {

                    multiPrinter(afterBuildFailedLine())

                    if config.promptingRetryNumber >= retryLimit {
                        multiPrinter("OVERALL prompting limit reached, stopping the process. Try a diff prompt you doof.")

                        do {
                            try backupAndDeleteWorkspace()
                        }
                        catch {
                            multiPrinter("file error = \(error)")
                        }

                        return
                    }

                    config.promptingRetryNumber += 1

                    if !config.interactiveMode {
                        doPrompting(errors)
                    }
                }
            }
        } else {
            multiPrinter("Failed to generate compilable code within the retry limit.")
        }
    }
}

func createFixItPrompt(errors: [String] = [], currentRetry: Int) -> String {
    let swiftnewLine = """

    """
    var newPrompt = prompt
    if !errors.isEmpty {
        newPrompt += fixItPrompt
        if !errors.isEmpty { //currentRetry > 0 {
            newPrompt += Array(Set(errors)).joined(separator: "\(swiftnewLine)\(swiftnewLine)\n")
            newPrompt += swiftnewLine

            if includeSourceCodeFromPreviousRun {
                // Add optional mode to just send error, file contents
                newPrompt += includeFilesPrompt()
                newPrompt += swiftnewLine

                for contents in config.lastFileContents {
                    newPrompt += contents
                    newPrompt += "\(swiftnewLine)\(swiftnewLine)\n"
                }
            }
        }
    }
    return newPrompt
}

func createIdeaPrompt(command: String) -> String {
    appDesc = command
    refreshPrompt(appDesc: command)

    let newPrompt = promptText(noGoogle: !config.enableGoogle, noLink: !config.enableLink)
    return newPrompt
}

func generateCodeUntilSuccessfulCompilation(prompt: String, retryLimit: Int, currentRetry: Int, errors: [String] = [], completion: @escaping (String?) -> Void) {
    if currentRetry >= retryLimit {
        multiPrinter("Retry limit reached, stopping the process.")
        completion(nil)
        return
    }

    sendPromptToGPT(prompt: prompt, currentRetry: currentRetry, isFix: !errors.isEmpty) { response, success in
        if success {
            completion(response)
        } else {
            multiPrinter("Code did not compile successfully, trying again... (attempt \(currentRetry + 1)/\(retryLimit))")
            generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit, currentRetry: currentRetry + 1, errors: errors, completion: completion)
        }
    }
}


// Running in Terminal and iTerm2 is still elusive.. I wonder what must be disabled.
main()

RunLoop.main.run()
