//
//  SettingsViewModel.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI
import Combine
import StoreKit



public class SettingsViewModel: ObservableObject {

    public static let shared = SettingsViewModel()

    let keychainManager = KeychainManager()

// BEGIN TERMINAL ZONE **************************************************************************************
    func logText(_ text: String, terminator: String = "\n") {
        consoleManagerText.append(text)
        consoleManagerText.append(terminator)
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
#if !os(macOS)
    @Published var unstagedFileChanges = [FileChange]()
    @Published var stagedFileChanges = [FileChange]()
#endif
    @Published var isLoading: Bool = false
    var cancellable: AnyCancellable?

    @Published var hasAcceptedMicrophone = false

    @Published var showAllColorSettings: Bool = false

    @Published var showSourceEditorColorSettings: Bool = false
    @Published var showSizeSliders: Bool = false
    @Published var repoSettingsShown: Bool = false

    @Published var downloadProgress: Double = 0.0
    @Published var unzipProgress: Double = 0.0
    @Published var forkProgress: Double = 0.0

    @Published var ipAddress: String = ""
    @Published var port: String = ""

    @Published var showAudioSettings: Bool = false
    @AppStorage("autoCorrect") var autoCorrect: Bool = true
    @AppStorage("defaultURL") var defaultURL = "https://"
    @AppStorage("chatUpdateInterval") var chatUpdateInterval: Double = 0.5

    @Published var initalAnim: Bool = false

    func doDiscover() {
        serviceDiscovery?.startDiscovering()
    }

// END SAVED UI SETTINGS ZONE **************************************************************************************

// BEGIN STREAMING IMAGES/ZIPZ OVER WEBSOCKET ZONE *****************************************************************
#if !os(macOS)
    @Published var receivedImageData: Data? = nil {
        didSet {
            recieveImageData(recievedImageData: receivedImageData)
        }
    }
    @Published var actualReceivedImage: UIImage?
    @Published var receivedWallpaperFileName: String?
    @Published var receivedWallpaperFileSize: Int?

    @Published var receivedSimulatorFrameData: Data? = nil {
        didSet {
            actualReceivedSimulatorFrame = UIImage(data: receivedSimulatorFrameData  ?? Data())

            if oldValue == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
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
    @Published var voiceOutputenabled = false
    @AppStorage("voiceOutputEnabled") var voiceOutputenabledUserDefault = false
    @AppStorage("selectedVoiceIndex") var selectedVoiceIndexSaved: Int = 0 {
        didSet {
            if !installedVoices.isEmpty && selectedVoiceIndexSaved < installedVoices.count {
                selectedVoice = installedVoices[selectedVoiceIndexSaved]
            }
        }
    }
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

    @AppStorage("userName") var userName = "chris" {
        didSet {
        }
    }
    @Published var password = "swiftsage" {
        didSet {
            if keychainManager.saveToKeychain(key: "swsPassword", value: password) {
                print("Key saved successfully")
            } else {
                print("Error saving key")
            }
        }
    }

    @AppStorage("openAIModel") var openAIModel = defaultGPTModel

    @Published var openAIKey = "" {
        didSet {
            let trimmedKey = openAIKey.trimmingCharacters(in: .whitespacesAndNewlines)
            if keychainManager.saveToKeychain(key:aiKeyKey, value: trimmedKey) {
                 print("openAIKey saved successfully")
                GPT.shared.resetOpenAI()
            } else {
                print("Error saving ai key")
            }
        }
    }
    @Published var ghaPat = ""  {
        didSet {
            let trimmedKey = ghaPat.trimmingCharacters(in: .whitespacesAndNewlines)

            if keychainManager.saveToKeychain(key: ghaKeyKey, value: trimmedKey) {
                print("ghPat saved successfully")
            } else {
                print("Error saving gha pat")
            }
        }

    }
    @AppStorage("yourGitUser") var yourGitUser = "\(defaultYourGithubUsername)"
    @AppStorage("gitUser") var gitUser = "\(defaultOwner)"
    // It's not okay to only allow lowercase. The forking API is case-sensitive with repos so we must be vigilant and use the same case when working with Github. OK?
    @AppStorage("gitRepo") var gitRepo = "\(defaultRepo)"
    @AppStorage("gitBranch") var gitBranch = "\(defaultBranch)"
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
    @Published var targetName: String = "SwiftSageiOS"
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
                return logD("no review today")
            }

            print("SKStoreReviewController.requestReview")
            SKStoreReviewController.requestReview()
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
        if let key = keychainManager.retrieveFromKeychain(key: ghaKeyKey) {

            self.ghaPat = key
            // print("Retrieved value: ghaPat")
        } else {
            //         print("Error retrieving ghaPat == reset")
            //           keychainManager.saveToKeychain(key:ghaKeyKey, value: "")
        }
        if let key = keychainManager.retrieveFromKeychain(key: "swsPassword") {

            self.password = key
            //          print("Retrieved value: \(ghaPat)")
            //  print("Retrieved value: swsPassword")

        } else {
            //         print("Error retrieving ghaPat == reset")
            //           keychainManager.saveToKeychain(key:ghaKeyKey, value: "")
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
            self.backgroundColor =  Color(rawValue:colorKey) ?? Color(UIColor.systemBackground)
        }
        else {
            self.backgroundColor =  Color(UIColor.systemBackground)
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
        voiceOutputenabled = voiceOutputenabledUserDefault

        if UserDefaults.standard.integer(forKey: "selectedVoiceIndex") != 0 {
            self.selectedVoiceIndexSaved = UserDefaults.standard.integer(forKey: "selectedVoiceIndex")
        }
        else {
            self.selectedVoiceIndexSaved = 0
        }
        configureAudioSession()
        DispatchQueue.main.async {
            if UserDefaults.standard.integer(forKey: "selectedVoiceIndex") != 0 {
                self.selectedVoiceIndexSaved = UserDefaults.standard.integer(forKey: "selectedVoiceIndex")

            }
            else {
                self.selectedVoiceIndexSaved = 0
            }
            self.configureAudioSession()
        }
        
        // END AUDIO SETTING LOAD ZONE FROM DISK

        // START LOADING SAVED GIT REPOS LOAD ZONE FROM DISK
        refreshDocuments()
        // END LOADING SAVED GIT REPOS LOAD ZONE FROM DISK

        DispatchQueue.main.async {
            if let convos = self.retrieveConversationContentFromDisk(forKey: jsonFileName) {
                self.conversations = convos
            }
        }
    }

    func currentGitRepoKey() -> String {
        "\(gitUser)\(SettingsViewModel.gitKeySeparator)\(gitRepo)\(SettingsViewModel.gitKeySeparator)\(gitBranch)"
    }
    static let gitKeySeparator = "-sws-"

    func refreshDocuments() {
        let fileURL = getDocumentsDirectory()
        DispatchQueue.global(qos: .default).async {
            let files = getFiles(in: fileURL)
            DispatchQueue.main.async {
                self.root = RepoFile(name: fileRootName, url: fileURL, isDirectory: true, children: files)
            }
        }
    }

    // START THEME ZONE

    func applyTheme(theme: AppTheme) {
#if !os(macOS)
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
// Mac OS Cereproc voices for LogicSage for Mac cmd line voices - not streamed to device. SwiftSageiOS acts as remote for this if you have your headphones hooked up to your mac and
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
