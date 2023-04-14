//
//  Prompt.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/12/23.
//

let appDesc = "that displays a text label that says 'Hello World! with text color that randomly changes to a random color every random number of seconds between 1-3."


var prompt = """
Develop an iOS app in \(language) for a SwiftUI-based \(appDesc). Name it \(aiNamedProject ? "a unique name" : appName). Return necessary, valid, and formatted Swift code files as a JSON array. It is essential you return your response as a JSON array matching the structure:. [{"command": "Create project","name": "UniqueName"}, {"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}, {"command": "Open project", "name": "\(aiNamedProject ? "UniqueName" : appName)"},{"command": "Close project", "name": "UniqueName"}]
Example SWIFT_FILE_CONTENTS = "import SwiftUI\\nstruct UniqueGameView: View { var body: some View { Spinner() } }\nstruct Spinner: View { var body: some View {a } }". Follow this order: Create project, Create Swift files (including App file), Open project, Close project. Minimize command usage.
1. It is essential you return your response as a JSON array.
2. It is essential you include a Swift `App` file.
3. Implement all needed code. Do not use files other than .swift files.

"""

let fixItPrompt = """

Review the following Swift source code:

"""

let errorsPrompt = """

Errors:

"""

let includeFilesPrompt = """

Please suggest improvements and corrections to fix the errors and optimize the code. Return necessary, valid, and formatted Swift code files as a JSON array. It is essential you return your response as a JSON array matching the structure:. [{"command": "Create Project","name": "SickGame007"}, {"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}, {"command": "Open project", "name": "SickGame007"},{"command": "Close project", "name": "SickGame007"}]

Source Code:

"""

