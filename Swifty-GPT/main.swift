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

    // TODO: Check workspace and delete or backup if req
    // backup workspace to file folder with suffix
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
    let audioFilePath = "\(projectPath)/audio-\(UUID())(audioRecordingFileFormat)"
    let audioOut = URL(fileURLWithPath: audioFilePath)
    audioRecorder = AudioRecorder(outputFileURL: audioOut)

    requestMicrophoneAccess { granted in
        if granted {
            print("Microphone access granted.")
            // Start audio capture or other operations that require microphone access.
        } else {
            print("Microphone access denied.")
            // Handle the case where microphone access is denied.
        }
    }
    // Intro .... should add a check so it only plays once and doesn't annoy anyone.
    runTest()

    stopRandomSpinner()

    if interactiveMode {

        print(generatedOpenLine())
        openLinePrintCount += 1
        refreshPrompt(appDesc: appDesc)
    }

    if enableAEyes {
        startEyes()
    }

    // END AUDIO PROCESSING
    sema.wait()
}

var promptingRetryNumber = 0

let sema = DispatchSemaphore(value: 0)

func doPrompting(_ errors: [String] = [], overridePrompt: String = "") {
    if !overridePrompt.isEmpty {
        prompt = overridePrompt
    }
    else if let searchResultPrompt = searchResultHeadingGlobal {
        prompt = searchResultPrompt
        searchResultHeadingGlobal = nil
    }
    
    generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit, currentRetry: promptingRetryNumber, errors: errors) { response in
        if response != nil, let response {
            parseAndExecuteGPTOutput(response, errors) { success, errors in
                if success {
                    print("Parsed and executed code successfully. Opening project...")

                    textToSpeech(text: "Opening project...")
                    executeAppleScriptCommand(.openProject(name: projectName))
                }
                else {

                    print(afterBuildFailedLine)

                    if promptingRetryNumber >= retryLimit {
                        print("OVERALL prompting limit reached, stopping the process. Try a diff prompt you doof.")
                        //completion(nil)
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

    let newPrompt = promptText()
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

            do {
                try backupAndDeleteWorkspace()
            }
            catch {
                print("file error = \(error)")
            }

            print("Code did not compile successfully, trying again... (attempt \(currentRetry + 1)/\(retryLimit))")
            generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit, currentRetry: currentRetry + 1, errors: errors, completion: completion)
        }
    }
}

func executeXcodeCommand(_ command: XcodeCommand, completion: @escaping (Bool, [String]) -> Void) {
    switch command {
    case let .openProject(name):
        print("SKIPPING GPT-Opening project with name (we auto open project after gpt commands now): \(name)")
        //        executeAppleScriptCommand(.openProject(name: projectName))
        //        completion(true)
    case let .createProject(name):
        print("Creating project with name: \(name)")
        projectName = name.isEmpty ? "MyApp" : name
        projectName = preprocessStringForFilename(projectName)
        print("set current name")
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/"

        // Call the createNewWorkspace function directly
        createNewProject(projectName: name, projectDirectory: projectPath) { success in
            
            completion(success, [])

        }

    case .closeProject(name: let name):
        print("SKIPPING GPT-Closing project with name: \(name)")
        //        executeAppleScriptCommand(.closeProject(name: name))
        //        completion(true)

    case .createFile(fileName: let fileName, fileContents: let fileContents):
        if projectName.isEmpty {
            print("missing proj, creating one")
            projectName = "MyApp"

            // MIssing projecr gen// create a proj
            executeXcodeCommand(.createProject(name: projectName)) { success, errors in
                if success {
                   // completion(true, [])

                } else {
                    print("createProject failed")

                    completion(false, errors)
                }
            }
        }
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(projectName)"
        let filePath = "\(projectPath)/Sources/\(fileName)"
        print("Adding file w/ path: \(filePath) w/ contents w length = \(fileContents.count) to p=\(projectPath)")
        let added = createFile(projectPath: "\(projectPath).xcodeproj", projectName: projectName, targetName: projectName, filePath: filePath, fileContent: fileContents)
        completion(added, [])

    case .buildProject(name: let name):
        print("buildProject project with name: \(name)")
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(projectName).xcodeproj"

        buildProject(projectPath: projectPath, scheme: projectName) { success, errors in

            if success {
                completion(true, [])


//                // PROJECT BUILD SUCCESS WAIT FOR INPUT???
//                // This isn't right spot for this
//                if let choice = promptUserInput(message: "What would you like to do?: (1) Enter a new prompt? (2) Fix bugs in this project. 3.) Add a new feature to this project. 4. Add tests to this project?") {
//                    print("You chose \(choice) --- awesome!")
//                } else {
//                    print("No input was provided.")
//                }

                print(afterSuccessLine)

            } else {
                completion(false, errors)
            }
        }
    }
}

// Function to execute an high level Xcode Shell/ Ruby / AppleScript command
func executeAppleScriptCommand(_ command: XcodeCommand) {
    if !command.appleScript.isEmpty {
        
        let appleScriptCommand = command.appleScript
        let script = NSAppleScript(source: appleScriptCommand)
        var errorDict: NSDictionary? = nil
        print("Executing AppleScript: \(command)")

        script?.executeAndReturnError(&errorDict)
        if let error = errorDict {
            print("AppleScript Error: \(error)")
        }
    } else {
        print("Unsupported command")
    }
}

// Returns success / failure for some ops.
func parseAndExecuteGPTOutput(_ output: String, _ errors:[String] = [], completion: @escaping (Bool, [String]) -> Void) {

    print("🤖: \(output)")

    let (updatedString, fileContents) = extractFieldContents(output, field: "fileContents")
    lastFileContents = Array(fileContents)

    let (_, nameContents) = extractFieldContents(updatedString, field: "name")

    let (_, commandContents) = extractFieldContents(output, field: "command")

    print("found \(nameContents) names")

    print("found \(commandContents) commands")

    print("📁 found = \(fileContents.count)")

    guard !nameContents.isEmpty else {
        print("No names found... failing..")
        return completion(false, [])
    }
    guard !commandContents.isEmpty else {
        print("No commands found... failing..")
        return completion(false, [])
    }

    print("📜= \(updatedString)")

    var nameIndex = 0
    var commandIndex = 0
    var fileIndex = 0

    for gptCommandIndex in 0...commandContents.count - 1 {
        let fullCommand = commandContents[gptCommandIndex]
        print("🤖🔨: performing GPT command = \(fullCommand)")

        let createProjectPrefix = "Create project"
        let openProjectPrefix = "Open project"
        let closeProjectPrefix = "Close project"
        let createFilePrefix = "Create file"
        let googlePrefix = "Google"

        if fullCommand.hasPrefix(createProjectPrefix) {

            var name =  projectName

            projectName = name.isEmpty ? "MyApp" : name
            projectName = preprocessStringForFilename(projectName)

            textToSpeech(text: "Create project " + name + ".")

            if nameContents.count > gptCommandIndex {
                name = nameContents[gptCommandIndex]
            }

            executeXcodeCommand(.createProject(name: name)) { success, errors in

                if !success {
                    completion(success, errors)
                }
            }
        }
        else if fullCommand.hasPrefix(openProjectPrefix) {

            var name =  projectName

            projectName = name.isEmpty ? "MyApp" : name
            projectName = preprocessStringForFilename(projectName)

            textToSpeech(text: "Open project " + projectName + ".")

            if nameContents.count > gptCommandIndex {
                name = nameContents[gptCommandIndex]
            }

            executeXcodeCommand(.openProject(name: name)) { success, errors in

                if !success {
                    completion(success, errors)
                }
            }
        }
        else if fullCommand.hasPrefix(closeProjectPrefix) {

            var name =  projectName

            projectName = name.isEmpty ? "MyApp" : name
            projectName = preprocessStringForFilename(projectName)

            //textToSpeech(text: "Close project " + projectName + ".")

            if nameContents.count > gptCommandIndex {
                name = nameContents[gptCommandIndex]
            }


            // todo: check success here
            executeXcodeCommand(.createProject(name: name)) { success , errors in
                print("unknown command = \(fullCommand)")

//                if !success {
//                    completion(success, errors)
//                }
            }
        }
        else if fullCommand.hasPrefix(createFilePrefix) {
            var fileName =  UUID().uuidString

            if nameContents.count > fileIndex {
                fileName = nameContents[fileIndex]
            }

            // Fix to handle all file types , not just .swift?
            if !fileName.lowercased().hasSuffix(".swift") {
                fileName += ".swift"
            }
            fileName = preprocessStringForFilename(fileName)

            let fileContents = Array(fileContents)
            let foundFileContents: String
            if fileContents.count > fileIndex {
                foundFileContents = fileContents[fileIndex]
            }
            else {
                foundFileContents = ""
            }
            let speech = "\(fullCommand) \(fileName) with length \(fileContents.count)."
            // textToSpeech(text: speech)

            // todo: check success here
            executeXcodeCommand(.createFile(fileName: fileName, fileContents:foundFileContents)) {
                success, errors in
                if success {
                    fileIndex += 1
                    // completion(true, globalErrors)
                }
                else {
                    return completion(false, globalErrors)
                }
            }

        }
        // Experimental. I think this should probably override responses for 1 or two messages to get the research in place.
        else if fullCommand.hasPrefix(googlePrefix) {
            var query =  ""

            if nameContents.count > fileIndex {
                query = nameContents[fileIndex]
            }

            textToSpeech(text: "Googling \(query)...", overrideWpm: "250")

            googleCommand(input: query)
        }
        else {
            print("unknown command = \(fullCommand)")
        }

        nameIndex += 1
        commandIndex += 1
    }

    // todo: check to make sure the files were written
    if fileIndex == 0 || fileIndex != fileContents.count {
        print("Failed to make files.. retrying...")
        return completion(false, globalErrors)
    }

    print("Building project...")
    textToSpeech(text: "Building project \(projectName)...")

    executeXcodeCommand(.buildProject(name: projectName)) { success, errors in
        if success {
            print("Build successful.")
            textToSpeech(text: "Build successful.")

            completion(true, errors)
        }
        else {
            print("Build failed.")
            textToSpeech(text: "Build failed.")

            completion(false, errors)
        }
    }
}

main()
