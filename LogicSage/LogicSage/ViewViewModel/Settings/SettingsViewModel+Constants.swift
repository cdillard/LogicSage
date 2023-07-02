//
//  SettingsViewModel+Constants.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/14/23.
//

import Foundation

let aiModelOptions: [String] = [
    "gpt-4",
    "gpt-4-0314",
    "gpt-4-0613",
    "gpt-4-32k",
    "gpt-4-32k-0314",
    "gpt-4-32k-0613",
    "gpt-3.5-turbo",
    "gpt-3.5-turbo-0301",
    "gpt-3.5-turbo-0613",
    "gpt-3.5-turbo-16k",
    "gpt-3.5-turbo-16k-0613",
]

let defaultTerminalFontSize: Double = 13.666
let defaultCommandButtonSize: Double = 28
let defaultToolbarButtonScale: Double = 0.27

let defaultHandleSize: Double = 37
let defaultSourceEditorFontSize: Double = 12.666

let defaultOwner = "cdillard"
let defaultRepo = "LogicSage"
let defaultBranch = "main"

let defaultYourGithubUsername = "cdillard"

let jsonFileName = "conversations"

let bundleID = "com.chrisdillard.SwiftSage"
let appLink = URL(string: "https://apps.apple.com/us/app/logicsage/id6448485441")!

func logoAscii5(model: String = SettingsViewModel.shared.openAIModel) -> String {
"""
┃┃╱╱╭━━┳━━┳┳━━┫╰━━┳━━┳━━┳━━╮
┃┃╱╭┫╭╮┃╭╮┣┫╭━┻━━╮┃╭╮┃╭╮┃┃━┫
┃╰━╯┃╰╯┃╰╯┃┃╰━┫╰━╯┃╭╮┃╰╯┃┃━┫
╰━━━┻━━┻━╮┣┻━━┻━━━┻╯╰┻━╮┣━━╯model: \(model)
"""
}
