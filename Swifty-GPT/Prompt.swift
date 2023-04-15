//
//  Prompt.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/12/23.
//


//var appDesc = "app that displays 200 spheres with physics bodies in a circular area and a ground plane"

var appDesc = "app that displays 200 squares with physics bodies in a circular area and a ground plane"


//var appDesc = "app that displays a breathtaking 3D scene with towering mountains, lush forests, and a majestic waterfall cascading into a crystal-clear lake. The scene should be bathed in the warm glow of a setting sun, with the sky awash in pink and orange hues.  max 10,000 polygons and texture resolution of 1024x1024. Use Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files"

// Add in a variety of animals, such as grazing deer, soaring eagles, and playful otters, to bring the scene to life. Enhance the aesthetics of the scene by adding in intricate details, such as the textures of the trees, the ripples on the water, and the glimmering reflections of the sun on the natural surroundings.

//let appDesc = "app that displays a simple 3D Voroni Diagrom. Use Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files"

//let appDesc = "that implements an L-System for displaying 3d text objects in 3D. Use Swift and SceneKit and the SCNText object to display the created obejcts. Do not use .scnassets folders or .scnassets files or .scn files."
//let appDesc = "that displays a text label that says 'Hello World! with text color that randomly changes to a random color every random number of seconds between 1-3"

//let appDesc = "app that displays a spiraling swirling line across the entire screen. It should use colors from a matching color palette."

//let appDesc = "app that displays a mandelbrot set fractal. The app allows zooming into a specific point on the fractal using zoom gesture. Take special care to optimize the code so it works well on devices while zooming."

//var appDesc = "app that displays a spiraling swirling line across the entire screen. Make me dizzy!!! It should use colors from a matching color palette"

//let appDesc = "app that displays a mandelbrot set fractal. The app allows zooming into a specific point on the fractal using zoom gesture. Take special care to optimize the code so it works well on devices while zooming."

func promptText() -> String {
    """
    Develop an iOS app in \(language) for a SwiftUI-based \(appDesc). Name it \(aiNamedProject ? "a unique name" : appName). Return necessary, valid, and formatted Swift code files as a JSON array. It is essential you return your response as a JSON array matching the structure:. [{"command": "Create project","name": "UniqueName"}, {"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}, {"command": "Open project", "name": "\(aiNamedProject ? "UniqueName" : appName)"},{"command": "Close project", "name": "UniqueName"}]
    Example SWIFT_FILE_CONTENTS = "import SwiftUI\\nstruct UniqueGameView: View { var body: some View { Spinner() } }\nstruct Spinner: View { var body: some View {a } }". Follow this order: Create project, Create Swift files (including App file), Open project, Close project. Minimize command usage.
    1. It is essential you return your response as a JSON array.
    2. It is essential you include a Swift `App` file.
    3. Implement all needed code. Do not use files other than .swift files. Use Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files.

    """
}

var prompt = promptText()

let fixItPrompt = """

Review the following Swift source code:

"""

let errorsPrompt = """

Review Errors: Encountered

"""

let includeFilesPrompt = """

Please suggest improvements and corrections to fix the errors and optimize the code. Return necessary, valid, and formatted Swift code files as a JSON array. It is essential you return your response as a JSON array matching the structure:. [{"command": "Create Project","name": "\(projectName)"}, {"command": "Create file","name": "Filename.swift","fileContents": "import SwiftUI\\nstruct UniqueGameView: View { var body: some View { Spinner() } }\nstruct Spinner: View { var body: some View {a } }"}, {"command": "Open project", "name": "\(projectName)"},{"command": "Close project", "name": "\(projectName)"}]

Available commands: Create files, Open project, Close project. Minimize command usage.

Source Code:

"""

func refreshPrompt(appDesc: String) {
    updatePrompt(appDesc2: appDesc)
    updateOpeningLine()
}

func updatePrompt(appDesc2: String) {
    appDesc = appDesc2
    prompt = promptText()
}
