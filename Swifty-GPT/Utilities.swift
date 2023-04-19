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

// Regex / Parsing

