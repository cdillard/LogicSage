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

func backupAndDeleteWorkspace() {
    print("Backing up and deleting workspace.")

    var projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)"

    let backupPath = "\(projectPath)-\(Date().timeIntervalSince1970)"
    projectPath = "\(projectPath)/"

    let projectPathURL = URL(fileURLWithPath: projectPath)
    let backupPathURL = URL(fileURLWithPath: backupPath)
    do {
        try FileManager.default.moveItem(at: projectPathURL, to: backupPathURL)
    }
    catch {
        print(error)
    }
}

// Regex / Parsing

func extractFieldContents(_ input: String, field: String = "fileContents") -> (String, [String]) {
    var fileContents: [String] = []
    let pattern = #""\#(field)":\s*?"((?:\\.|[^"\\]+)*)""#
    let regex = try! NSRegularExpression(pattern: pattern)
    let modifiedInput = regex.stringByReplacingMatches(in: input, options: [], range: NSRange(input.startIndex..., in: input), withTemplate: "\"\(field)\": \"\"")
    let matches = regex.matches(in: input, options: [], range: NSRange(input.startIndex..., in: input))
    for match in matches {
        if let fileContentRange = Range(match.range(at: 1), in: input) {
            var fileContent = String(input[fileContentRange])
            fileContent = fileContent.replacingOccurrences(of: #"\\("")"#, with: "\"")
            fileContent = fileContent.replacingOccurrences(of: #"\\n"#, with: "\n")
            fileContents.append(fileContent              .replacingOccurrences(of: "\\\"", with: "\"")
                                                        .replacingOccurrences(of: "\\\\", with: "\\")
                                                        .replacingOccurrences(of: "\\n", with: "\n")
                                                        .replacingOccurrences(of: "\\r", with: "\r")
                                                        .replacingOccurrences(of: "\\t", with: "\t"))
        }
    }
    return (modifiedInput, fileContents)
}

//func removeTextAfterLastClosingBracket(input: String) -> String {
//    if let closingBracketIndex = input.lastIndex(of: "]") {
//        let result = input[input.startIndex...closingBracketIndex]
//        return String(result)
//    }
//    return input
//}
