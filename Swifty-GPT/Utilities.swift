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

func removeInvalidEscapeSequences(in jsonString: String) -> String {
    let pattern = #"\\[^"\\/bfnrtu]"#
    let regex: NSRegularExpression

    var jsonString = jsonString

    do {
        regex = try NSRegularExpression(pattern: pattern, options: [])
    } catch {
        print("Error: Invalid regular expression.")
        return jsonString
    }

    let nsRange = NSRange(jsonString.startIndex..<jsonString.endIndex, in: jsonString)
    let matches = regex.matches(in: jsonString, options: [], range: nsRange)

    if matches.isEmpty {
        print("No invalid escape sequences found.")
    } else {
        for match in matches {
            let invalidEscapeSequence = (jsonString as NSString).substring(with: match.range)
            print("Found invalid escape sequence: \(invalidEscapeSequence) at range: \(match.range)")
            if let delRange = jsonString.rangeFromNSRange(nsRange: match.range) {
                jsonString.replaceSubrange(delRange, with: "\"fileContents\":\"\"")
            }
            else {
                print("Failed to delete control character.")

            }
        }
    }
    return jsonString
}

func replaceFileContents(_ input: String) -> String {
    let pattern = #""fileContents":\s*?("""[\s\S]*?"""|"[^"]*")"#
    let regex = try! NSRegularExpression(pattern: pattern)
    let range = NSRange(input.startIndex..., in: input)
    var result = input
    regex.enumerateMatches(in: input, options: [], range: range) { (match, _, _) in
        if let matchRange = match?.range, let range = Range(matchRange, in: input) {
            let fileContent = String(input[range])
            let modifiedFileContent = "\"fileContents\": \"\","
            if let nextCommandRange = input.range(of: #" {"command":"#, range: range.upperBound..<input.endIndex) {
                let modifiedRange = range.lowerBound..<nextCommandRange.lowerBound
                let modifiedString = input.replacingCharacters(in: modifiedRange, with: modifiedFileContent)
                result = result.replacingOccurrences(of: fileContent, with: modifiedString)
            }
        }
    }
    return result
}

func extractFileContents(_ input: String) -> (String, [String]) {
    var fileContents: [String] = []
    let pattern = #""fileContents":\s*?"((?:\\.|[^"\\]+)*)""#
    let regex = try! NSRegularExpression(pattern: pattern)
    let modifiedInput = regex.stringByReplacingMatches(in: input, options: [], range: NSRange(input.startIndex..., in: input), withTemplate: "\"fileContents\": \"\"")
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

extension String {
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        return Range(nsRange, in: self)
    }
}

func removeControlCharacters(from input: String) -> String {
    let allowedCharacters = CharacterSet(charactersIn: " \t\n\r!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\"")
    let filtered = input.unicodeScalars.filter { allowedCharacters.contains($0) }
    return String(String.UnicodeScalarView(filtered))
}

func removeTextAfterLastClosingBracket(input: String) -> String {
    if let closingBracketIndex = input.lastIndex(of: "]") {
        let result = input[input.startIndex...closingBracketIndex]
        return String(result)
    }
    return input
}
