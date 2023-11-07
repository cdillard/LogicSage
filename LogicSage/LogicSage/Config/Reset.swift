//
//  Reset.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/2/23.
//

import Foundation

// DEFAULT IS NOW GPT-4 (due to its general availability)
let defaultGPTModel = "gpt-4-1106-preview"

//let defaultGPTModel = "gpt-4-0314"
//let defaultGPTModel = "gpt-4"

//let defaultGPTModel = "gpt-3.5-turbo"

let apiEndpoint = "https://api.openai.com/v1/chat/completions"

// WORKSPACE SETTING
let swiftyGPTWorkspaceFirstName = "SwiftyGPTWorkspace"

let swiftyGPTWorkspaceName = "\(swiftyGPTWorkspaceFirstName)/Workspace"

let builtInAppDesc = "a simple SwiftUI app that shows SFSymbols and Emojis that go together well on a scrollable grid"

var config = Config(
    projectName: "MyApp",
    globalErrors: [String](),
    manualPromptString: "",
    blockingInput: false,
    promptingRetryNumber: 0,
    lastFileContents: [String](),
    lastNameContents: [String](),
    searchResultHeadingGlobal: nil,
    appName: "MyApp",
    appType: "iOS",
    appDesc: builtInAppDesc,
    language: "Swift",
    conversational: true,
    streak: 0,
    chosenTQ: nil,
    promptMode: .normal,
    // EXPERIMENTAL: YE BEEN WARNED!!!!!!!!!!!!
    enableGoogle: true,
    enableLink: true,
    loadMode: LoadMode.dots,
    projectArray: [FileSystemItem]()

)

// Configurable settings for AI.
let retryLimit = 10
let fixItRetryLimit = 3

// set to false and it should go til successful build automatically using built in prompt, if it actually does anything good or not is up to chance though.
let interactiveMode = true
let aiNamedProject = true

// OPEN LINE ZONE
func generatedOpenLine(overrideV: Bool = false) -> String {
    """
    🔍:
    """
}
var openLinePrintCount = 0
var openingLine = generatedOpenLine()

// END OPEN LINE ZONE

// LOAD MOAD ZONE
// . change your loading mode, matrix is fun but busy, waves is classy, dots are minimal. Let me know if these chocices don't suit your fancy and you know i'll add more.
var defaultLoadMode = LoadMode.dots
// END LOAD MOAD ZONE

func asciAnimations() -> Bool {
    config.loadMode == LoadMode.matrix
}

struct TriviaQuestion {
    let question: String
    let code: String?
    let options: [String]
    let correctOptionIndex: Int
    let reference: String
}
enum InputMode {
    case loading
    case normal
    case debate
    case trivia
}
enum LoadMode {
    case none
    case dots
    case bar
    case waves
    case matrix
}
struct Config {
    var projectName: String
    var globalErrors: [String]
    var manualPromptString: String
    var blockingInput: Bool
    var promptingRetryNumber: Int

    var lastFileContents: [String]
    var lastNameContents: [String]
    var searchResultHeadingGlobal: String?
    var linkResultGlobal: String?

    var appName: String
    var appType: String

    var appDesc: String
    var language: String

    var conversational: Bool
    var streak: Int
    var chosenTQ: TriviaQuestion?
    var promptMode: InputMode

    // EXPERIMENTAL: YE BEEN WARNED!!!!!!!!!!!!
    var enableGoogle: Bool
    var enableLink: Bool

    var loadMode: LoadMode

    var projectArray: [FileSystemItem]

}
func resetCommand(input: String) {

    // TODO: Reset for the right user.
    resetCommandWithConfig(config: &config)
}

func resetCommandWithConfig(config: inout Config) {
    config.projectName = "MyApp"
    config.globalErrors = [String]()
    config.manualPromptString = ""
    config.blockingInput = false
    config.promptingRetryNumber = 0

    config.lastFileContents = [String]()
    config.lastNameContents = [String]()
    config.searchResultHeadingGlobal = nil

    config.appName = "MyApp"
    config.appType = "iOS"

    config.appDesc = builtInAppDesc
    config.language = "Swift"

    config.conversational = true
    config.manualPromptString = ""

    config.streak = 0
    config.chosenTQ = nil
    config.promptMode = .normal

    config.loadMode = LoadMode.dots

    config.projectArray = [FileSystemItem]()

    logD("🔁🔄♻️ Reset.")
}
