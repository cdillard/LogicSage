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
  rs    🔁 Reset prompt state
  del   🗑️ Backup & delete workspace
"""
}

func generatedOpenLine(overrideV: Bool = false) -> String {
    let openLine = """
    \(logoAscii5)
    \((logV == .verbose && overrideV) ? commandsText() : "")
    🔍:
    """
    return openLine
}

var openLinePrintCount = 0

var openingLine = generatedOpenLine()

func updateOpeningLine() {

    openingLine = generatedOpenLine()
}

func afterBuildFailedLine() -> String {
"""
Project creation failed. Open the Xcode project and check for simple mistakes AI may have made [o] 🤔.
❓ What would you like to do:
🔍 Please choose an option [(r): Run loaded prompt, (s): Show loaded prompt, (o): Open Xcode Project, (del): Backup & Delete Workspace,  (c): list commands]:
"""
}
