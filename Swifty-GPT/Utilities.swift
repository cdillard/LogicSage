//
//  Utilities.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/10/23.
//

import Foundation

// Workspace Utilities

func getWorkspaceFolder() -> String {
    guard let swiftyGPTDocumentsPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path(percentEncoded: false) else {
        print("ERROR GETTING WORKSPACE")

        return ""
    }
    return swiftyGPTDocumentsPath
}

func backupAndDeleteWorkspace() throws {
    let fileManager = FileManager.default

    var projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)"

    let backupPath = "\(projectPath)-\(Date().timeIntervalSince1970)"
    projectPath = "\(projectPath)/"

    let projectPathURL = URL(fileURLWithPath: projectPath)
    let backupPathURL = URL(fileURLWithPath: backupPath)

    var isDirectory: ObjCBool = false
    if fileManager.fileExists(atPath: projectPathURL.path, isDirectory: &isDirectory) && isDirectory.boolValue {
        // Check if destination directory exists
        if !fileManager.fileExists(atPath: backupPathURL.path, isDirectory: &isDirectory) {
            do {
                try fileManager.moveItem(at: projectPathURL, to: backupPathURL)
            } catch {
                print("Failed to move directory: \(error.localizedDescription)")
                throw error
            }
        } else {
            print("Destination directory already exists: \(backupPathURL.path)")
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileWriteFileExistsError, userInfo: nil)
        }
    }
}

// Regex / Parsing

func extractFieldContents(_ input: String, field: String = "fileContents") -> (String, [String]) {
    var fileContents: [String] = []
    let pattern = #""\#(field)":\s*?"((?:\\.|[^"\\]+)*)""#
    let regex = try! NSRegularExpression(pattern: pattern)
    let matches = regex.matches(in: input, options: [], range: NSRange(input.startIndex..., in: input))

    for match in matches {
        if let fileContentRange = Range(match.range(at: 1), in: input) {
            var fileContent = String(input[fileContentRange])
            fileContent = fileContent.replacingOccurrences(of: #"\\("")"#, with: "\"")
            fileContent = fileContent.replacingOccurrences(of: #"\\n"#, with: "\n")
            fileContents.append(fileContent.replacingOccurrences(of: "\\\"", with: "\"")
                                           .replacingOccurrences(of: "\\\\", with: "\\")
                                           .replacingOccurrences(of: "\\n", with: "\n")
                                           .replacingOccurrences(of: "\\r", with: "\r")
                                           .replacingOccurrences(of: "\\t", with: "\t"))
        }
    }

    // Remove the matched strings from the input
    let modifiedInput = regex.stringByReplacingMatches(in: input, options: [], range: NSRange(input.startIndex..., in: input), withTemplate: "\"\(field)\": \"\"")

    return (modifiedInput, fileContents)
}

//func extractFieldContents(_ input: String, field: String = "fileContents") -> (String, [String]) {
//    var fileContents: [String] = []
//    let pattern = #""\#(field)":\s*?"((?:\\.|[^"\\]+)*)""#
//    let regex = try! NSRegularExpression(pattern: pattern)
//    let modifiedInput = regex.stringByReplacingMatches(in: input, options: [], range: NSRange(input.startIndex..., in: input), withTemplate: "\"\(field)\": \"\"")
//    let matches = regex.matches(in: input, options: [], range: NSRange(input.startIndex..., in: input))
//    for match in matches {
//        if let fileContentRange = Range(match.range(at: 1), in: input) {
//            var fileContent = String(input[fileContentRange])
//            fileContent = fileContent.replacingOccurrences(of: #"\\("")"#, with: "\"")
//            fileContent = fileContent.replacingOccurrences(of: #"\\n"#, with: "\n")
//            fileContents.append(fileContent              .replacingOccurrences(of: "\\\"", with: "\"")
//                                                        .replacingOccurrences(of: "\\\\", with: "\\")
//                                                        .replacingOccurrences(of: "\\n", with: "\n")
//                                                        .replacingOccurrences(of: "\\r", with: "\r")
//                                                        .replacingOccurrences(of: "\\t", with: "\t"))
//        }
//    }
//    return (modifiedInput, fileContents)
//}
