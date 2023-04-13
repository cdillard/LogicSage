//
//  Prompt.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/12/23.
//

//let appDesc = "that displays a torus knot using Swift and SceneKit. Generate the torus knot gemoetry. Do not use the built inSCNTorusKnot or SCNParametricGeometry. Do not Use SCNCustomGeometrySource. Do not use .scnassets folders or .scnassets files or .scn files."
let appDesc = "that displays the 3D fractal 'Menger Sponge' with configurable recursion level, using Swift and SceneKit. The user should be able to zoom and rotate the camera. Do not use .scnassets folders or .scnassets files or .scn files"

//let appDesc = "that displays a scrollable grid with many random SF Symbols and the symbol name in each square. Tapping an symbol should go to a new screen with facts about that symbol."


var prompt = """
You are working on a \(appType) app in the \(language) programming language.
As an AI language model, please generate \(language) code for a SwiftUI app \(appDesc). Project should be named \(aiNamedProject ? "something unique" : appName). Your response should include the necessary \(language) code files. Please ensure that the generated code is valid and properly formatted. The files should be returned as a JSON array with the following structure:
It is essential you return your response as a JSON array matching the structure:. [{"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}]
Example SWIFT_FILE_CONTENTS = "import SwiftUI\\nstruct ContentView: View { var body: some View { Spinner() } }\nstruct Spinner: View { var body: some View { } }"
Available commmands are: "Close project name" , "Create project name", "Open project name", "Create file name fileContents"
Commands are expensive so try to use as few as possible.
Please keep in mind the following constraints when generating the response:
1. It is essential you return your response as a JSON array.
2. It is essential you include a Swift `App` file.
3. Focus on generating valid, properly formatted, and properly escaped Swift code.
4. Complete tasks in this order: Create project. Create Swift files including App file. Open project. Close project.

"""

let fixItPrompt = """

Genereated code encountered compile errors last time, See below JSON array of error strings and avoid these compile errors in this generation:

"""

let includeFilesPrompt = """

I've included the fileContents from  the previous generation below:

"""
