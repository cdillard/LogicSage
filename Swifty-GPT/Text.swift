//
//  TextStuffs.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

var commands = """
🔹 idea:  💡 New appDesc prompt
🔹 gpt:   🧠 Talk to GPT
🔹 xcode: 🛠️ Run Xcode operations
🔹 exit:  🚪 Close the program
"""

func generatedOpenLine() -> String {
    """

    \(openLinePrintCount == 0 ? "\(logoAscii2)\n 🚀🔥 Welcome to Swifty GPT 🧠💥\n" : "")


    🔹 1. ✨ Run appDesc GPT prompt
    🔹 2. 🚀 Show loaded prompt
    🔹 3. 📂 Open project

    \(commands)

    🔍 Please choose an option [1-3, gpt:, xcode:, idea:, exit]:

    """
}



var openLinePrintCount = 0

var openingLine = generatedOpenLine()

func updateOpeningLine() {

    openingLine = generatedOpenLine()
}


let afterBuildFailedLine = """
Project creation failed. Check the Xcode project for simple mistakes [4] 🤔. Use GPT to fix it [5] 🤖.

🔹 1. ✨   Run appDesc GPT prompt
🔹 2. 🚀   Show loaded prompt
🔹 3. 📂   Open project
🔹 4. 🚪📂 Close project
🔹 5. 🖥️🔧 Fix errors w/ GPT
🔹 6. 🆕   Continue implementation

\(commands)

❓ What would you like to do:
🔍 Please choose an option [1-6, gpt:, xcode:, idea:, exit]:

"""


let afterSuccessLine = """
Project creation success. Project should have auto openned.

🔹 1. ✨   Run appDesc GPT prompt
🔹 2. 🚀   Show loaded prompt
🔹 3. 📂   Open project
🔹 4. 🚪📂 Close project
🔹 5. 🖥️🔧 Fix errors w/ GPT
🔹 6. 🆕   Continue implementation

\(commands)

🔍 Please choose an option [1-6, gpt:, xcode:, idea:, exit]:

"""
