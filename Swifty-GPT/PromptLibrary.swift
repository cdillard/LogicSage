//
//  PromptLibrary.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/17/23.
//
//
//  PromptLibrary.swift
//
//
//  Created by Chris Dillard on 4/17/23.
//

import Foundation
class PromptLibrary {

    static var promptLib: [String] = [
    "app that displays a breathtaking 3D scene with towering mountains, lush forests, and a majestic waterfall cascading into a crystal-clear lake. The scene should be bathed in the warm glow of a setting sun, with the sky awash in pink and orange hues.  max 10,000 polygons and texture resolution of 1024x1024. Use Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files",
    "Add in a variety of animals, such as grazing deer, soaring eagles, and playful otters, to bring the scene to life. Enhance the aesthetics of the scene by adding in intricate details, such as the textures of the trees, the ripples on the water, and the glimmering reflections of the sun on the natural surroundings.",
    "app that displays a simple 3D Voroni Diagrom. Use Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files",
    "that implements an L-System for displaying 3d text objects in 3D. Use Swift and SceneKit and the SCNText object to display the created obejcts. Do not use .scnassets folders or .scnassets files or .scn files.",
    "that displays a text label that says 'Hello World! with text color that randomly changes to a random color every random number of seconds between 1-3",
    "a game that uses simple shapes and colors. Develop a 2D grid-based color matching puzzle where players swap shapes to create matches, clear grid cells, and score points. Use distinct colors and geometric shapes (circles, squares, triangles) for game pieces. Utilize animations for shape swapping and cascading. Develop using Apple's built in frameworks.",
    "that displays a matching game to the user. There should be a 2d grid of cards with concealed emojis on them, tapping a card should show the concealed emoji. If the user selects two cards with the same concealsed emoji, they get a point and those two cards are removed from the grid.",
    "that displays a text label that says 'Hello World! with text color that randomly changes to a random color every random number of seconds between 1-3.",
    "that displays the following text using a typewriter animation: You are feeling very sleepy...",
    "that displays a label that says I love you so much! with heart emojis all around the screen in random places.",
    "containing a label that says 'Hello World!",
    "containing a color picker and a label that says `Hi bud` which changes color based on the picker.",
    "that displays a scrollable grid with many random SF Symbols and the symbol name in each square. Tapping an symbol should go to a new screen with facts about that symbol.",
    "containing a circle that can be moved by tapping and dragging.",
    "containing a circle that can be moved by tapping and dragging and stays where you move it.",
    "containing a list of hilarious jokes.",
    "that displays a beautiful gradient between green and light green across the entire screen. Show a system symbol in multicolor of the palette in the center of the screen.",
    "that displays a 3d scene. Show 3 spheres and a ground plane. Attach physics body to spheres so they react to gravity.",
    "that displays the following text using a typewriter animation: You are feeling very sleepy...",
    "that implements a dungeon crawling game incorporating these mechanics: buttons to go up, down, left, or right. a map that shows monsters and obstacles to navigate around.",
    "that uses SceneKit to display a mountain scene in 3D using emojis as the sky, trees, and animal art assets. Do not use .scnassets folders or .scnassets files or .scn files",
    "that creates a 3D animation of a rotating torus knot using Swift and SceneKit. A torus knot is a type of space-filling curve that wraps around a torus (a donut-shaped object). Do not use .scnassets folders or .scnassets files or .scn files.",
    "that displays a 3D fractal called the 'Menger Sponge' with configurable recursion level using Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files",
    "that displays the classic Hangman game. A random word should be chosen and the user should be able to guess by entering into the text field.",
    "that implments the classic game battleships. The user should be able to play against the computer opponent.",
    "that implments a simple game that uses multitouch to see how many fingers are on the screen, add a circle to each touch point and track it, if there are two or more touch points, randomly choose one of the touch points as the winner and play an animation.",
    "that displays a spiraling swirling line across the entirescreen. It should use colors from a matching color palette.",
    "that displays a mandelbrot set fractal. The app allows zooming into a specific point on the fractal using zoom gesture. Take special care to optimize the code so it works well on devices while zooming.",
    "for an iOS app that displays an interactive Mandelbrot set fractal. The app should allow users to zoom in and out, and pan the fractal using touch gestures. The fractal should be rendered in real-time, with adjustable color schemes. Include code for basic touch gesture handling and the fractal generation algorithm.",
    "that shows a wave using sin function. Animate the wave by changing the value passed to sin over time.",
    "that displays an animation of three squares animating into place. One from the top of the screen, one from the left, and one from the bottom.",
    "that displays and animates randomly all the emoji related to plants and green across the screen in random locations.",
    "that displays an american flag. The american flag should be drawn using the built in shape drawing in SwiftUI.",
    "that displays a list of saved notes. The app should allow the user to create a new note.",
    "that implements classic dots and boxes game. Dots and Boxes is a classic pencil-and-paper game for two players. The game consists of a grid of dots, and the objective is to create more boxes than your opponent by connecting the dots with lines. Quick rules: 1.Players take turns drawing a horizontal or vertical line between adjacent dots. 2.If a player completes a box (all 4 sides), they claim it and get a point. The player who completes a box gets another turn. The game ends when all boxes are claimed. The player with the most boxes wins.",
    "that integrates the New Relic for iOS SDK using Swift Package Manager. It should add an AppDelegate to the SwiftUI app and properly hook it up to the applicationDidFinishLaunching function with the required setup code for the New Relic SDK. It should display a screen with a few buttons on it. It should use the New Relic SDK to record custom events when tapping buttons.",
    "that displays a torus knot using Swift and SceneKit. Generate the torus knot gemoetry. Do not use the built in SCNTorusKnot or SCNParametricGeometry. Do not Use SCNCustomGeometrySource. Do not use .scnassets folders or .scnassets files or .scn files.",
    "that implements the Turing Pattern for generating the texture for and displays a 3D sphere using Swift and SceneKit. Do not use .scnassets folders or .scnassets files or .scn files.",
    "that implements a simple L-System for displaying objects in 3D. Use Swift and SceneKit to display the created objects. Do not use .scnassets folders or .scnassets files or .scn files.",
    "that displays a scrollable grid with many random SF Symbols and the symbol name in each square. Tapping an symbol should go to a new screen with facts about that symbol.",
    "a game that uses simple shapes and colors. Develop a 2D grid-based color matching puzzle where players swap shapes to create matches, clear grid cells, and score points. Use distinct colors and geometric shapes (circles, squares, triangles) for game pieces. Utilize animations for shape swapping and cascading. Develop using Apple's built in frameworks.",
    "that displays a circle that can be moved by tapping and dragging and stays where you move it. Keep a timer of how long the users been moving the circle and show the acculated time in a label.",]
}
