//
//  SettingsViewModel+Constants.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/14/23.
//

import Foundation

let defaultTerminalFontSize: Double = 13.666
let defaultCommandButtonSize: Double = 28
let defaultToolbarButtonScale: Double = 0.27

let defaultHandleSize: Double = 40.0
let defaultSourceEditorFontSize: Double = 12.666
let email = "chrisbdillard@gmail.com"

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
╰━━━┻━━┻━╮┣┻━━┻━━━┻╯╰┻━╮┣━━╯model:\(model)
"""
}
