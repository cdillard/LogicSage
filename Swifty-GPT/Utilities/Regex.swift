//
//  Regex.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/19/23.
//

import Foundation

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
