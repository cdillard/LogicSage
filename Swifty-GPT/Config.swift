//
//  Config.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/19/23.
//

import Foundation


// VOICE SETTINGS

// var defaultVoice = "Rishi"
var defaultVoice = "Karen"

// Set builtInAppDesc
let builtInAppDesc = "that displays a 3d scene. Show 3 spheres and a ground plane. Attach physics body to spheres so they react to gravity"  // a Towering Skyscraper and a bridge

// TODO: Fix hardcoded paths.
let xcodegenPath = "/opt/homebrew/bin/xcodegen"

// WORKSPACE SETTING
let swiftyGPTWorkspaceFirstName = "SwiftyGPTWorkspace"

let swiftyGPTWorkspaceName = "\(swiftyGPTWorkspaceFirstName)/Workspace"

// OPEN AI SETTIN
let gptModel = "gpt-3.5-turbo" // Can someone out there hook me up with "gpt-4" ;)
let apiEndpoint = "https://api.openai.com/v1/chat/completions"

// PLIST SETTINGS

func keyForName(name: String) -> String {
    guard let apiKey = plistHelper.objectFor(key: name, plist: "GPT-Info") as? String else { return "" }
    return apiKey
}

// Add your Open AI key to the GPT-Info.plist file
var OPEN_AI_KEY:String {
    get {
        keyForName(name: "OPEN_AI_KEY")
    }
}
var PIXABAY_KEY:String {
    get {
        keyForName(name: "PIXABAY_KEY")
    }
}
var GOOGLE_KEY:String {
    get {
        keyForName(name: "GOOGLE_KEY")
    }
}
var GOOGLE_ID:String {
    get {
        keyForName(name: "GOOGLE_SEARCH_ID")
    }
}

var infoPlistPath:String {
    get {
        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            return plistPath
        }
        return ""
    }
}
var rubyScriptPath:String {
    get {
        if let scriptPath = Bundle.main.path(forResource: "add_file_to_project", ofType: "rb") {
            return scriptPath
        }
        return ""
    }
}

// Configurable settings for AI.
let retryLimit = 10
let fixItRetryLimit = 3

// set to false and it should go til successful build automatically using built in prompt, if it actually does anything good or not is up to chance though.
let interactiveMode = true

let aiNamedProject = true
let tryToFixCompileErrors = true
let includeSourceCodeFromPreviousRun = true
let asciAnimations = false

let triviaEnabledSwift = true
let triviaEnabledObjc = false

let voiceOutputEnabled = true
let voiceInputEnabled = true

// EXPERIMENTAL: YE BEEN WARNED!!!!!!!!!!!!
let enableGoogle = false
let enableLink = false

// DO NOT USE
let enableAEyes = false

var logV: LogVerbosity = .verbose

enum LogVerbosity {
    case verbose
    case none
}

// IF the movie is TOO big/blurry for you and your tastes try manually setting your Xcode console font to 2 or 3 and then  turn movie width up :).
let movieWidth = 60
let matrixScreenWidth = 100

