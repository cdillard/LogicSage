//
//  SettingsViewModel.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI
import Combine
import StoreKit
import AVFoundation

public class SettingsViewModel: ObservableObject {

    public static let shared = SettingsViewModel()

    //preload webkit
#if !os(tvOS)
#if !targetEnvironment(macCatalyst)

    var _preLoadWebViewStore: WebViewStore = WebViewStore()
#endif
#endif

    let speechSynthesizer = AVSpeechSynthesizer()
    let speakerDelegate = SpeakerDelegate()
    
    let keychainManager = KeychainManager()

// BEGIN TERMINAL ZONE **************************************************************************************
    func logText(_ text: String, terminator: String = "\n") {
        DispatchQueue.main.async {
            self.consoleManagerText.append(text)
            self.consoleManagerText.append(terminator)
        }
    }
    var consoleManagerText: String = ""
// END TERMINAL ZONE **************************************************************************************

    var latestWindowManager: WindowManager?

    var serviceDiscovery: ServiceDiscovery?

    // BEGIN SAVED UI SETTINGS ZONE **************************************************************************************

    @Published var root: RepoFile?

    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("savedUserAvatar") var savedUserAvatar: String = "👨"
    @AppStorage("savedBotAvatar") var savedBotAvatar: String = "🤖"

    @Published var changes = [ChangeRow]()
    @Published var unstagedFileChanges = [FileChange]()
    @Published var stagedFileChanges = [FileChange]()

    @Published var isLoading: Bool = false
    var cancellable: AnyCancellable?

    @Published var downloadProgress: Double = 0.0
    @Published var unzipProgress: Double = 0.0
    @Published var forkProgress: Double = 0.0

    @Published var ipAddress: String = ""
    @Published var port: String = ""

    @Published var showAudioSettings: Bool = false
    @AppStorage("autoCorrect") var autoCorrect: Bool = true
    @AppStorage("defaultURL") var defaultURL = "https://www.google.com"
    @AppStorage("chatUpdateInterval") var chatUpdateInterval: Double = 0.5

    @Published var initalAnim: Bool = false

    func doDiscover() {
        serviceDiscovery?.startDiscovering()
    }

    @AppStorage("chatGPTAuth") var chatGPTAuth: Bool = false

// END SAVED UI SETTINGS ZONE **************************************************************************************

// BEGIN STREAMING IMAGES/ZIPZ OVER WEBSOCKET ZONE *****************************************************************
    @Published var receivedImageData: Data? = nil {
        didSet {
            recieveImageData(recievedImageData: receivedImageData)
        }
    }
#if !os(macOS)
    @Published var actualReceivedImage: UIImage?
    @Published var receivedWallpaperFileName: String?
    @Published var receivedWallpaperFileSize: Int?

    @Published var receivedSimulatorFrameData: Data? = nil {
        didSet {
            actualReceivedSimulatorFrame = UIImage(data: receivedSimulatorFrameData  ?? Data())

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                    if self.latestWindowManager?.windows.contains(where: {$0.windowType == .simulator }) != true {

                    self.latestWindowManager?.addWindow(windowType: .simulator, frame: defSize, zIndex: 0)
                }
            }
        }
    }
    @Published var actualReceivedSimulatorFrame: UIImage?

    @Published var recievedWorkspaceData: Data? = nil {
        didSet {
            if let recievedWorkspaceData {
                recieveWorkspaceData(receivedWorkspaceData: recievedWorkspaceData)
            }
        }
    }
#endif
// END STREAMING IMAGES/ZIPZ OVER WEBSOCKET ZONE *****************************************************************

// BEGIN SAVED AUDIO SETTINS ZONE *****************************************************************
    @AppStorage("savedVoiceName") var voiceOutputSavedName: String = "" {
        didSet {
            if !installedVoices.isEmpty {
                selectedVoice = installedVoices.first(where: { $0.voiceName == voiceOutputSavedName })
            }
        }
    }
    @AppStorage("voiceOutputEnabled") var voiceOutputEnabled = false
    @AppStorage("duckingAudio") var duckingAudio = false

    // TODO: Add more server controls for server voice
    @Published var serverVoiceOutputEnabled = false
    @Published var installedVoices = [VoicePair]()
    @Published var selectedVoice: VoicePair?
    @Published var isRecording = false
// END SAVED AUDIO SETTINGS ZONE *****************************************************************

// BEGIN SAVED SIZES ZONE **************************************************************************************
    @AppStorage("savedButtonSize") var buttonScale: Double = defaultToolbarButtonScale
    @AppStorage("commandButtonFontSize")var commandButtonFontSize: Double = defaultCommandButtonSize
    @AppStorage("cornerHandleSize")var cornerHandleSize: Double = defaultHandleSize
    @AppStorage("fontSizeSrcEditor") var fontSizeSrcEditor: Double = defaultSourceEditorFontSize

// END SAVED SIZES ZONE ********************************************************************************************

    @Published var appTextColor: Color {
        didSet {
            setUserDefaultFor(appTextColor, "appTextColor")
        }
    }
    @Published var buttonColor: Color {
        didSet {
            setUserDefaultFor(buttonColor, "buttonColor")
        }
    }
    @Published var backgroundColor: Color {
        didSet {
            setUserDefaultFor(backgroundColor, "backgroundColor")
        }
    }
    // BEGIN SUB ZONE FOR SRC EDITOR COLORS ********************************************

    @Published var plainColorSrcEditor: Color {
        didSet {
            setUserDefaultFor(plainColorSrcEditor, "plainColorSrcEditor")
        }
    }
    @Published var numberColorSrcEditor: Color {
        didSet {
            setUserDefaultFor(numberColorSrcEditor, "numberColorSrcEditor")
        }
    }
    @Published var stringColorSrcEditor: Color {
        didSet {
            setUserDefaultFor(stringColorSrcEditor, "stringColorSrcEditor")
        }
    }
    @Published var identifierColorSrcEditor: Color {
        didSet {
            setUserDefaultFor(identifierColorSrcEditor, "identifierColorSrcEditor")
        }
    }
    @Published var keywordColorSrcEditor: Color {
        didSet {
            setUserDefaultFor(keywordColorSrcEditor, "keywordColorSrcEditor")
        }
    }
    @Published var commentColorSrceEditor: Color {
        didSet {
            setUserDefaultFor(commentColorSrceEditor, "commentColorSrceEditor")
        }
    }
    @Published var editorPlaceholderColorSrcEditor: Color {
        didSet {
            setUserDefaultFor(editorPlaceholderColorSrcEditor, "editorPlaceholderColorSrcEditor")
        }
    }
    @Published var backgroundColorSrcEditor: Color {
        didSet {
            setUserDefaultFor(backgroundColorSrcEditor, "backgroundColorSrcEditor")
        }
    }
    @Published var lineNumbersColorSrcEditor: Color {
        didSet {
            setUserDefaultFor(lineNumbersColorSrcEditor, "lineNumbersColorSrcEditor")
        }
    }

    func setUserDefaultFor(_ rawValue: Color, _ key: String) {
#if !os(macOS)
        UserDefaults.standard.set(rawValue.rawValue, forKey: key)
#endif
    }

// END SUB ZONE FOR SRC EDITOR COLORS********************************************
// END SAVED COLORS ZONE **************************************************************************************

// BEGIN CLIENT API KEYS ZONE ******************************************************************************
// TODO: React to user name and password change
    let aiKeyKey = "openAIKeySec"
    let ghaKeyKey = "ghaPat"
    let googleKeyKey = "googleKey"
    let googleSearchIDKey = "googleSearchId"

    @AppStorage("userName") var userName = "chris" {
        didSet {
        }
    }
    @Published var password = "swiftsage" {
        didSet {
            DispatchQueue.global(qos: .default).async {
                
                if self.keychainManager.saveToKeychain(key: "swsPassword", value: self.password) {
                    print("Key saved successfully")
                } else {
                    print("Error saving key")
                }
            }
        }
    }

    @AppStorage("openAIModel") var openAIModel = defaultGPTModel

    @Published var openAIKey = "" {
        didSet {
            let trimmedKey = openAIKey.trimmingCharacters(in: .whitespacesAndNewlines)
#if os(xrOS)
#if targetEnvironment(simulator)
            UserDefaults.standard.set(trimmedKey, forKey: "openAIKey")
#endif
#endif
            DispatchQueue.global(qos: .default).async {
                
                if self.keychainManager.saveToKeychain(key:self.aiKeyKey, value: trimmedKey) {
                    print("openAIKey saved successfully")
                } else {
                    print("Error saving ai key")
                }
                DispatchQueue.main.async {
                    GPT.shared.resetOpenAI()
                }
            }
        }
    }
    @Published var ghaPat = ""  {
        didSet {
            let trimmedKey = ghaPat.trimmingCharacters(in: .whitespacesAndNewlines)
#if os(xrOS)
#if targetEnvironment(simulator)
            UserDefaults.standard.set(trimmedKey, forKey: ghaKeyKey)
#endif
#endif
            DispatchQueue.global(qos: .default).async {
                
                if self.keychainManager.saveToKeychain(key: self.ghaKeyKey, value: trimmedKey) {
                    print("ghPat saved successfully")
                } else {
                    print("Error saving gha pat")
                }
            }
        }
    }
    @AppStorage("openAIHost") var openAIHost = "api.openai.com" {
        didSet {
            DispatchQueue.main.async {
                GPT.shared.resetOpenAI()
            }
        }
    }

    @Published var googleKey = ""  {
        didSet {
            let trimmedKey = googleKey.trimmingCharacters(in: .whitespacesAndNewlines)
#if os(xrOS)
#if targetEnvironment(simulator)
            UserDefaults.standard.set(trimmedKey, forKey: googleKeyKey)
#endif
#endif
            DispatchQueue.global(qos: .default).async {

                if self.keychainManager.saveToKeychain(key: self.googleKeyKey, value: trimmedKey) {
                    print("googleKey saved successfully")
                } else {
                    print("Error saving gha googleKey")
                }
            }
        }
    }

    @Published var googleSearchId = ""  {
        didSet {
            let trimmedKey = googleSearchId.trimmingCharacters(in: .whitespacesAndNewlines)
#if os(xrOS)
#if targetEnvironment(simulator)
            UserDefaults.standard.set(trimmedKey, forKey: googleSearchIDKey)
#endif
#endif
            DispatchQueue.global(qos: .default).async {

                if self.keychainManager.saveToKeychain(key: self.googleSearchIDKey, value: trimmedKey) {
                    print("googleSearchId saved successfully")
                } else {
                    print("Error saving gha googleSearchId")
                }
            }
        }
    }
    func googleAvailable() -> Bool {
        !googleKey.isEmpty && !googleSearchId.isEmpty
    }

    @AppStorage("yourGitUser") var yourGitUser = "\(defaultYourGithubUsername)"
    @AppStorage("gitUser") var gitUser = "\(defaultOwner)"
    // It's not okay to only allow lowercase. The forking API is case-sensitive with repos so we must be vigilant and use the same case when working with Github. OK?
    @AppStorage("gitRepo") var gitRepo = "\(defaultRepo)"
    @AppStorage("gitBranch") var gitBranch = "\(defaultBranch)"

    let aiAccessTokenKey = "openAIAccessTokenKeySec"
    @Published var accessToken = "" {
        didSet {

            DispatchQueue.global(qos: .default).async {
                
                if self.keychainManager.saveToKeychain(key: self.aiAccessTokenKey, value: self.accessToken) {
                    print("aiAccessTokenKey saved successfully")
                } else {
                    print("Error saving accessToken pat")
                }
            }
        }
    }

    @Published var cookies: [String : String] = [:] {
        didSet {
            logD("did set shared cookies")
        }
    }
// END CLIENT APIS ZONE **************************************************************************************

// START GPT CONVERSATION VIEWMODEL ZONE ***********************************************************************

    let idProvider: () -> String
    let dateProvider: () -> Date
// WAS @Published
    var conversations: [Conversation] = [] {
        didSet {
            //logD("new convo state:\n\(conversations)")
        }
    }
    var conversationErrors: [Conversation.ID: Error] = [:] {
        didSet {
            if !conversationErrors.isEmpty {
                logD("new convo error state = \(conversationErrors)")
            }
        }
    }
    @AppStorage("completedMessages") var completedMessages = 0

// END GPT CONVERSATION VIEWMODEL ZONE ***********************************************************************

// START DEBUGGER VIEWMODEL ZONE ***********************************************************************
    @Published var isDebugging: Bool = false
    @Published var targetName: String = "LogicSage"
    @Published var deviceName: String = "Chris🚀🙌♾🦍"
    @Published var debuggingStatus: String = ""
    @Published var warningCount: Int = 0
    @Published var errorCount: Int = 0

// END DEBUGGER VIEWMODEL ZONE ***********************************************************************

// START STOREKIT ZONE ***********************************************************************
    func requestReview() {
        DispatchQueue.main.async {
            self.completedMessages += 1
            let reviewLimit = 33
            let newCompletionMsgs = self.completedMessages
            print("\(newCompletionMsgs) % \(reviewLimit) = will review")
            guard newCompletionMsgs % reviewLimit == 0 else {
                return print("no review today")
            }
            print("SKStoreReviewController.requestReview")
#if !os(xrOS)
#if !os(tvOS)

            SKStoreReviewController.requestReview()
#endif
#endif

        }
    }
// END STOREKIT ZONE ***********************************************************************

    init() {
        self.idProvider = { UUID().uuidString }
        self.dateProvider = Date.init

// BEGIN SIZE SETTING LOAD ZONE FROM DISK *********************************
        if UserDefaults.standard.double(forKey: "savedButtonSize") != 0 {
            self.buttonScale = UserDefaults.standard.double(forKey: "savedButtonSize")
        }
        else {
            self.buttonScale = defaultToolbarButtonScale
        }
        
        if UserDefaults.standard.double(forKey: "commandButtonFontSize") != 0 {
            self.commandButtonFontSize = CGFloat(UserDefaults.standard.double(forKey: "commandButtonFontSize"))
        }
        else {
            self.commandButtonFontSize = defaultCommandButtonSize
        }
        
        // END SIZE SETTING LOAD ZONE FROM DISK

// BEGIN LOAD CLIENT SECRET FROM KEYCHAIN ZONE ******************************
        if let key = keychainManager.retrieveFromKeychain(key: aiKeyKey) {

            self.openAIKey = key
            //  print("Retrieved value: aiKey")
        } else {
            //            print("Error retrieving openAIKey")
            //            keychainManager.saveToKeychain(key:openAIKey, value: "")
        }
#if os(xrOS)
#if targetEnvironment(simulator)
        if let key = UserDefaults.standard.string(forKey: "openAIKey") {
            self.openAIKey = key
        }
#endif
#endif

        if let key = keychainManager.retrieveFromKeychain(key: ghaKeyKey) {

            self.ghaPat = key
            // print("Retrieved value: ghaPat")
        } else {
            //         print("Error retrieving ghaPat == reset")
            //           keychainManager.saveToKeychain(key:ghaKeyKey, value: "")
        }

#if os(xrOS)
#if targetEnvironment(simulator)
        if let key = UserDefaults.standard.string(forKey: ghaKeyKey) {
            self.ghaPat = key
        }
#endif
#endif

        if let key = keychainManager.retrieveFromKeychain(key: googleKeyKey) {
            self.googleKey = key
        }


        if let key = keychainManager.retrieveFromKeychain(key: googleSearchIDKey) {
            self.googleSearchId = key
        }
        if let key = keychainManager.retrieveFromKeychain(key: "swsPassword") {
            self.password = key
        }
        if let key = keychainManager.retrieveFromKeychain(key: aiAccessTokenKey) {
            self.accessToken = key
        }
// END LOAD CLIENT SECRET FROM KEYCHAIN ZONE ******************************

#if !os(macOS)
// BEGIN TERM / APP COLOR LOAD FROM DISK ZONE ******************************
        if let colorKey = UserDefaults.standard.string(forKey: "buttonColor") {
            self.buttonColor = Color(rawValue:colorKey) ?? .accentColor
        }
        else {
            self.buttonColor = .accentColor
        }

        if let colorKey = UserDefaults.standard.string(forKey: "backgroundColor") {
#if !os(tvOS)

            self.backgroundColor =  Color(rawValue:colorKey) ?? Color(UIColor.systemBackground)
            #else
            self.backgroundColor =  Color(rawValue:colorKey) ?? Color(UIColor.black)

            #endif
        }
        else {
#if !os(tvOS)

            self.backgroundColor =  Color(UIColor.systemBackground)
            #else
            self.backgroundColor =  Color(UIColor.black)

            #endif
        }

        if let colorKey = UserDefaults.standard.string(forKey: "appTextColor") {
            self.appTextColor =  Color(rawValue:colorKey) ?? .primary
        }
        else {
            self.appTextColor = .primary
        }
#else
        self.buttonColor = .green
        self.backgroundColor = .gray
        self.appTextColor = .primary
#endif

// BEGIN SUB ZONE FOR LOADING TERM / CHAT / SRC COLORS FROM DISK ******************************
        if UserDefaults.standard.double(forKey: "fontSizeSrcEditor") != 0 {
            self.fontSizeSrcEditor = UserDefaults.standard.double(forKey: "fontSizeSrcEditor")
        }
        else {
            self.fontSizeSrcEditor = defaultSourceEditorFontSize
        }
#if !os(macOS)
        if let colorKey = UserDefaults.standard.string(forKey: "plainColorSrcEditor") {
            self.plainColorSrcEditor =  Color(rawValue:colorKey) ?? .white
        }
        else {
            self.plainColorSrcEditor = .white
        }
        let defautColornumberColor = Color(red: 116/255, green: 109/255, blue: 176/255)
        if let colorKey = UserDefaults.standard.string(forKey: "numberColorSrcEditor") {
            self.numberColorSrcEditor =  Color(rawValue:colorKey) ?? defautColornumberColor
        }
        else {
            self.numberColorSrcEditor = defautColornumberColor
        }
        let defaultStringColor = Color(red: 211/255, green: 35/255, blue: 46/255)
        if let colorKey = UserDefaults.standard.string(forKey: "stringColorSrcEditor") {
            self.stringColorSrcEditor =  Color(rawValue:colorKey) ?? defaultStringColor
        }
        else {
            self.stringColorSrcEditor = defaultStringColor
        }

        let defaultIdentifierColor = Color(red: 20/255, green: 156/255, blue: 146/255)
        if let colorKey = UserDefaults.standard.string(forKey: "identifierColorSrcEditor") {
            self.identifierColorSrcEditor =  Color(rawValue:colorKey) ?? defaultIdentifierColor
        }
        else {
            self.identifierColorSrcEditor = defaultIdentifierColor
        }
        let defaultKeywordColor = Color(red: 215/255, green: 0, blue: 143/255)
        if let colorKey = UserDefaults.standard.string(forKey: "keywordColorSrcEditor") {
            self.keywordColorSrcEditor =  Color(rawValue:colorKey) ?? defaultKeywordColor
        }
        else {
            self.keywordColorSrcEditor = defaultKeywordColor
        }
        let defaultCommentColor = Color(red: 69.0/255.0, green: 187.0/255.0, blue: 62.0/255.0)
        if let colorKey = UserDefaults.standard.string(forKey: "commentColorSrceEditor") {
            self.commentColorSrceEditor =  Color(rawValue:colorKey) ?? defaultCommentColor
        }
        else {
            self.commentColorSrceEditor = defaultCommentColor
        }
        let defaultEditorPlaceholderColor = Color(red: 31/255.0, green: 32/255, blue: 41/255)
        if let colorKey = UserDefaults.standard.string(forKey: "editorPlaceholderColorSrcEditor") {
            self.editorPlaceholderColorSrcEditor =  Color(rawValue:colorKey) ?? defaultEditorPlaceholderColor
        }
        else {
            self.editorPlaceholderColorSrcEditor = defaultEditorPlaceholderColor
        }
        let defaultBackgroundColorSrcEditor = Color(red: 31/255.0, green: 32/255, blue: 41/255)
        if let colorKey = UserDefaults.standard.string(forKey: "backgroundColorSrcEditor") {
            self.backgroundColorSrcEditor =  Color(rawValue:colorKey) ?? defaultBackgroundColorSrcEditor
        }
        else {
            self.backgroundColorSrcEditor = defaultBackgroundColorSrcEditor
        }

        let defaultlineNumbersColorSrcEditor = Color( red: 100/255, green: 100/255, blue: 100/255)
        if let colorKey = UserDefaults.standard.string(forKey: "lineNumbersColorSrcEditor") {
            self.lineNumbersColorSrcEditor =  Color(rawValue:colorKey) ?? defaultlineNumbersColorSrcEditor
        }
        else {
            self.lineNumbersColorSrcEditor = defaultlineNumbersColorSrcEditor
        }
#else
        self.fontSizeSrcEditor = 13.666
        self.plainColorSrcEditor = .black
        self.numberColorSrcEditor = .white
        self.stringColorSrcEditor = .green
        self.identifierColorSrcEditor = .gray
        self.keywordColorSrcEditor = .gray
        self.commentColorSrceEditor = .gray
        self.editorPlaceholderColorSrcEditor = .gray
        self.backgroundColorSrcEditor = .gray
        self.lineNumbersColorSrcEditor = .gray
#endif
// END SUB ZONE FOR LOADING  TERM / CHAT / SRC EDITOR COLORS FROM DISK ******************************
// END COLOR LOAD FROM DISK ZONE ******************************

// BEGIN AUDIO SETTING LOAD ZONE FROM DISK
        self.duckingAudio = UserDefaults.standard.bool(forKey: "duckingAudio")
        self.voiceOutputEnabled = UserDefaults.standard.bool(forKey: "voiceOutputEnabled")
        self.voiceOutputSavedName = UserDefaults.standard.string(forKey: "savedVoiceName") ?? ""
        configureAudioSession()
        DispatchQueue.main.async {
            self.configureAudioSession()
        }
// END AUDIO SETTING LOAD ZONE FROM DISK

// START LOADING SAVED GIT REPOS LOAD ZONE FROM DISK
        refreshDocuments()
// END LOADING SAVED GIT REPOS LOAD ZONE FROM DISK

// START LOADING SAVED CONVO ZONE FROM DISK
        DispatchQueue.main.async {
            if let convos = self.retrieveConversationContentFromDisk(forKey: jsonFileName) {
                self.conversations = convos
            }
        }
// END LOADING SAVED CONVO ZONE FROM DISK

    }

    func currentGitRepoKey() -> String {
        "\(gitUser)\(SettingsViewModel.gitKeySeparator)\(gitRepo)\(SettingsViewModel.gitKeySeparator)\(gitBranch)"
    }
    static let gitKeySeparator = "-sws-"

    func refreshDocuments() {

// IF APP SANDBOX IS DISABLED ,
//#if !targetEnvironment(macCatalyst)

        let fileURL = getDocumentsDirectory()
        DispatchQueue.global(qos: .default).async {
            let files = getFiles(in: fileURL)
            DispatchQueue.main.async {
                self.root = RepoFile(name: fileRootName, url: fileURL, isDirectory: true, children: files)
            }
        }
//#endif
    }

    // START THEME ZONE

    func applyTheme(theme: AppTheme) {
#if os(macOS)
//        switch theme {
//        case .deepSpace:
//            appTextColor = Colorv(hex: 0xF5FFFA, alpha: 1)
//            buttonColor = Color(hex: 0x76D7EA, alpha: 1)
//            backgroundColor = Color(hex: 0x008CB4, alpha: 1)
//            plainColorSrcEditor = Color(hex: 0xBBD2D1, alpha: 1)
//            numberColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
//            stringColorSrcEditor =  Color(hex: 0xC1D82F, alpha: 1)
//            identifierColorSrcEditor = Color(hex: 0x188BC2, alpha: 1)
//            keywordColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
//            commentColorSrceEditor =  Color(hex: 0xE2062C, alpha: 1)
//            editorPlaceholderColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
//            backgroundColorSrcEditor = Color(hex: 0x232C33, alpha: 1)
//            lineNumbersColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
//
//        case .hacker:
//            appTextColor = Color(hex: 0xF5FFFA, alpha: 1) // FIND A NEW COLOR
//            buttonColor = Color(hex: 0x5F7D8E, alpha: 1)
//            backgroundColor = Color(hex: 0x2C3539, alpha: 1)
//            plainColorSrcEditor = Color(hex: 0xF5F5F5, alpha: 1)
//            numberColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1)
//            stringColorSrcEditor =  Color(hex: 0xCCFF00, alpha: 1) // FIND A NEW COLOR
//            identifierColorSrcEditor = Color(hex: 0x006B3C, alpha: 1)
//            keywordColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
//            commentColorSrceEditor =  Color(hex: 0x808080, alpha: 1)
//            editorPlaceholderColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
//            backgroundColorSrcEditor = Color(hex: 0x1A2421, alpha: 1)
//            lineNumbersColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
//        }

        #else
        switch theme {
        case .deepSpace:
            appTextColor = Color(hex: 0xF5FFFA, alpha: 1)
            buttonColor = Color(hex: 0x76D7EA, alpha: 1)
            backgroundColor = Color(hex: 0x008CB4, alpha: 1)
            plainColorSrcEditor = Color(hex: 0xBBD2D1, alpha: 1)
            numberColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
            stringColorSrcEditor =  Color(hex: 0xC1D82F, alpha: 1)
            identifierColorSrcEditor = Color(hex: 0x188BC2, alpha: 1)
            keywordColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
            commentColorSrceEditor =  Color(hex: 0xE2062C, alpha: 1)
            editorPlaceholderColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
            backgroundColorSrcEditor = Color(hex: 0x232C33, alpha: 1)
            lineNumbersColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR

        case .hacker:
            appTextColor = Color(hex: 0xF5FFFA, alpha: 1) // FIND A NEW COLOR
            buttonColor = Color(hex: 0x5F7D8E, alpha: 1)
            backgroundColor = Color(hex: 0x2C3539, alpha: 1)
            plainColorSrcEditor = Color(hex: 0xF5F5F5, alpha: 1)
            numberColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1)
            stringColorSrcEditor =  Color(hex: 0xCCFF00, alpha: 1) // FIND A NEW COLOR
            identifierColorSrcEditor = Color(hex: 0x006B3C, alpha: 1)
            keywordColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
            commentColorSrceEditor =  Color(hex: 0x808080, alpha: 1)
            editorPlaceholderColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
            backgroundColorSrcEditor = Color(hex: 0x1A2421, alpha: 1)
            lineNumbersColorSrcEditor = Color(hex: 0xC1D82F, alpha: 1) // FIND A NEW COLOR
        }
#endif
    }
}

// END THEME ZONE

enum AppTheme {
    case deepSpace
    case hacker
}
// CEREPROC VOICE ZONE
// Mac OS Cereproc voices for LogicSage for Mac cmd line voices - not streamed to device. LogicSage acts as remote for this if you have your headphones hooked up to your mac and
// are using muliple iOS devices for screens, etc.
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
// END CEREPROC VOICE ZONE
