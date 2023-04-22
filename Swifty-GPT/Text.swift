//
//  TextStuffs.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

func commandsText() -> String {
"""
 🔸 Project Management:
   1. ✨ Run loaded prompt (r)
   2. 🚀 Show loaded prompt (s)
   3. 📂 Open project (o)
   4. 🏗️ Build Project (b)
   5. 📂 Voice settings (x)

 🔸 GPT Interaction:
   6. 💡 Idea prompt (i)
   7. 🧠 Talk to GPT (g)
   8. 🧠 GPT Voice (gv) `gv Bad luck and extreme misfortune will infest your pathetic soul for all eternity. --voice com.apple.eloquence.en-US.Rocko`

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
"""
}

func generatedOpenLine(overrideV: Bool = false) -> String {
    """
    \(openLinePrintCount == 0 ? "\(randomAscii())\n 🚀🔥 Welcome to SwiftSage 🧠💥" : "")
    \((logV == .verbose || overrideV) ? commandsText() : "")
    🔍 Please choose an option [1-19, B, X, i, g, gv, ...]:
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
❓ What would you like to do:
🔍 Please choose an option [1-3, B, X, i, g, gv, ...]:
"""
}

//func afterSuccessLine() -> String {
//"""
//Project creation success. Project should have auto openned.
//\(logV == .verbose ? numericalCommands() : "")
//\(logV == .verbose ? commandsText() : "")
//🔍 Please choose an option [0-6, gpt:, xcode:, idea:, exit]:
//"""
//}
//// 🎮🎨📲
//func sharedCommands() -> String {
//"""
//🔹 0. 🗣️ Use voice command: "0" to start/end
//🔹 1. ✨ Run loaded prompt, 2. 🚀 Show loaded prompt, 3. 📂 Open project,  B. 🏗️ Build Project, X. 📂 Voice settings
//"""
//}

//func numericalCommands() -> String {
//"""
//\(logV == .verbose ? sharedCommands() : "")
//🔹 4. 🚪📂 Close project,  5. 🖥️🔧 Fix errors w/ GPT, 6. 🆕   Continue implementation
//"""
//}

