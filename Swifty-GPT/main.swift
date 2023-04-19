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

// Add your Open AI key to the GPT-Info.plist file
var OPEN_AI_KEY:String {
    get {
        guard let apiKey = plistHelper.objectFor(key: "OPEN_AI_KEY", plist: "GPT-Info") as? String else { return "" }
        return apiKey
    }
}
let PIXABAY_KEY = "PIXABAY_KEY"

// TODO: Fix hardcoded paths.
let xcodegenPath = "/opt/homebrew/bin/xcodegen"
var infoPlistPath:String {
    get {
        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            return plistPath
        }
        return ""
    }
}
var rubyScriptPath:String {
    get {
        if let scriptPath = Bundle.main.path(forResource: "add_file_to_project", ofType: "rb") {
            return scriptPath
        }
        return ""
    }
}
let apiEndpoint = "https://api.openai.com/v1/chat/completions"

let swiftyGPTWorkspaceFirstName = "SwiftyGPTWorkspace"

let swiftyGPTWorkspaceName = "\(swiftyGPTWorkspaceFirstName)/Workspace"

// Configurable settings for AI.
let retryLimit = 10
let fixItRetryLimit = 3

let aiNamedProject = true
let tryToFixCompileErrors = true
let includeSourceCodeFromPreviousRun = true
let interactiveMode = true
let asciAnimations = false

let voiceOutputEnabled = true
let voiceInputEnabled = true
let enableAEyes = false

var termColSize = 5
var spinner: LoadingSpinner = LoadingSpinner(columnCount: termColSize)
let animator = TextAnimator(text: loadingText)

var audioRecorder: AudioRecorder?

// Globals  I know....
var projectName = "MyApp"
var globalErrors = [String]()
var manualPromptString = ""

var lastFileContents = [String]()
var lastNameContents = [String]()

var appName = "MyApp"
var appType = "iOS"
var language = "Swift"

// Main function to run the middleware
func main() {
    print("Swifty-GPT is loading...")
    spinner.start()
//    if let terminalWidth = getTerminalWidth() {
//        termColSize = terminalWidth
//    }


    //  ceheck for whisper files
    // check for tessarect training files

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
    // Intro ....
    // SHOULD Add, hasHeardInto check
    runTest()

    spinner.stop()

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
                newPrompt += includeFilesPrompt
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
        print("set current name")
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/"

        // Call the createNewWorkspace function directly
        createNewProject(projectName: name, projectDirectory: projectPath)
        completion(true, [])

    case .closeProject(name: let name):
        print("SKIPPING GPT-Closing project with name: \(name)")
        //        executeAppleScriptCommand(.closeProject(name: name))
        //        completion(true)

    case .createFile(fileName: let fileName, fileContents: let fileContents):
        if projectName.isEmpty {
            print("missing proj, creating one")
            projectName = "MyApp"

            // MIssing projecr gen// create a proj
            executeXcodeCommand(.createProject(name: projectName)) { success, errors in }
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


                // PROJECT BUILD SUCCESS WAIT FOR INPUT???
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

        if fullCommand.hasPrefix("Create project") {

            var name =  projectName

            projectName = name.isEmpty ? "MyApp" : name

            textToSpeech(text: "Create project " + name + ".")

            if nameContents.count > gptCommandIndex {
                name = nameContents[gptCommandIndex]
            }

            executeXcodeCommand(.createProject(name: name)) { success, errors in }
        }
        else if fullCommand.hasPrefix("Open project") {

            var name =  projectName

            projectName = name.isEmpty ? "MyApp" : name

            textToSpeech(text: "Open project " + projectName + ".")

            if nameContents.count > gptCommandIndex {
                name = nameContents[gptCommandIndex]
            }

            executeXcodeCommand(.openProject(name: name)) { success, errors in }
        }
        else if fullCommand.hasPrefix("Close project") {

            var name =  projectName

            projectName = name.isEmpty ? "MyApp" : name

            textToSpeech(text: "Close project " + projectName + ".")

            if nameContents.count > gptCommandIndex {
                name = nameContents[gptCommandIndex]
            }


            // todo: check success here
            executeXcodeCommand(.createProject(name: name)) { _ , _ in  }
        }
        else if fullCommand.hasPrefix("Create file") {
            var fileName =  UUID().uuidString

            if nameContents.count > fileIndex {
                fileName = nameContents[fileIndex]
            }

            if !fileName.lowercased().hasSuffix(".swift") {
                fileName += ".swift"
            }

            let fileContents = Array(fileContents)
            let foundFileContents: String
            if fileContents.count > fileIndex {
                foundFileContents = fileContents[fileIndex]
            }
            else {
                foundFileContents = ""
            }
            let speech = "\(fullCommand) \(fileName) with length \(fileContents.count)."
            textToSpeech(text: speech)

            // todo: check success here
            executeXcodeCommand(.createFile(fileName: fileName, fileContents:foundFileContents)) { success, errors in   }


            fileIndex += 1
        }
        else {
            print("unknown command = \(fullCommand)")
        }

        nameIndex += 1
        commandIndex += 1
    }

    // todo: check to make sure the files were written
//        if filesWritten == 0 || filesWritten != fileContents.count {
//            print("Failed to make files.. retrying...")
//            return completion(false)
//        }

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

func getDirectory() -> String {
    let arguments = CommandLine.arguments

    guard arguments.count > 1 else {
        print("Please provide the folder path as an argument.")
        return ""

    }

    let folderPath = arguments[1]

    let fileManager = FileManager.default
    let folderURL = URL(fileURLWithPath: folderPath)

    var isDirectory: ObjCBool = false
    guard fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDirectory), isDirectory.boolValue else {
        print("The provided path does not exist or is not a directory.")
       return ""
    }
    return folderURL.path
}

main()

