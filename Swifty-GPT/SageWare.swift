//
//  SageWare.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/19/23.
//

import Foundation

//
//  GPTMiddleware.swift
//
//
//  Created by Chris Dillard on 4/19/23.
//

import Foundation

let createProjectPrefix = "Create project"
let openProjectPrefix = "Open project"
let closeProjectPrefix = "Close project"
let createFilePrefix = "Create file"
let buildProjectPrefix = "Build project"

let googlePrefix = "Google"
let linkPrefix = "Link"

// Returns success / failure for some ops.
func parseAndExecuteGPTOutput(_ output: String, _ errors:[String] = [], completion: @escaping (Bool, [String]) -> Void) {

    if logV == .verbose { multiPrinter("🤖: \(output)") }

    let (updatedString, fileContents) = extractFieldContents(output, field: "fileContents")
    lastFileContents = Array(fileContents)

    let (_, nameContents) = extractFieldContents(updatedString, field: "name")

    let (_, commandContents) = extractFieldContents(output, field: "command")

    multiPrinter("found \(nameContents) names")

    multiPrinter("found \(commandContents) commands")

    multiPrinter("📁 found = \(fileContents.count)")

    guard !nameContents.isEmpty else {
        multiPrinter("No names found... failing..")
        return completion(false, [])
    }
    guard !commandContents.isEmpty else {
        multiPrinter("No commands found... failing..")
        return completion(false, [])
    }

    multiPrinter("📜= \(updatedString)")

    var nameIndex = 0
    var commandIndex = 0
    var fileIndex = 0

    for gptCommandIndex in 0...commandContents.count - 1 {
        let fullCommand = commandContents[gptCommandIndex]
        multiPrinter("🤖🔨: performing GPT command = \(fullCommand)")

        if fullCommand.hasPrefix(createProjectPrefix) {

            var name =  projectName
            if nameContents.count > gptCommandIndex {
                name = nameContents[gptCommandIndex]
            }
            projectName = name.isEmpty ? "MyApp" : name

            projectName = preprocessStringForFilename(projectName)


            //textToSpeech(text: "Create project " + projectName + ".")

            executeXcodeCommand(.createProject(name: projectName)) { success, errors in

                if !success {
                    completion(success, errors)
                }
            }
        }
        else if fullCommand.hasPrefix(openProjectPrefix) {
            multiPrinter("SKIPPING GPT PROJECT OPENING FOR NOW")
//            var name =  projectName
//
//            projectName = name.isEmpty ? "MyApp" : name
//            projectName = preprocessStringForFilename(projectName)
//
//            textToSpeech(text: "Open project " + projectName + ".")
//
//            if nameContents.count > gptCommandIndex {
//                name = nameContents[gptCommandIndex]
//            }
//            name = preprocessStringForFilename(name)
//
//            executeXcodeCommand(.openProject(name: name)) { success, errors in
//
//                if !success {
//                  //  completion(success, errors)
//                }
//            }
        }
        else if fullCommand.hasPrefix(buildProjectPrefix) {
            multiPrinter("SKIPPING GPT PROJECT BUILDING FOR NOW")

//            buildIt() { success, errrors in
//                if !success {
//                    completion(success, errors)
//                }
//            }
//            return
        }
        else if fullCommand.hasPrefix(closeProjectPrefix) {
            multiPrinter("SKIPPING GPT PROJECT CLOSING FOR NOW")

//            var name =  projectName
//
//            projectName = name.isEmpty ? "MyApp" : name
//            projectName = preprocessStringForFilename(projectName)
//
//            //textToSpeech(text: "Close project " + projectName + ".")
//
//            if nameContents.count > gptCommandIndex {
//                name = nameContents[gptCommandIndex]
//            }
//
//            name = preprocessStringForFilename(name)
//
//            executeXcodeCommand(.closeProject(name: name)) { success , errors in
//                multiPrinter("unknown command = \(fullCommand)")
//
//                if !success {
//                    multiPrinter("failed to close, e=\(errors) ")
//
//                }
//                completion(success, errors)
//
//            }
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

            executeXcodeCommand(.createFile(fileName: fileName, fileContents:foundFileContents)) {
                success, errors in
                if success {
                    fileIndex += 1
                }
                else {
                    return completion(false, globalErrors)
                }
            }
        }
        // Experimental. I think this should probably override responses for 1 or two messages to get the research in place.
        else if fullCommand.hasPrefix(googlePrefix) && enableGoogle {
            var query =  ""

            if nameContents.count > fileIndex {
                query = nameContents[fileIndex]
            }

            textToSpeech(text: "Googling \(query)...", overrideWpm: "250")

            googleCommand(input: query)

            // This should work if GPT keeps Google command first?
            return
        }
        // Experimental. I think this should probably override responses for 1 or two messages to get the research in place.
        else if fullCommand.hasPrefix(linkPrefix) && enableLink {
            var query =  ""

            if nameContents.count > fileIndex {
                query = nameContents[fileIndex]
            }

            textToSpeech(text: "tapping linkn...", overrideWpm: "250")

            linkCommand(input: query)

            // This should work if GPT keeps Google command first?
            return
        }
        else {
            multiPrinter("unknown command = \(fullCommand)")
        }

        nameIndex += 1
        commandIndex += 1
    }

    if fileIndex == 0 || fileIndex != fileContents.count {
        multiPrinter("Failed to make files.. retrying...")
        return completion(false, globalErrors)
    }

    buildIt() { success, errrors in
              // open it?
          completion(success, errors)

      }
}


func buildIt(completion: @escaping (Bool, [String]) -> Void) {
    multiPrinter("Building project...")
    //textToSpeech(text: "Building project \(projectName)...")

    startRandomSpinner()
    executeXcodeCommand(.buildProject(name: projectName)) { success, errors in
        stopRandomSpinner()

        if success {
            multiPrinter("Build successful.")

            func sucessWord() -> String {
                switch Int.random(in: 0...5)
                {
                case 0:
                    return  "Build successful"
                case 1:
                    return "Build success"
                case 2:
                    return "Build worked"
                case 3:
                    return "Successful build"
                case 4:
                    return "Successfully built"
                default:
                    return ""
                }
            }

            textToSpeech(text: sucessWord())

            completion(true, errors)
        }
        else {
            multiPrinter("Build failed.")

            func failWord() -> String {
                switch Int.random(in: 0...5)
                {
                case 0:
                    return "Failed build"
                case 1:
                    return "Build failed"
                case 2:
                    return "Build failed, for now..."
                case 3:
                    return "Build broke"
                case 4:
                    return "Failed to build"
                default:
                    return ""
                }
            }

            textToSpeech(text: failWord())

            completion(false, errors)
        }
    }

}
