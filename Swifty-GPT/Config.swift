//
//  Config.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/19/23.
//

import Foundation

// OPEN AI SETTINGS

// TODO: MOVE TO CONFIG

let gptModel = "gpt-4-1106-preview"

//let gptModel = "gpt-4-0314"

//let gptModel = "gpt-4-0314-32k"

//let gptModel = "gpt-4"

//let gptModel = "gpt-4-32k"

// == GPT 3.5 TURBO MODEL CHOICES ==

//let gptModel = "gpt-3.5-turbo-16k-0613"

//let gptModel = "gpt-3.5-turbo-16k"

//let gptModel = "gpt-3.5-turbo"

let apiEndpoint = "https://api.openai.com/v1/chat/completions"

//  let modelsApiEndpoint = https://api.openai.com/v1/models

// sws CONFIG
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
    conversational: false,
    streak: 0,
    chosenTQ: nil,
    promptMode: .normal,
    // EXPERIMENTAL: YE BEEN WARNED!!!!!!!!!!!!
    enableGoogle: false,
    enableLink: false,
    loadMode: LoadMode.dots,
    voiceOutputEnabled: false,
    voiceInputEnabled: false,
    interactiveMode: true,
    projectArray: [FileSystemItem]()
)

//// Set builtInAppDesc
let builtInAppDesc = "a simple SwiftUI app that shows SFSymbols and Emojis that go together well on a scrollable grid"
//
//// TODO: Fix hardcoded paths.
let xcodegenPath = "/opt/homebrew/bin/xcodegen"
//
//// WORKSPACE SETTING
let swiftyGPTWorkspaceFirstName = "LogicSageWorkspace"
//
let swiftyGPTWorkspaceName = "\(swiftyGPTWorkspaceFirstName)/Workspace"

// SwiftyGPTWOrkspace/Wallpaper
//let dynamicWallpaperFolder = "/Users/$USERNAME/Library/Application Support/com.apple.mobileAssetDesktop"
//let staticWallpaperFolder = "/System/Library/Desktop Pictures"


// 1. change your loading mode, matrix is fun but busy, waves is classy, dots are minimal. Let me know if these chocices don't suit
// your fancy and you know i'll add more.

var defaultLoadMode = LoadMode.dots

// Eventualy wr''ll read loadMoad from the user ID prefs

enum LoadMode {
    case none
    case dots
    case bar
    case waves
    case matrix
}

// NETWORKING SETTINGS AND MISC
let PING_INTERVAL: TimeInterval = 60.666
let bundleID = "com.chrisdillard.SwiftSageServer"
//let bundleID = "com.chrisdillard.SwiftSageServer"

// VOICE SETTINGS
let alexVoice = "com.apple.speech.synthesis.voice.Alex"
let avaVoice = "com.apple.voice.premium.en-US.Ava"
let allisonVoice = "com.apple.voice.enhanced.en-US.Allison"
let sageVoice = "com.apple.ttsbundle.siri_Nicky_en-US_compact"
let grandmaVoice = "com.apple.eloquence.en-US.Grandma"
let eddyVoice = "com.apple.eloquence.en-US.Eddy"
let shellVoice = "com.apple.eloquence.en-US.Shelley"
let sammyVoice = "com.apple.voice.compact.en-US.Samantha"
let kathyVoice = "com.apple.speech.synthesis.voice.Kathy"
let sandyVoice = "com.apple.eloquence.en-US.Sandy"
let floVoice = "com.apple.eloquence.en-US.Flo"
let aaronVoice = "com.apple.ttsbundle.siri_Aaron_en-US_compact"
var defaultMachineVoice = "com.apple.speech.synthesis.voice.Zarvox"

// CHOOSE your default voice (if using built in Mac OS voice synthesis)
// INCLUDE THE FOLLOWING LINE IF NOT USING CEREPROC VOICES.
var defaultVoice = avaVoice//allisonVoice//aaronVoice//floVoice//sandyVoice//kathyVoice//sammyVoice//eddyVoice//sageVoice

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
var SWIFTSAGE_USERNAME:String {
    get {
        keyForName(name: "SWIFTSAGE_USERNAME")
    }
}
var SWIFTSAGE_SERVER_USERNAME:String {
    get {
        keyForName(name: "SWIFTSAGE_SERVER_USERNAME")
    }
}
var SWIFTSAGE_SERVER_PASSWORD:String {
    get {
        keyForName(name: "SWIFTSAGE_SERVER_PASSWORD")
    }
}
var SWIFTSAGE_PASSWORD:String {
    get {
        keyForName(name: "SWIFTSAGE_PASSWORD")
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

//// set to false and it should go til successful build automatically using built in prompt, if it actually does anything good or not is up to chance though.
//let interactiveMode = true
//
let aiNamedProject = true
let tryToFixCompileErrors = true
let includeSourceCodeFromPreviousRun = true
func asciAnimations() -> Bool {
    config.loadMode == LoadMode.matrix
}
//
let triviaEnabledSwift = true
let triviaEnabledObjc = false


// CEREPROC ZONE ///////////////////////////////
// EXPERIMENTAL AUDIO
// What YOU don't like the goofy robotic voices built in to Mac OS????
// DISABLED BY DEFAULT: SEE README AND https://www.cereproc.com
// Specify a built in cereproc voice that yuou see in the (5) output.
// For instance I have included Heather, Hannah, Sam, Carolyn,
// Lauren, Megan, Katherine, and Isabella for my Cereproc voices
let heatherVoice = "com.cereproc.tts.CereVoice6_fmm"
let hannahVoice = "com.cereproc.tts.CereVoice6_abm"
let carolynVoice = "com.cereproc.tts.CereVoice6_acm"
let samVoice = "com.cereproc.tts.CereVoice6_mmu" // new ones
let laurenVoice = "com.cereproc.tts.CereVoice6_rrh"
let isabellaVoice = "com.cereproc.tts.CereVoice6_vde"
let meganVoice = "com.cereproc.tts.CereVoice6_alk"
let katherineVoice = "com.cereproc.tts.CereVoice6_smo"
// Don't check this in -- Chris
// UNCOMMENT THIS LINE AND fill the below arrs with your purchased Cereproc voices.
// var defaultVoice =  cereprocVoices.randomElement() ?? heatherVoice
let cereprocVoices = [
    heatherVoice,
    hannahVoice,
    carolynVoice,
    samVoice,
    laurenVoice,
    isabellaVoice,
    meganVoice,
    katherineVoice
]
let cereprocVoicesNames = [
    "Heather",
    "Hannah",
    "Carolyn",
    "Sam",
    "Lauren",
    "Isabella",
    "Megan",
    "Katherine"
]
func currentCereprocVoiceName() -> String {
    cereprocVoicesNames[cereprocVoices.firstIndex(of: defaultVoice) ?? 0]
}
func getCereprocVoiceIdentifier(name: String) -> String {
    cereprocVoices[cereprocVoicesNames.firstIndex(of: name) ?? 0]
}
// END CEREPROC ZONE ///////////////////////////////

// VERY EXPERIMENTAL MACOS / IOS INTEGRATIONS
let enableMacSage = true
let swiftSageIOSEnabled = true

var logV: LogVerbosity = .none

enum LogVerbosity {
    case verbose
    case none
}
// ASCII MOVIES ZONE ///////////////////////////////
// IF the movie is TOO big/blurry for you and your tastes try manually setting your sws/Xcode console font to 2 or 3 and then  turn movie width up :).
// We'll need to sync each clients terminal window/s widths to make sure the animations and movies play properly.
let movieWidth = 175
let matrixScreenWidth = 100
// END ASCII MOVIES ZONE ///////////////////////////////
