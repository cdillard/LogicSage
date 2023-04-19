//
//  TextStuffs.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

var commandsText = """
🔹 idea: "Your app idea"  💡 New appDesc prompt
🔹 gpt: "Hi GPT. Tell me something interesting about technology."   🧠 Talk to GPT
🔹 xcode: 🛠️ Run Xcode operations
🔹 random  Build app from random premade prompt
🔹 prompts  List built in prompts

🔹 gptVoice: $PROMPT --voice "Good news"   🧠 reply with passed voice

🔹 stop  🛑 Stop any voices or Commands
🔹 sing  🎵 Sing a built in song

🔹 reset  🔁🔄♻️ Reset prompt state


🔹 exit  🚪 Close the program

"""

func generatedOpenLine() -> String {
    """
    \(openLinePrintCount == 0 ? "\(randomAscii())\n 🚀🔥 Welcome to Swifty GPT 🧠💥" : "")

    \(sharedCommands)
    \(commandsText)

    🔍 Please choose an option [0-3, gpt:, xcode:, idea:, exit]:

    """
}

func randomAscii() -> String {
    let index = Int.random(in: 0..<4)

    switch index {
    case 0: return logoAscii2
    case 1: return logoAscii
    case 2: return logoAscii3
    case 3: return logoAscii5

    default: return logoAscii2
    }
}

var openLinePrintCount = 0

var openingLine = generatedOpenLine()

func updateOpeningLine() {

    openingLine = generatedOpenLine()
}


let afterBuildFailedLine = """
Project creation failed. Check the Xcode project for simple mistakes [4] 🤔. Use GPT to fix it [5] 🤖.
\(numericalCommands)
\(commandsText)

❓ What would you like to do:
🔍 Please choose an option [1-6, gpt:, xcode:, idea:, exit]:

"""

let afterSuccessLine = """
Project creation success. Project should have auto openned.
\(numericalCommands)
\(commandsText)

🔍 Please choose an option [0-6, gpt:, xcode:, idea:, exit]:

"""
// 🎮🎨📲
let sharedCommands = """
🔹 0. 🗣️ Use voice command: Tap 0 to start, Tap 0 to end
🔹 1. ✨ Run loaded prompt
🔹 2. 🚀 Show loaded prompt
🔹 3. 📂 Open project
🔹 X. 📂 Voice settings

"""

let numericalCommands = """
\(sharedCommands)
🔹 4. 🚪📂 Close project
🔹 5. 🖥️🔧 Fix errors w/ GPT
🔹 6. 🆕   Continue implementation
"""

