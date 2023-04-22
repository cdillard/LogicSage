//
//  TextStuffs.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation


// 4. 🚪📂 Close project

func commandsText() -> String {
"""
🔸 Project Management:
  1. ✨ Run loaded prompt (r)
  2. 🚀 Show loaded prompt (s)
  3. 📂 Open project (o)
  B. 🏗️ Build Project (b)
  X. 📂 Voice settings (x)
🔸 GPT Interaction:
  idea: "Your app idea"  💡 (i)
  gpt: "Hi GPT. Tell me a you're Mom joke!"  🧠 Talk to GPT (g)
  gptVoice: $PROMPT --voice "Good news"  🧠 (gv)
🔸 Miscellaneous:
  random 💥 Build app from random premade prompt (rand)
  prompts 🧠 List built-in prompts (p)
  commands 📲 List Commands (c)
  gptFile Run "InputText" as gpt: prompt (gf)
  ideaFile Run "IdeaText" as idea: prompt (if)
  stop 🛑 Stop any voices or Commands (st)
  sing 🎵 Sing a built-in song (sn)
  trivia 🎤📺🎉 Play an iOS development trivia game (t)
  reset 🔁🔄♻️ Reset prompt state (rs)
  delete 🗑️ Backup and delete workspace (del)
  exit 🚪 Close the program (e)
"""
}

func generatedOpenLine(overrideV: Bool = false) -> String {
    """
    \(openLinePrintCount == 0 ? "\(randomAscii())\n 🚀🔥 Welcome to SwiftSage 🧠💥" : "")
    \((logV == .verbose || overrideV) ? sharedCommands() : "")
    \((logV == .verbose || overrideV) ? commandsText() : "")
    🔍 Please choose an option [1-3, B, X, i, g, gv, ...]:
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

func afterBuildFailedLine() -> String {
"""
Project creation failed. Check the Xcode project for simple mistakes [3] 🤔. Use GPT to fix erros one at a time [5] 🤖.
\(logV == .verbose ? numericalCommands() : "")
\(logV == .verbose ? commandsText() : "")
❓ What would you like to do:
🔍 Please choose an option [1-3, B, X, i, g, gv, ...]:
"""
}

func afterSuccessLine() -> String {
"""
Project creation success. Project should have auto openned.
\(logV == .verbose ? numericalCommands() : "")
\(logV == .verbose ? commandsText() : "")
🔍 Please choose an option [0-6, gpt:, xcode:, idea:, exit]:
"""
}
// 🎮🎨📲
func sharedCommands() -> String {
"""
🔹 0. 🗣️ Use voice command: "0" to start/end
🔹 1. ✨ Run loaded prompt, 2. 🚀 Show loaded prompt, 3. 📂 Open project,  B. 🏗️ Build Project, X. 📂 Voice settings
"""
}

func numericalCommands() -> String {
"""
\(logV == .verbose ? sharedCommands() : "")
🔹 4. 🚪📂 Close project,  5. 🖥️🔧 Fix errors w/ GPT, 6. 🆕   Continue implementation
"""
}

