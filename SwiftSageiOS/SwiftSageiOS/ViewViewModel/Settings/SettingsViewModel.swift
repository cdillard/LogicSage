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

let defaultTerminalFontSize: Double = 13.666
let defaultCommandButtonSize: Double = 28
let defaultToolbarButtonScale: Double = 0.27
let defaultHandleSize: Double = 28
let defaultSourceEditorFontSize: Double = 12.666

let defaultOwner = "cdillard"
let defaultRepo = "LogicSage"
let defaultBranch = "main"

let defaultYourGithubUsername = "cdillard"

let jsonFileName = "conversations"


// TODO MAKE SURE ITS OKAY TO UP THIS SO MUCH
let STRING_LIMIT = 150000

// TODO BEFORE RELEASE: PROD BUNDLE ID
// TODO USE BUILT IN BundleID var.
let bundleID = "com.chrisdillard.SwiftSage"


public class SettingsViewModel: ObservableObject {
    func logoAscii5() -> String {
        """
        ┃┃╱╱╭━━┳━━┳┳━━┫╰━━┳━━┳━━┳━━╮
        ┃┃╱╭┫╭╮┃╭╮┣┫╭━┻━━╮┃╭╮┃╭╮┃┃━┫
        ┃╰━╯┃╰╯┃╰╯┃┃╰━┫╰━╯┃╭╮┃╰╯┃┃━┫
        ╰━━━┻━━┻━╮┣┻━━┻━━━┻╯╰┻━╮┣━━╯
        client: \(currentMode == .mobile ? "mobile" : "computer"): model: \(openAIModel).
        """
    }
    static let link = URL(string: "https://apps.apple.com/us/app/logicsage/id6448485441")!

    public static let shared = SettingsViewModel()

    @State private var lastConsoleUpdate: Date?
    func logText(_ text: String, terminator: String = "\n") {
        let now = Date()
        if lastConsoleUpdate == nil ||  now.timeIntervalSince(self.lastConsoleUpdate ?? Date()) >= 4.666 {
            self.lastConsoleUpdate = now
            DispatchQueue.main.async {
                self.consoleManagerText.append(text)
                self.consoleManagerText.append(terminator)
            }
        }
    }
    @Published var consoleManagerText: String = ""

    var latestWindowManager: WindowManager?

    var serviceDiscovery: ServiceDiscovery?
    func doDiscover() {
        serviceDiscovery?.startDiscovering()
    }
    @AppStorage("savedUserAvatar") var savedUserAvatar: String = "👨"
    @AppStorage("savedBotAvatar") var savedBotAvatar: String = "🤖"

    // BEGIN SAVED UI SETTINGS ZONE **************************************************************************************
    let keychainManager = KeychainManager()

    @Published var root: RepoFile?

    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true

    @Published var changes = [ChangeRow]()
#if !os(macOS)
    @Published var unstagedFileChanges = [FileChange]()
    @Published var stagedFileChanges = [FileChange]()
#endif
    @Published var isLoading: Bool = false
    var cancellable: AnyCancellable?

    @Published var commandMode: EntryMode = .commandBar

//    @AppStorage("savedText") var multiLineText = ""

    @Published var hasAcceptedMicrophone = false
    @AppStorage("device") var currentMode: Device = .mobile

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


    @Published var initalAnim: Bool = false
    
// END SAVED UI SETTINGS ZONE **************************************************************************************

// BEGIN STREAMING IMAGES OVER WEBSOCKET ZONE *****************************************************************
#if !os(macOS)
    @Published var receivedImageData: Data? = nil {
        didSet {
            actualReceivedImage = UIImage(data: receivedImageData  ?? Data())

            // received
            if let  receivedWallpaperFileName, let receivedImageData {
                let receivedWallpaperFileName = receivedWallpaperFileName.replacingOccurrences(of: " ", with: "%20")
                logD("REC -- going to write -- \(receivedWallpaperFileName) c: \(receivedWallpaperFileSize ?? 0)")


                do {
                    try FileManager.default.createDirectory(at: getDocumentsDirectory().appendingPathComponent("LogicSageWallpapers"), withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    logD("fail to create LogicSageWallpapers dir")
                }

                let fileURL = getDocumentsDirectory().appendingPathComponent("LogicSageWallpapers/\(receivedWallpaperFileName)")


                do {
                    try FileManager.default.removeItem(at: fileURL)
                }
                catch {
                    logD("didnt rmv or exist old m")

                }

                do {
                    try receivedImageData.write(to: fileURL)

                    logD("Successfully wrote out wallpaper  \(fileURL)")

                }
                catch {
                    logD("Failed to write out rec wallpaper")

                }


                self.receivedWallpaperFileName = nil
                receivedWallpaperFileSize = nil
                
                refreshDocuments()
            }
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
#if !os(macOS)
                    self.latestWindowManager?.addWindow(windowType: .simulator, frame: defSize, zIndex: 0)
#endif
                }
            }
        }
    }
    @Published var actualReceivedSimulatorFrame: UIImage?

    @Published var receivedWorkspaceData: Data? = nil {
        didSet {
            if let receivedWorkspaceData {
                logD("received workspace data of size = \(receivedWorkspaceData.count)")
                let fileURL = getDocumentsDirectory().appendingPathComponent("workspace_archive.zip")

                do {
                    try FileManager.default.removeItem(at: fileURL)

                }
                catch {
                    logD("fil enot exist or deketed")
                }
                do {
                    try receivedWorkspaceData.write(to: fileURL)

                    logD("wrote file \(fileURL) out successfully")
                    let existingExtraction = getDocumentsDirectory().appendingPathComponent("Workspace")

                    do {
                        try FileManager.default.removeItem(at:  existingExtraction)
                    }
                    catch {
                        logD("did not delete or didn't exist old REPO")
                    }
                    let myProgress = Progress()
                    do {
                        // Workspace is already included in this folder.
                        try FileManager.default.unzipItem(at: fileURL, to: getDocumentsDirectory(), progress: myProgress)

                        logD("unzipped to \(existingExtraction) successfully")

                        do {
                            try FileManager.default.removeItem(at:  fileURL)
                        }
                        catch {
                            print("did not delete or didn't exist old REPO")
                        }

                        self.refreshDocuments()
                    }
                    catch {
                        logD("failed to unzip workspace")

                    }
                }
                catch {
                    logD("failed to write out zip")
                }

            }
        }
    }

#endif
// END STREAMING IMAGES OVER WEBSOCKET ZONE *****************************************************************

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
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Published var recognizedText: String = ""
// END SAVED AUDIO SETTINGS ZONE *****************************************************************

// BEGIN SAVED SIZES ZONE **************************************************************************************
    // TOOL BAR BUTOTN SIZE
    @AppStorage("savedButtonSize") var buttonScale: Double = defaultToolbarButtonScale
    // COMMAND BUTTON SIZE
    @AppStorage("commandButtonFontSize")var commandButtonFontSize: Double = defaultCommandButtonSize
    @AppStorage("cornerHandleSize")var cornerHandleSize: Double = defaultHandleSize
    @AppStorage("textSize") var textSize: Double = defaultTerminalFontSize {
        didSet {
            if textSize != 0 {
                UserDefaults.standard.set(textSize, forKey: "textSize")
            }
            else {
                logD("failed to set terminal text size")
            }

        }
    }
// END SAVED SIZES ZONE ********************************************************************************************

    // BEGIN SAVED COLORS ZONE **************************************************************************************
//    @Published var terminalBackgroundColor: Color {
//        didSet {
//#if !os(macOS)
//            UserDefaults.standard.set(terminalBackgroundColor.rawValue , forKey: "terminalBackgroundColor")
//#endif
//        }
//    }
//    @Published var terminalTextColor: Color {
//        didSet {
//#if !os(macOS)
//            UserDefaults.standard.set(terminalTextColor.rawValue , forKey: "terminalTextColor")
//#endif
//        }
//    }

    @Published var appTextColor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(appTextColor.rawValue, forKey: "appTextColor")
#endif
        }
    }
    @Published var buttonColor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(buttonColor.rawValue , forKey: "buttonColor")
#endif
        }
    }
    @Published var backgroundColor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(backgroundColor.rawValue, forKey: "backgroundColor")
#endif
        }
    }

    // BEGIN SUB ZONE FOR SRC EDITOR COLORS ********************************************
    @AppStorage("fontSizeSrcEditor") var fontSizeSrcEditor: Double = defaultSourceEditorFontSize
    @Published var plainColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(plainColorSrcEditor.rawValue , forKey: "plainColorSrcEditor")
#endif
        }
    }
    @Published var numberColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(numberColorSrcEditor.rawValue , forKey: "numberColorSrcEditor")
#endif
        }
    }
    @Published var stringColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(stringColorSrcEditor.rawValue , forKey: "stringColorSrcEditor")
#endif
        }
    }
    @Published var identifierColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(identifierColorSrcEditor.rawValue, forKey: "identifierColorSrcEditor")
#endif
        }
    }
    @Published var keywordColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(keywordColorSrcEditor.rawValue , forKey: "keywordColorSrcEditor")
#endif
        }
    }
    @Published var commentColorSrceEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(commentColorSrceEditor.rawValue , forKey: "commentColorSrceEditor")
#endif
        }
    }
    @Published var editorPlaceholderColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(editorPlaceholderColorSrcEditor.rawValue , forKey: "editorPlaceholderColorSrcEditor")
#endif
        }
    }
    @Published var backgroundColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(backgroundColorSrcEditor.rawValue, forKey: "backgroundColorSrcEditor")
#endif
        }
    }
    @Published var lineNumbersColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(lineNumbersColorSrcEditor.rawValue, forKey: "lineNumbersColorSrcEditor")
#endif
        }
    }
    // END SUB ZONE FOR SRC EDITOR COLORS********************************************
    // END SAVED COLORS ZONE **************************************************************************************

    // BEGIN CLIENT API KEYS ZONE ******************************************************************************
    // TODO: React to user name and password change
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
    let aiKeyKey = "openAIKeySec"
    let ghaKeyKey = "ghaPat"

    @AppStorage("openAIModel") var openAIModel = defaultGPTModel

    @Published var openAIKey = "" {
        didSet {
            if keychainManager.saveToKeychain(key:aiKeyKey, value: openAIKey) {
                // print("openAIKey saved successfully")
            } else {
                print("Error saving ai key")
            }
        }
    }
    @Published var ghaPat = ""  {
        didSet {
            if keychainManager.saveToKeychain(key: ghaKeyKey, value: ghaPat) {
                //print("ghPat saved successfully")
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
    @Published var conversations: [Conversation] = [] {
        didSet {
            //logD("new convo state:\n\(conversations)")
        }
    }
    @Published var conversationErrors: [Conversation.ID: Error] = [:] {
        didSet {
            if !conversationErrors.isEmpty {
                //logD("new convo error state = \(conversationErrors)")
            }
        }
    }
    @AppStorage("completedMessages") var completedMessages = 0

    func renameConvo(_ convoId: Conversation.ID, newName: String) {

        logD("rename convo id = \(convoId) to \(newName)")
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return
        }
        SettingsViewModel.shared.conversations[conversationIndex].name = newName

        saveConvosToDisk()
    }
    func saveConvosToDisk() {
        saveConversationContentToDisk(object: conversations, forKey: jsonFileName)

    }
    func appendMessageToConvoIndex(index: Int, message: Message) async {
        conversations[index].messages.append(message)
    }
    func setMessageAtConvoIndex(index: Int, existingMessageIndex: Int, message: Message) async {
        conversations[index].messages[existingMessageIndex] = message
    }
    func nilOutConversationErrorsAt(convoId: Conversation.ID) async {
        conversationErrors[convoId] = nil
    }
    func setConversationError(convoId: Conversation.ID, error: Error) async {
        conversationErrors[convoId] = error
    }
    let idProvider: () -> String
    let dateProvider: () -> Date

    func sendChatText(_ convoID: Conversation.ID, chatText: String) {
        gptCommand(conversationId: convoID, input: chatText)
    }
    func createConversation() -> Conversation.ID {
        let conversation = Conversation(id: idProvider(), messages: [])
        conversations.append(conversation)
        logD("created new convo = \(conversation.id)")
        return conversation.id
    }
    func deleteConversation(_ conversationId: Conversation.ID) {
        conversations.removeAll(where: { $0.id == conversationId })

        latestWindowManager?.removeWindowsWithConvoId(convoID: conversationId)
        saveConvosToDisk()
    }
    func createAndOpenNewConvo() {
        let convo = createConversation()

        saveConvosToDisk()

        openConversation(convo)
    }
    func openConversation(_ convoId: Conversation.ID) {
        latestWindowManager?.removeWindowsWithConvoId(convoID: convoId)

#if !os(macOS)
        latestWindowManager?.addWindow(windowType: .chat, frame: defChatSize, zIndex: 0, url: defaultURL, convoId: convoId)
#endif
    }
    func createAndOpenServerChat() {

        openConversation(Conversation.ID(-1))
    }
    func saveConversationContentToDisk(object: [Conversation], forKey key: String) {

       let encoder = JSONEncoder()
       do {
           let encodedData = try encoder.encode(object)

           saveJSONData(encodedData, filename: "\(key).json")
       }
       catch {
           logD("failed w error = \(error)")
       }
    }
    func retrieveConversationContentFromDisk(forKey key: String) -> [Conversation]? {

       if let savedData = loadJSONData(filename: "\(key).json") {
           do {
               let decoder = JSONDecoder()
               return try decoder.decode([Conversation].self, from: savedData)
           }
           catch {
               logD("failed w error = \(error)")
           }
       }
       return nil
    }
    func loadJSONData(filename: String) -> Data? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            logD("Failed to read JSON data: \(error.localizedDescription)")
            return nil
        }
    }
    func saveJSONData(_ data: Data, filename: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
        } catch {
            logD("Failed to write JSON data: \(error.localizedDescription)")
        }
    }

    func convoText(_ newConversations: [Conversation], window: WindowInfo?) -> String {
        var retString  = ""
        if let conversation = newConversations.first(where: { $0.id == window?.convoId }) {
            for msg in conversation.messages {
                retString += "\(msg.role == .user ? savedUserAvatar : savedBotAvatar):\n\(msg.content.trimmingCharacters(in: .whitespacesAndNewlines))\n"
            }

        }
        return retString
    }

    func convoName(_ convoId: Conversation.ID) -> String {
        if let conversation = conversations.first(where: { $0.id == convoId }) {
            return conversation.name ?? String(convoId.prefix(4))
        }

        return "Term"
    }

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
            let newCompletionMsgs = self.completedMessages
            logD("\(newCompletionMsgs) % 7 = will review")

            guard newCompletionMsgs % 7 == 0 else {
                return logD("no review today")
            }

            logD("SKStoreReviewController.requestReview")
            SKStoreReviewController.requestReview()
        }
    }
// END STOREKIT ZONE ***********************************************************************

    init() {

        self.idProvider = {
            UUID().uuidString
        }
        self.dateProvider = Date.init

        // BEGIN SIZE SETTING LOAD ZONE FROM DISK

        if UserDefaults.standard.double(forKey: "textSize") != 0 {
            self.textSize = CGFloat(UserDefaults.standard.double(forKey: "textSize"))
        }
        else {
            self.textSize = defaultTerminalFontSize
        }

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
//        if let colorKey = UserDefaults.standard.string(forKey: "terminalBackgroundColor") {
//
//            self.terminalBackgroundColor =  Color(rawValue:colorKey) ?? .black
//        }
//        else {
//            self.terminalBackgroundColor = .black
//        }
//
//        if let colorKey = UserDefaults.standard.string(forKey: "terminalTextColor") {
//
//            self.terminalTextColor =  Color(rawValue:colorKey) ?? .white
//        }
//        else {
//            self.terminalTextColor = .white
//        }

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
//        self.terminalBackgroundColor = .black
//        self.terminalTextColor = .white
        self.buttonColor = .green
        self.backgroundColor = .gray
        self.appTextColor = .primary
#endif

        // BEGIN SUB ZONE FOR LOADING SRC EDITOR COLORS FROM DISK\

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
        // END SUB ZONE FOR LOADING SRC EDITOR COLORS FROM DISK\


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

    enum Device: Int {
        case mobile, computer
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
//            terminalBackgroundColor = Color(hex: 0x4A646C, alpha: 1)
//            terminalTextColor = Color(hex: 0xF5FFFA, alpha: 1)
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

//            terminalBackgroundColor = Color(hex: 0x000000, alpha: 1)
//            terminalTextColor = Color(hex: 0x39FF14, alpha: 1)
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
enum AppTheme {
    case deepSpace
    case hacker
}

// END THEME ZONE


// CEREPROC VOICE ZONE
// Mac OS Cereproc voices for Sw-S: cmd line voices - not streamed to device. SwiftSageiOS acts as remote for this if you have your headphones hooked up to your mac and
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
