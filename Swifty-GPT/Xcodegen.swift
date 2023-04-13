//
//  Xcodegen.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/12/23.
//

import Foundation

// TODO: Fix hardcoded paths to Info.plist.
func createNewProject(projectName: String, projectDirectory: String) {
    let projectSpec = """
    name: \(projectName)
    targets:
      \(projectName):
        type: application
        platform: iOS
        deploymentTarget: "16.0"
        sources: [Sources]
        info:
          path: \(infoPlistPath)
          properties:
            CFBundleVersion: "1.0"
            UILaunchScreen: []
        settings:
          base:
            PRODUCT_BUNDLE_IDENTIFIER: com.example.\(projectName)
            INFOPLIST_FILE: \(infoPlistPath)
    """

    // TODO: Fix harcoded path to xcodegen.
    let projectSpecPath = "\(projectDirectory)\(projectName)/project.yml"
    let createProjectScript = """
    mkdir -p \(projectDirectory)/\(projectName)/Sources
    echo '\(projectSpec)' > \(projectSpecPath)
    \(xcodegenPath) generate --spec \(projectSpecPath) --project \(projectDirectory)
    """

    let task = Process()
    task.launchPath = "/bin/zsh"
    task.arguments = ["-c", createProjectScript]
    task.launch()
    task.waitUntilExit()

    let status = task.terminationStatus
    if status == 0 {
        print("Project created successfully")
    } else {
        print("Error creating project")
    }
}
