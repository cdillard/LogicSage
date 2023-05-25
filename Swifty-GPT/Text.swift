//
//  TextStuffs.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

func commandsText() -> String {
    let text = """
     \( fullProjText() )
    """
    return text
}
//    8. 🧠 GPT Voice (gv) `gv I'm Bubbles, I like Kitties. --voice com.apple.speech.synthesis.voice.Bubbles`
//   12. 🧠 Run GPT from file (gf)
// 13. 💡 Run Idea from file (if)
//    5 📂 Voice settings (See more voices in Config.swift- you coding today) CEREPROC VOICES ROCK!

func fullProjText() -> String {
"""
 🔸 Project Management:
   r ✨ Run loaded prompt
   s 🚀 Show loaded prompt
   o 📂 Open project
   b 🏗️ Build Project
 🔸 GPT Interaction:
   i 💡 Idea prompt
   g 🧠 Talk to GPT
 🔸 Speak:
  \(config.voiceInputEnabled == false ? "" :" -  🗣️: tap 0 to start listening, tap 0 to capture." )
  say  💬 `say anything`
 🔸 Miscellaneous:
  rand  💥 Build random app
  p     🧠 List built-in prompts
  c     📲 List Commands
  st    🛑 Stop voices/commands
  sn    🎵 Sing a built-in song
  t     🎤 Play iOS dev trivia
  rs    🔁 Reset prompt state
  del   🗑️ Backup & delete workspace
  e     🚪 Exit the program
  debate👥 Debate (`debate`, or `debate your topic`) [  MORE: ethics, movies, and encourage ]
"""
}

func generatedOpenLine(overrideV: Bool = false) -> String {
    let openLine = """
    \(randomAscii())
    \((logV == .verbose && overrideV) ? commandsText() : "")
    🔍:
    """
    return openLine
}
func randomAscii() -> String {
    let index = Int.random(in: 0..<4)

    switch index {
    case 0: return logoAscii2
    case 1: return logoAscii5
    case 2: return logoAscii2
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
Project creation failed. Check the Xcode project for simple mistakes [3] 🤔.
❓ What would you like to do:
🔍 Please choose an option [1-19, b, x, i, g, gv, (c) - list commands, ...]:
"""
}
