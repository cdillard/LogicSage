//
//  main.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/8/23.
//

import Foundation
import AVFAudio

// Note you must have xcodegen brew and gem xcodeproj installed.

// Note the Xcode Console works w/ stdin the way this input works but iTerm and the Terminal app won't allow entering input
// I'm looking into it with GPT.

// Main function to run the middleware
func main() {
    print("Swifty-GPT is loading...")
    startRandomSpinner()

    // TODOD:
    // check for whisper files
    // check for tessarect training files
    // cause a more elegant failure if issues are detected wit xcodegen or xcodeproj

    refreshPrompt(appDesc: appDesc)

    // Parse command-line arguments
    let arguments = CommandLine.arguments
    appName = arguments.contains("--name") ? arguments[arguments.firstIndex(of: "--name")! + 1] : "MyApp"
    appType = arguments.contains("--type") ? arguments[arguments.firstIndex(of: "--type")! + 1] : "iOS"
    language = arguments.contains("--language") ? arguments[arguments.firstIndex(of: "--language")! + 1] : "Swift"

    do {
        try backupAndDeleteWorkspace()
    }
    catch {
        print("file error = \(error)")
    }

    // Reset the global stuff
    globalErrors.removeAll()
    lastFileContents.removeAll()
    lastNameContents.removeAll()

   // XcodeCommand impls TODO:
    /*
     3. Run project
     5. Test project
     6. Commit changes
     7. Push changes
     8. Send Slack message
     */

    if interactiveMode {

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

    // Lets just disable it by default...
    if intro { runTest() }

    stopRandomSpinner()

    if interactiveMode {

        print(generatedOpenLine())
        openLinePrintCount += 1
        refreshPrompt(appDesc: appDesc)
    }

    if triviaEnabledSwift || triviaEnabledObjc {
        loadTriviaSystem()
        //printRandomUnusedTrivia()
    }

    if enableAEyes {
        startEyes()
    }

    // END AUDIO PROCESSING
    sema.wait()
}

func doPrompting(_ errors: [String] = [], overridePrompt: String = "") {

    if !overridePrompt.isEmpty {
        prompt = overridePrompt
    }

    generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit, currentRetry: promptingRetryNumber, errors: errors) { response in

        // Generations
        print("Retry another generation...?")

        if response != nil, let response {

            print("Response non nil, another generation...")

            parseAndExecuteGPTOutput(response, errors) { success, errors in
                if success {
                    print("Parsed and executed code successfully. Opening project...")

                    textToSpeech(text: "Opening project...")


                    executeAppleScriptCommand(.openProject(name: projectName)) { success, errors in
                        if success {
                            print("opened successfully")
                        }
                        else {
                            textToSpeech(text: "Failed to open project.")

                            print("failed to open")
                        }
                    }
                }
                else {

                    print(afterBuildFailedLine())

                    if promptingRetryNumber >= retryLimit {
                        print("OVERALL prompting limit reached, stopping the process. Try a diff prompt you doof.")

                        do {
                            try backupAndDeleteWorkspace()
                        }
                        catch {
                            print("file error = \(error)")
                        }

                        sema.signal()
                        return
                    }

                    promptingRetryNumber += 1

                    if !interactiveMode {
                        doPrompting(errors)
                    }
                }
            }
        } else {
            print("Failed to generate compilable code within the retry limit.")
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

                for contents in lastFileContents {
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

    let newPrompt = promptText(noGoogle: !enableGoogle, noLink: !enableLink)
    return newPrompt
}

func generateCodeUntilSuccessfulCompilation(prompt: String, retryLimit: Int, currentRetry: Int, errors: [String] = [], completion: @escaping (String?) -> Void) {
    if currentRetry >= retryLimit {
        print("Retry limit reached, stopping the process.")
        completion(nil)
        return
    }

    sendPromptToGPT(prompt: prompt, currentRetry: currentRetry, isFix: !errors.isEmpty) { response, success in
        if success {
            completion(response)
        } else {

            print("Code did not compile successfully, trying again... (attempt \(currentRetry + 1)/\(retryLimit))")
            generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit, currentRetry: currentRetry + 1, errors: errors, completion: completion)
        }
    }
}

main()
