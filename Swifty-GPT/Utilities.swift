//
//  Utilities.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/10/23.
//

import Foundation

func getWorkspaceFolder() -> String {
    guard let swiftyGPTDocumentsPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path(percentEncoded: false) else {
        print("ERROR GETTING WORKSPACE")

        return ""
    }
    return swiftyGPTDocumentsPath
}

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}


func findInvalidEscapeSequences(in jsonString: String) {
    let pattern = #"\\[^"\\/bfnrtu]"#
    let regex: NSRegularExpression

    do {
        regex = try NSRegularExpression(pattern: pattern, options: [])
    } catch {
        print("Error: Invalid regular expression.")
        return
    }

    let nsRange = NSRange(jsonString.startIndex..<jsonString.endIndex, in: jsonString)
    let matches = regex.matches(in: jsonString, options: [], range: nsRange)

    if matches.isEmpty {
        print("No invalid escape sequences found.")
    } else {
        for match in matches {
            let invalidEscapeSequence = (jsonString as NSString).substring(with: match.range)
            print("Found invalid escape sequence: \(invalidEscapeSequence) at range: \(match.range)")

            // "\\." and "\\\n" are culprits "\\\" and "\\" and ""
            // How can we get this Swift file to reliably escape/unescape all possible code.
        }
    }
}

func escapeFileContents(jsonString: String) -> String? {
    let leadingMultiLineLiteralPattern = #"""(?=\s*\n)"#
    let trailingMultiLineLiteralPattern = #""""\s*(,?)\s*\n?\s*([}\]])"#

    let escapedJsonString = jsonString
        .replacingOccurrences(of: leadingMultiLineLiteralPattern, with: "", options: .regularExpression)
        .replacingOccurrences(of: trailingMultiLineLiteralPattern, with: "\"$1\n$2", options: .regularExpression)

    return escapedJsonString
            .replacingOccurrences(of: "\\\\.\\.", with: "\\\\\\.")
            .replacingOccurrences(of: "\\self", with: "\\\\\\self")
            .replacingOccurrences(of: "\\ .self", with: "\\\\ .self")
            .replacingOccurrences(of: "\"\"\"", with: "\\\"")
            .replacingOccurrences(of: "\\\\ .", with: specialCode)
            .replacingOccurrences(of: "\\\\.", with: specialCode)
            .replacingOccurrences(of: "\\ .", with: specialCode)
            .replacingOccurrences(of: "\\.", with: specialCode)
            .replacingOccurrences(of: "\\\\_", with: "\\_")
            .replacingOccurrences(of: "\\(", with: specialCode2)
    }
