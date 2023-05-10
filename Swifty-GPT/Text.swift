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

func fullProjText() -> String {
"""
 🔸 Project Management:
   1. ✨ Run loaded prompt (r)
   2. 🚀 Show loaded prompt (s)
   3. 📂 Open project (o)
   4. 🏗️ Build Project (b)
   5. 📂 Voice settings (See more voices in Config.swift- you coding today) CEREPROC VOICES ROCK!
 🔸 GPT Interaction:
   6. 💡 Idea prompt (i)
   7. 🧠 Talk to GPT (g)
   8. 🧠 GPT Voice (gv) `gv I'm Bubbles, I like Kitties. --voice com.apple.speech.synthesis.voice.Bubbles`
 🔸 Speak:
  \(config.voiceInputEnabled == false ? "" :" -  🗣️: tap 0 to start listening, tap 0 to capture." )
   -  💬 `say anything`
 🔸 Miscellaneous:
   9. 💥 Build random app (rand)
  10. 🧠 List built-in prompts (p)
  11. 📲 List Commands (c)
  12. 🧠 Run GPT from file (gf)
  13. 💡 Run Idea from file (if)
  14. 🛑 Stop voices/commands (st)
  15. 🎵 Sing a built-in song (sn)
  16. 🎤 Play iOS dev trivia (t)
  17. 🔁 Reset prompt state (rs)
  18. 🗑️ Backup & delete workspace (del)
  19. 🚪 Exit the program (e)
  20. 👥 Debate (`debate`, or `debate your topic`) [  MORE: ethics, movies, and encourage ]
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
