//
//  Files.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

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
