//
//  TextStuffs.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

var showOnce = true

var openingLine = """

\(showOnce ? logoAscii : "")

🚀🔥 Welcome to Swifty GPT 🧠💥

🔹 1. ✨ Run appDesc GPT prompt
🔹 2. 🚀 Show loaded prompt
🔹 3. 📂 Open project

🔹 idea: 💡 New appDesc prompt
🔹 gpt: 🧠 Talk to GPT
🔹 xcode: 🛠️ Run Xcode operations
🔹 exit: 🚪 Close the program

🔍 Please choose an option [1-3, gpt:, xcode:]:

"""

func updateOpeningLine() {
    openingLine = """

    \(showOnce ? logoAscii : "")

    🚀🔥 Welcome to Swifty GPT 🧠💥

    🔹 1. ✨ Run appDesc GPT prompt
    🔹 2. 🚀 Show loaded prompt
    🔹 3. 📂 Open project

    🔹 idea: 💡 New appDesc prompt
    🔹 gpt: 🧠 Talk to GPT
    🔹 xcode: 🛠️ Run Xcode operations
    🔹 exit: 🚪 Close the program

    🔍 Please choose an option [1-3, gpt:, xcode:]:

    """
}


let afterBuildFailedLine = """
Project creation failed. Check the Xcode project for simple mistakes. 🤔

🔹 1. ✨   Run appDesc GPT prompt
🔹 2. 🚀   Show loaded prompt
🔹 3. 📂   Open project
🔹 4. 🚪📂 Close project
🔹 5. 🖥️🔧 Fix errors w/ GPT

🔹 idea: 💡 New appDesc prompt
🔹 gpt: 🧠 Talk to GPT
🔹 xcode: 🛠️ Run Xcode operations
🔹 exit: 🚪 Close the program

❓ What would you like to do:
🔍 Please choose an option [1-5, gpt:, xcode:]:

"""


let afterSuccessLine = """
Project creation success. Project should have auto openned.

🔹 1. ✨   Run appDesc GPT prompt
🔹 2. 🚀   Show loaded prompt
🔹 3. 📂   Open project
🔹 4. 🚪📂 Close project
🔹 5. 🖥️🔧 Fix errors w/ GPT

🔹 idea: 💡 New appDesc prompt
🔹 gpt: 🧠 Talk to GPT
🔹 xcode: 🛠️ Run Xcode operations
🔹 exit: 🚪 Close the program

🔍 Please choose an option [1-5, gpt:, xcode:]:

"""


let logoAscii = """

 $$$$$$\\                $$\\  $$$$$$\\    $$\\                        $$$$$$\\  $$$$$$$\\ $$$$$$$$\\
$$  __$$\\               \\__|$$  __$$\\   $$ |                      $$  __$$\\ $$  __$$\\\\__$$  __|
$$ /  \\__|$$\\  $$\\  $$\\ $$\\ $$ /  \\__|$$$$$$\\   $$\\   $$\\         $$ /  \\__|$$ |  $$ |  $$ |
\\$$$$$$\\  $$ | $$ | $$ |$$ |$$$$\\     \\_$$  _|  $$ |  $$ |$$$$$$\\ $$ |$$$$\\ $$$$$$$  |  $$ |
 \\____$$\\ $$ | $$ | $$ |$$ |$$  _|      $$ |    $$ |  $$ |\\______|$$ |\\_$$ |$$  ____/   $$ |
$$\\   $$ |$$ | $$ | $$ |$$ |$$ |        $$ |$$\\ $$ |  $$ |        $$ |  $$ |$$ |        $$ |
\\$$$$$$  |\\$$$$$\\$$$$  |$$ |$$ |        \\$$$$  |\\$$$$$$$ |        \\$$$$$$  |$$ |        $$ |
 \\______/  \\_____\\____/ \\__|\\__|         \\____/  \\____$$ |         \\______/ \\__|        \\__|
                                                $$\\   $$ |
                                                \\$$$$$$  |
                                                 \\______/

"""


let loadingText = """

 o                   o                              o
O                   O  o                           O                             o
o                   o                              o                                  O
O                   o                              O                                 oOo
o  .oOo. .oOoO' .oOoO  O  'OoOo. .oOoO       .oOo. o  ooOO       'o     O .oOoO' O    o
O  O   o O   o  o   O  o   o   O o   O       O   o O    o         O  o  o O   o  o    O
o  o   O o   O  O   o  O   O   o O   o       o   O o   O          o  O  O o   O  O    o
Oo `OoO' `OoO'o `OoO'o o'  o   O `OoOo       oOoO' Oo OooO        `Oo'oO' `OoO'o o'   `oO
                                     O       O
                                  OoO'       o'

"""
