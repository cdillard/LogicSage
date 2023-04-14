//
//  Ideas_prompts.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/12/23.
//

// Other optional command-line arguments, like frameworks or additional features, can be added here

//    let appDesc = "a game that uses simple shapes and colors. Develop a 2D grid-based color matching puzzle where players swap shapes to create matches, clear grid cells, and score points. Use distinct colors and geometric shapes (circles, squares, triangles) for game pieces. Utilize animations for shape swapping and cascading. Develop using Apple's built in frameworks."

//        let appDesc = "that displays a matching game to the user. There should be a 2d grid of cards with concealed emojis on them, tapping a card should show the concealed emoji. If the user selects two cards with the same concealsed emoji, they get a point and those two cards are removed from the grid."

//        let appDesc = "that displays a text label that says 'Hello World! with text color that randomly changes to a random color every random number of seconds between 1-3."
//    let appDesc = "that displays the following text using a typewriter animation: You are feeling very sleepy..."
// Working PROMPTS that generate somewhat working code.
//        let appDesc = "that displays a label that says I love you so much! with heart emojis all around the screen in random places."
//         let appDesc = "containing a label that says 'Hello World!"
//     let appDesc = "containing a color picker and a label that says `Hi bud` which changes color based on the picker."
//         let appDesc = "that displays a scrollable grid with many random SF Symbols and the symbol name in each square. Tapping an symbol should go to a new screen with facts about that symbol."
//let appDesc = "containing a circle that can be moved by tapping and dragging."
//         let appDesc = "containing a circle that can be moved by tapping and dragging and stays where you move it."
//        let appDesc = "containing a list of hilarious jokes."
//    let appDesc = "that displays a beautiful gradient between green and light green across the entire screen. Show a system symbol in multicolor of the palette in the center of the screen."
//          let appDesc = "that displays a 3d scene. Show 3 spheres and a ground plane. Attach physics body to spheres so they react to gravity."
//        let appDesc = "that displays the following text using a typewriter animation: You are feeling very sleepy..."

//    let appDesc = "that implements a dungeon crawling game incorporating these mechanics: buttons to go up, down, left, or right. a map that shows monsters and obstacles to navigate around."
//     let appDesc = "that uses SceneKit to display a mountain scene in 3D using emojis as the sky, trees, and animal art assets. Do not use .scnassets folders or .scnassets files or .scn files"

// PARTIALLY WORKS. EXCITED TO see gpt-4
//    let appdesc = "that creates a 3D animation of a rotating torus knot using Swift and SceneKit. A torus knot is a type of space-filling curve that wraps around a torus (a donut-shaped object). Do not use .scnassets folders or .scnassets files or .scn files."
//    let appDesc = "that displays a 3D fractal called the 'Menger Sponge' with configurable recursion level using Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files"
//    let appDesc = "that displays the classic Hangman game. A random word should be chosen and the user should be able to guess by entering into the text field."
// let appDesc = "that implments the classic game battleships. The user should be able to play against the computer opponent."

//    let appDesc = "that implments a simple game that uses multitouch to see how many fingers are on the screen, add a circle to each touch point and track it, if there are two or more touch points, randomly choose one of the touch points as the winner and play an animation."
//        let appDesc = "that displays a spiraling swirling line across the entire screen. It should use colors from a matching color palette."

//    let appDesc = "that displays a mandelbrot set fractal. The app allows zooming into a specific point on the fractal using zoom gesture. Take special care to optimize the code so it works well on devices while zooming."

//         let appDesc = "Generate Swift code for an iOS app that displays an interactive Mandelbrot set fractal. The app should allow users to zoom in and out, and pan the fractal using touch gestures. The fractal should be rendered in real-time, with adjustable color schemes. Include code for basic touch gesture handling and the fractal generation algorithm."

//let appDesc = "that shows an wave using sin function. Animate the wave by changing the value passed to sin over time. "
//     let appDesc = "that displays an animation of three squares animating into place. One from the top of the screen, one from the left, and one from the bottom."
//     let appDesc = "that displays and animates randomly all the emoji related to plants and green across the screen in random locations. Add ."

// borky
//    let appDesc = "that displays an american flag. The american flag should be drawn using the built in shape drawing in SwiftUI."
//     let appDesc = "that displays a list of saved notes. The app should allow the user to create a new note."
//    let appDesc = "that implements classic dots and boxes game. Dots and Boxes is a classic pencil-and-paper game for two players. The game consists of a grid of dots, and the objective is to create more boxes than your opponent by connecting the dots with lines. Quick rules: 1.Players take turns drawing a horizontal or vertical line between adjacent dots.\n2.If a player completes a box (all 4 sides), they claim it and get a point.\nThe player who completes a box gets another turn. The game ends when all boxes are claimed. The player with the most boxes wins."


// Integrating Third party libraries stufff
//    let appDesc = "that integrates the New Relic for iOS SDK using Swift Package Manager. It should add an AppDelegate to the SwiftUI app and properly hook it up to the applicationDidFinishLaunching function with the required setup code for the New Relic SDK. It should display a screen with a few buttons on it. It should use the New Relic SDK to record custom events when tapping buttons."

//let appDesc = "that displays a torus knot using Swift and SceneKit. Generate the torus knot gemoetry. Do not use the built in SCNTorusKnot or SCNParametricGeometry. Do not Use SCNCustomGeometrySource. Do not use .scnassets folders or .scnassets files or .scn files."
//let appDesc = "that implements the Turing Pattern for generating the texture for and displays a 3D sphere using Swift and SceneKit.  Do not use .scnassets folders or .scnassets files or .scn files."
//let appDesc = "that implements a simple L-System for displaying objects in 3D. Use Swift and SceneKit to display the created obejcts. Do not use .scnassets folders or .scnassets files or .scn files."
//let appDesc = "that displays a scrollable grid with many random SF Symbols and the symbol name in each square. Tapping an symbol should go to a new screen with facts about that symbol."

//let appDesc = "a game that uses simple shapes and colors. Develop a 2D grid-based color matching puzzle where players swap shapes to create matches, clear grid cells, and score points. Use distinct colors and geometric shapes (circles, squares, triangles) for game pieces. Utilize animations for shape swapping and cascading. Develop using Apple's built in frameworks."

//let appDesc = "that displays a circle that can be moved by tapping and dragging and stays where you move it. Keep a timer of how long the users been moving the circle and show the acculated time in a label."

//let appDesc = "that displays a mandelbrot set fractal. The app allows zooming into a specific point on the fractal using zoom gesture. Take special care to optimize the code so it works well on devices while zooming."

//let appDesc = "that integrates the New Relic for iOS SDK using Swift Package Manager. It should add an AppDelegate to the SwiftUI app and properly hook it up to the applicationDidFinishLaunching function with the required setup code for the New Relic SDK. It should display a screen with a few buttons on it. It should use the New Relic SDK to record custom events when tapping buttons."

// let appDesc = "that displays a scrollable grid with many random emojis and the emoji name in each square. Tapping an emoji should go to a new screen with facts about that emoji."


//let appDesc = "that implements a dungeon crawling game incorporating these mechanics: buttons to go up, down, left, or right. a map that shows monsters and obstacles to navigate around."

//var prompt = """
//You are working on a \(appType) app in the \(language) programming language.
//As an AI language model, please generate \(language) code for a SwiftUI app \(appDesc) Project should be named \(aiNamedProject ? "something unique" : appName). Your response should include the necessary \(language) code files. Please ensure that the generated code is valid and properly formatted. The files should be returned as a JSON array with the following structure:
//It is essential you return your response as a JSON array matching the structure:. [{"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}]
//Example SWIFT_FILE_CONTENTS = "import SwiftUI\\nstruct ContentView: View { var body: some View { Spinner() } }\nstruct Spinner: View { var body: some View { } }"
//Available commmands are: "Close project name" , "Create project name", "Open project name", "Create file name fileContents"
//Commands are expensive so try to use as few as possible.
//Please keep in mind the following constraints when generating the response:
//1. It is essential you return your response as a JSON array.
//2. It is essential you include a Swift `App` file.
//3. Focus on generating valid, properly formatted, and properly escaped Swift code.
//4. Complete tasks in this order: Create project. Create Swift files including App file. Open project. Close project.
//
//"""

//let appDesc = "ARKit target shooting game"
//let appDesc = "app that that displays a label that says I love you so much! with heart emojis all around the screen in random places."
//    let appDesc = "app that displays a mandelbrot set fractal. The app allows zooming into a specific point on the fractal using zoom gesture. Take special care to optimize the code so it works well on devices while zooming."
