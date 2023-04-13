//
//  main.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/8/23.
//

import Foundation

// Note you must have xcodegen brew and gem xcodeproj installed.

// Replace this with your OpenAI API key
let OPEN_AI_KEY = "sk-OPEN_AI_KEY"
let PIXABAY_KEY = "PIXABAY_KEY"

// TODO: Fix hardcoded paths.
let xcodegenPath = "/opt/homebrew/bin/xcodegen"
let infoPlistPath = "/Users/sprinchar/Documents/GPT/Swifty-GPT/Swifty-GPT/Info.plist"
let rubyScriptPath = "/Users/sprinchar/Documents/GPT/Swifty-GPT/Swifty-GPT/add_file_to_project.rb"
let apiEndpoint = "https://api.openai.com/v1/chat/completions"
let swiftyGPTWorkspaceName = "SwiftyGPTWorkspace"

// Configurable settings for AI.
let retryLimit = 10
let fixItRetryLimit = 3

let aiNamedProject = true
let tryToFixCompileErrors = true
let includeSourceCodeFromPreviousRun = true

// Globals  I know....
var projectName = ""
var globalErrors = [String]()

var lastFileContents = [String]()
var lastNameContents = [String]()

var appName = ""
var appType = ""
var language = ""

// Main function to run the middleware
func main() {
    // Parse command-line arguments
    let arguments = CommandLine.arguments
    appName = arguments.contains("--name") ? arguments[arguments.firstIndex(of: "--name")! + 1] : "MyApp"
    appType = arguments.contains("--type") ? arguments[arguments.firstIndex(of: "--type")! + 1] : "iOS"
    language = arguments.contains("--language") ? arguments[arguments.firstIndex(of: "--language")! + 1] : "Swift"

    // TODO: Check workspace and delete or backup if req
    // backup workspace to file folder with suffix
    backupAndDeleteWorkspace()

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

    var promptingRetryNumber = 0

    let sema = DispatchSemaphore(value: 0)

    func doPrompting(_ errors: [String] = []) {
        generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit, currentRetry: promptingRetryNumber, errors: errors) { response in
            if response != nil, let response {
                parseAndExecuteGPTOutput(response, errors) { success, errors in
                    if success {
                        print("Parsed and executed code successfully. Opening project...")

                        executeAppleScriptCommand(.openProject(name: projectName))

                        sema.signal()
                    }
                    else {
                        print("Failed @ parsing / executing code successfully.")
                        if promptingRetryNumber >= retryLimit {
                            print("OVERALL prompting limit reached, stopping the process. Try a diff prompt you doof.")
                            //completion(nil)
                            sema.signal()
                            return
                        }

                        promptingRetryNumber += 1

                        doPrompting(errors)
                    }
                }
            } else {
                print("Failed to generate compilable code within the retry limit.")
            }
        }
    }

    doPrompting()

    sema.wait()
}

func generateCodeUntilSuccessfulCompilation(prompt: String, retryLimit: Int, currentRetry: Int, errors: [String] = [], completion: @escaping (String?) -> Void) {
    if currentRetry >= retryLimit {
        print("Retry limit reached, stopping the process.")
        completion(nil)
        return
    }
    backupAndDeleteWorkspace()
    projectName = ""
    
    let swiftnewLine = """

    """
    var prompt = prompt
    if !errors.isEmpty {
        prompt += fixItPrompt
        if !errors.isEmpty && currentRetry > 0 {
            prompt += Array(Set(errors)).joined(separator: swiftnewLine)
            prompt += swiftnewLine

            if includeSourceCodeFromPreviousRun {
                prompt += includeFilesPrompt
                prompt += swiftnewLine

                for contents in lastFileContents {
                    prompt += contents
                    prompt += swiftnewLine
                    prompt += swiftnewLine
                }
            }
        }
    }

    sendPromptToGPT(prompt: prompt, currentRetry: currentRetry, isFix: !globalErrors.isEmpty) { response, success in
        if success {
            completion(response)
        } else {
            backupAndDeleteWorkspace()
            projectName = ""


            print("Code did not compile successfully, trying again... (attempt \(currentRetry + 1)/\(retryLimit))")
            generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit, currentRetry: currentRetry + 1, errors: globalErrors, completion: completion)
        }
    }
}

// Function to send a prompt to GPT via the OpenAI API
func sendPromptToGPT(prompt: String, currentRetry: Int, isFix: Bool = false, completion: @escaping (String, Bool) -> Void) {

    let url = URL(string: apiEndpoint)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // Set the required headers
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(OPEN_AI_KEY)", forHTTPHeaderField: "Authorization")

    // Prepare the request payload
    let requestBody: [String: Any] = [
        "model": "gpt-3.5-turbo",
        "messages": [
            [
                "role": "user",
                "content": prompt,
            ]
        ]
    ]
    do {
        // Convert the payload to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        request.httpBody = jsonData

        if currentRetry == 0 {
            print("👨 = \(prompt)")
        }
        else if isFix {
            print("💚 Try fix prompt: \(currentRetry) / \(retryLimit) \\n \(prompt)")

        }
        else {
            print("👨 Retry same prompt: \(currentRetry) / \(retryLimit)")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                completion("Failed networking w/ error = \(error)", false)
                return
            }

            guard let data  else {
                completion("Failed networking w/ error = \(error)", false)
                return print("failed to laod data")
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content, true)
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion("Failed parsing JSON w/ error = \(error)",false)
            }
        }
        print("🐑🧠🧠🧠 THINKING... 🧠🧠🧠🐑")
        task.resume()
    }
    catch {
        return completion("Failed parsing w/ error = \(error)", false)
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
        projectName = name
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

    print("🤖= \(output)")

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
            if nameContents.count > gptCommandIndex {
                name = nameContents[gptCommandIndex]
            }

            executeXcodeCommand(.createProject(name: name)) { success, errors in }
        }
        else if fullCommand.hasPrefix("Open project") {
            var name =  projectName
            if nameContents.count > gptCommandIndex {
                name = nameContents[gptCommandIndex]
            }

            executeXcodeCommand(.openProject(name: name)) { success, errors in }
        }
        else if fullCommand.hasPrefix("Close project") {
            var name =  projectName
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

            executeXcodeCommand(.createFile(fileName: fileName, fileContents:foundFileContents)) { success, errors in   }


            fileIndex += 1
        }
        else {
            print("unknown command = \(fullCommand)")
        }

        nameIndex += 1
        commandIndex += 1
    }

//        if filesWritten == 0 || filesWritten != fileContents.count {
//            print("Failed to make files.. retrying...")
//            return completion(false)
//        }

    print("Building project...")
    executeXcodeCommand(.buildProject(name: projectName)) { success, errors in
        if success {
            completion(true, errors)
        }
        else {
            completion(false, errors)
        }
    }
}

func writeFile(fileContent: String, filePath: String) -> Bool {

    let modifiedFileContent = fileContent.replacingOccurrences(of: "\\n", with: "\n")
    // Create a new Swift file
    if let data = modifiedFileContent.data(using: .utf8) {
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            return true
        }
        catch {
            print("Error writing file: \(error) @ p = \(filePath)")
            return false
        }
    }
    return false
}

func createFile(projectPath: String, projectName: String, targetName: String, filePath: String, fileContent: String) -> Bool {

    let wroteSuccessfully = writeFile(fileContent: fileContent, filePath: filePath)

    if !wroteSuccessfully {
        print ("failed to write file when adding it.")
        return false
    }

    // Add the file to the project using xcodeproj gem
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    task.arguments = [
        "ruby",
        // TODO: Fix hardcoded path.
        rubyScriptPath,
        projectPath,
        filePath,
        targetName
    ]

    do {
        try task.run()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            print("Error: Failed to add file to the project.")
            return false
        } else {
            print("File successfully added to the project.")
            return true
        }
    } catch {
        print("Error: \(error.localizedDescription)")
        return false

    }
}

main()
