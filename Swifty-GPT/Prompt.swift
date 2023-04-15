//
//  Prompt.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/12/23.
//


//let appDesc = "app that displays 200 spheres with physics bodies  in a random square area , and a ground plane. Use Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files"


//let appDesc = "app that displays a simple 3D Voroni Diagrom. Use Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files"

//let appDesc = "that implements an L-System for displaying 3d text objects in 3D. Use Swift and SceneKit and the SCNText object to display the created obejcts. Do not use .scnassets folders or .scnassets files or .scn files."
//let appDesc = "that displays a text label that says 'Hello World! with text color that randomly changes to a random color every random number of seconds between 1-3"

//let appDesc = "app that displays a spiraling swirling line across the entire screen. It should use colors from a matching color palette."

//let appDesc = "app that displays a mandelbrot set fractal. The app allows zooming into a specific point on the fractal using zoom gesture. Take special care to optimize the code so it works well on devices while zooming."

var appDesc = "app that displays a spiraling swirling line across the entire screen. Make me dizzy!!! It should use colors from a matching color palette"

//let appDesc = "app that displays a mandelbrot set fractal. The app allows zooming into a specific point on the fractal using zoom gesture. Take special care to optimize the code so it works well on devices while zooming."


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

Please suggest improvements and corrections to fix the errors and optimize the code. Return necessary, valid, and formatted Swift code files as a JSON array. It is essential you return your response as a JSON array matching the structure:. [{"command": "Create Project","name": "\(projectName)"}, {"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}, {"command": "Open project", "name": "\(projectName)"},{"command": "Close project", "name": "\(projectName)"}]

Source Code:

"""



func refreshPrompt() {
    prompt = """
    Develop an iOS app in \(language) for a SwiftUI-based \(appDesc). Name it \(aiNamedProject ? "a unique name" : appName). Return necessary, valid, and formatted Swift code files as a JSON array. It is essential you return your response as a JSON array matching the structure:. [{"command": "Create project","name": "UniqueName"}, {"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}, {"command": "Open project", "name": "\(aiNamedProject ? "UniqueName" : appName)"},{"command": "Close project", "name": "UniqueName"}]
    Example SWIFT_FILE_CONTENTS = "import SwiftUI\\nstruct UniqueGameView: View { var body: some View { Spinner() } }\nstruct Spinner: View { var body: some View {a } }". Follow this order: Create project, Create Swift files (including App file), Open project, Close project. Minimize command usage.
    1. It is essential you return your response as a JSON array.
    2. It is essential you include a Swift `App` file.
    3. Implement all needed code. Do not use files other than .swift files.
    """
    updateOpeningLine()
}
