//
//  SettingsViewModel.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI
import Combine
let defaultTerminalFontSize: CGFloat = 18.666
let defaultCommandButtonSize: CGFloat = 38
let defaultToolbarButtonScale: CGFloat = 0.4
let defaultHandleSize: Double = 28
let defaultSourceEditorFontSize: CGFloat = 13.666

let defaultOwner = "cdillard"
let defaultRepo = "SwiftSage"
let defaultBranch = "main"

public class SettingsViewModel: ObservableObject {

    public static let shared = SettingsViewModel()

    // BEGIN SAVED UI SETTINGS ZONE **************************************************************************************
    let keychainManager = KeychainManager()

    @Published var rootFiles: [GitHubContent] = []
    @Published var isLoading: Bool = false
    var cancellable: AnyCancellable?

    @Published var isInputViewShown = false
    @Published var commandMode: EntryMode = .commandBar

    @AppStorage("savedText") var multiLineText = ""

    @Published var hasAcceptedMicrophone = false
    @AppStorage("device") var currentMode: Device = .mobile

    @Published var showAddView = false
    // DONT AUTO SHOW THE STUFF
    @Published var showInstructions: Bool = false //!hasSeenInstructions()
    @Published var showHelp: Bool = false
        @Published var showSourceEditorColorSettings: Bool = false

    // 📙
    @AppStorage("autoCorrect") var autoCorrect: Bool = true

    @AppStorage("defaultURL") var defaultURL = "https://"

#if !os(macOS)
    @Published var receivedImage: UIImage? = nil
    func updateImage(data: Data) {
        if let image = UIImage(data: data) {
            self.receivedImage = image
        } else {
            print("Failed to convert data to UIImage")
        }
    }
#endif

    // END SAVED UI SETTINGS ZONE **************************************************************************************

    // BEGIN SAVED AUDIO SETTINS ZONE *****************************************************************

    @Published var voiceOutputenabled = false
    @AppStorage("voiceOutputEnabled") var voiceOutputenabledUserDefault = false
    @AppStorage("selectedVoiceIndex") var selectedVoiceIndexSaved: Int = 0
    @AppStorage("duckingAudio") var duckingAudio = true

    // TODO
    // add the code for server
    @Published var serverVoiceOutputEnabled = false
    @Published var installedVoices = [VoicePair]()
    @Published var selectedVoice: VoicePair?
    @Published var isRecording = false
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Published var recognizedText: String = ""


    // END SAVED AUDIO SETTINGS ZONE *****************************************************************

    // BEGIN SAVED SIZES ZONE **************************************************************************************


    // TOOL BAR BUTOTN SIZE
    @AppStorage("savedButtonSize") var buttonScale: Double = defaultToolbarButtonScale {
        didSet {
            buttonScalerFloat = CGFloat(  buttonScale)
        }
    }
    @Published var buttonScalerFloat: CGFloat = defaultToolbarButtonScale

    // COMMAND BUTTON SIZE
    @AppStorage("commandButtonFontSize")var commandButtonFontSize: Double = defaultCommandButtonSize {
        didSet {
            commandButtonFontSizeFloat = CGFloat(  commandButtonFontSize)
        }
    }
    @Published var commandButtonFontSizeFloat: CGFloat = defaultCommandButtonSize


    @AppStorage("cornerHandleSize")var cornerHandleSize: Double = defaultHandleSize
    @AppStorage("middleHandleSize")var middleHandleSize: Double = defaultHandleSize


    @Published var textSize: CGFloat = defaultTerminalFontSize {
        didSet {
            if textSize != 0 {
                UserDefaults.standard.set(Float(textSize), forKey: "textSize")
            }
            else {
                print("failed to set terminal text size")

            }
#if !os(macOS)
            consoleManager.fontSize = self.textSize

            consoleManager.refreshAtributedText()
#endif

        }
    }

    // END SAVED SIZES ZONE ********************************************************************************************

    // BEGIN SAVED COLORS ZONE **************************************************************************************

    @Published var terminalBackgroundColor: Color {
        didSet {
#if !os(macOS)

     //       if let data =  {
            UserDefaults.standard.set(terminalBackgroundColor.rawValue , forKey: "terminalBackgroundColor")
            print("saved terminalBackgroundColor to userdefaults")
            consoleManager.updateLumaColor()

#endif
        }
    }
    @Published var terminalTextColor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(terminalTextColor.rawValue , forKey: "terminalTextColor")
            print("saved terminalTextColor to userdefaults")

            consoleManager.refreshAtributedText()
#endif

        }
    }
    @Published var buttonColor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(buttonColor.rawValue , forKey: "buttonColor")
            print("saved buttonColor to userdefaults")
#endif
        }
    }
    @Published var backgroundColor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(backgroundColor.rawValue, forKey: "backgroundColor")
            print("saved backgroundColor to userdefaults")
#endif
        }
    }


    // BEGIN SUB ZONE FOR SRC EDITOR COLORS ********************************************

    @AppStorage("fontSizeSrcEditor") var fontSizeSrcEditor: Double = defaultSourceEditorFontSize {
        didSet {
            sourceEditorFontSizeFloat = CGFloat(  fontSizeSrcEditor)
        }
    }
    @Published var sourceEditorFontSizeFloat: CGFloat = defaultSourceEditorFontSize


    @Published var plainColorSrcEditor: Color {
        didSet {
#if !os(macOS)

     //       if let data =  {
            UserDefaults.standard.set(plainColorSrcEditor.rawValue , forKey: "plainColorSrcEditor")
            print("saved plainColorSrcEditor to userdefaults")

#endif
        }
    }
    @Published var numberColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(numberColorSrcEditor.rawValue , forKey: "numberColorSrcEditor")
            print("saved numberColorSrcEditor to userdefaults")

#endif
        }
    }
    @Published var stringColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(stringColorSrcEditor.rawValue , forKey: "stringColorSrcEditor")
            print("saved stringColorSrcEditor to userdefaults")
#endif
        }
    }
    @Published var identifierColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(identifierColorSrcEditor.rawValue, forKey: "identifierColorSrcEditor")
            print("saved identifierColorSrcEditor to userdefaults")
#endif
        }
    }
    @Published var keywordColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(keywordColorSrcEditor.rawValue , forKey: "keywordColorSrcEditor")
            print("saved keywordColorSrcEditor to userdefaults")

#endif

        }
    }
    @Published var commentColorSrceEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(commentColorSrceEditor.rawValue , forKey: "commentColorSrceEditor")
            print("saved commentColorSrceEditor to userdefaults")

#endif

        }
    }
    @Published var editorPlaceholderColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(editorPlaceholderColorSrcEditor.rawValue , forKey: "editorPlaceholderColorSrcEditor")
            print("saved editorPlaceholderColorSrcEditor to userdefaults")
#endif
        }
    }
    @Published var backgroundColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(backgroundColorSrcEditor.rawValue, forKey: "backgroundColorSrcEditor")
            print("saved backgroundColorSrcEditor to userdefaults")
#endif
        }
    }
    @Published var lineNumbersColorSrcEditor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(lineNumbersColorSrcEditor.rawValue, forKey: "lineNumbersColorSrcEditor")
            print("saved lineNumbersColorSrcEditor to userdefaults")
#endif
        }
    }



    // END SUB ZONE FOR SRC EDITOR COLORS********************************************

    // END SAVED COLORS ZONE **************************************************************************************

    // BEGIN SAVED SECRETS ZONE **************************************************************************************


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

    @AppStorage("openAIModel") var openAIModel = "\(gptModel)"

    // CLIENT API KEYS
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

    @AppStorage("gitUser") var gitUser = "\(defaultOwner)"

    @AppStorage("gitRepo") var gitRepo = "\(defaultRepo)"

    @AppStorage("gitBranch") var gitBranch = "\(defaultBranch)"

    
    // END CLIENT APIS ZONE **************************************************************************************

    init() {
        // BEGIN SIZE SETTING LOAD ZONE FROM DISK

        if UserDefaults.standard.float(forKey: "textSize") != 0 {
            self.textSize = CGFloat(UserDefaults.standard.float(forKey: "textSize"))

        }
        else {
            self.textSize = defaultTerminalFontSize
        }

        if UserDefaults.standard.float(forKey: "savedButtonSize") != 0 {
            self.buttonScale = CGFloat(UserDefaults.standard.float(forKey: "savedButtonSize"))
            self.buttonScalerFloat = CGFloat(  CGFloat(UserDefaults.standard.float(forKey: "savedButtonSize")))
        }
        else {
            self.buttonScale = defaultToolbarButtonScale
            self.buttonScalerFloat = CGFloat(  defaultToolbarButtonScale)
        }
        if UserDefaults.standard.float(forKey: "commandButtonFontSize") != 0 {
            self.commandButtonFontSize = CGFloat(UserDefaults.standard.float(forKey: "commandButtonFontSize"))
            self.commandButtonFontSizeFloat = CGFloat(  CGFloat(UserDefaults.standard.float(forKey: "commandButtonFontSize")))

        }
        else {
            self.commandButtonFontSize = defaultCommandButtonSize
            self.commandButtonFontSizeFloat = CGFloat(  defaultCommandButtonSize)

        }
        // END SIZE SETTING LOAD ZONE FROM DISK


        // BEGIN LOAD CLIENT SECRET FROM KEYCHAIN ZONE ******************************

        if let key = keychainManager.retrieveFromKeychain(key: aiKeyKey) {

            self.openAIKey = key
            print("Retrieved value: aiKey")
        } else {
//            print("Error retrieving openAIKey")
//            keychainManager.saveToKeychain(key:openAIKey, value: "")

        }
        if let key = keychainManager.retrieveFromKeychain(key: ghaKeyKey) {

            self.ghaPat = key
            print("Retrieved value: ghaPat")
        } else {
   //         print("Error retrieving ghaPat == reset")
 //           keychainManager.saveToKeychain(key:ghaKeyKey, value: "")


        }
        if let key = keychainManager.retrieveFromKeychain(key: "swsPassword") {

            self.password = key
  //          print("Retrieved value: \(ghaPat)")
            print("Retrieved value: swsPassword")

        } else {
   //         print("Error retrieving ghaPat == reset")
 //           keychainManager.saveToKeychain(key:ghaKeyKey, value: "")


        }

        // END LOAD CLIENT SECRET FROM KEYCHAIN ZONE ******************************

#if !os(macOS)

        // BEGIN COLOR LOAD FROM DISK ZONE ******************************
        if let colorKey = UserDefaults.standard.string(forKey: "terminalBackgroundColor") {

            self.terminalBackgroundColor =  Color(rawValue:colorKey) ?? .black
        }
        else {
            self.terminalBackgroundColor = .black
        }
        if let colorKey = UserDefaults.standard.string(forKey: "terminalTextColor") {

            self.terminalTextColor =  Color(rawValue:colorKey) ?? .white
        }
        else {
            self.terminalTextColor = .white

        }

        if let colorKey = UserDefaults.standard.string(forKey: "buttonColor") {
            self.buttonColor = Color(rawValue:colorKey) ?? .green
        }
        else {
            self.buttonColor = .green
            
        }

        if let colorKey = UserDefaults.standard.string(forKey: "backgroundColor") {

            self.backgroundColor =  Color(rawValue:colorKey) ?? .gray
        }
        else {
            self.backgroundColor = .gray
        }
#else
        self.terminalBackgroundColor = .black
        self.terminalTextColor = .white
        self.buttonColor = .green
        self.backgroundColor = .gray

#endif

        // BEGIN SUB ZONE FOR LOADING SRC EDITOR COLORS FROM DISK\

        if UserDefaults.standard.float(forKey: "fontSizeSrcEditor") != 0 {
            self.fontSizeSrcEditor = CGFloat(UserDefaults.standard.float(forKey: "fontSizeSrcEditor"))
            self.sourceEditorFontSizeFloat = CGFloat(  CGFloat(UserDefaults.standard.float(forKey: "fontSizeSrcEditor")))


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
        self.sourceEditorFontSizeFloat = 13.666
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
        // END AUDIO SETTING LOAD ZONE FROM DISK


        // BEGIN LOAD SAVED GIT REPO
        let openRepoKey = "\(gitUser)/\(gitRepo)/\(gitBranch)"

        if let retrievedObject = retrieveGithubContentFromUserDefaults(forKey: openRepoKey) {
            self.rootFiles = retrievedObject.compactMap { $0 }

            print("Sucessfully restored open repo w/ rootFile count = \(self.rootFiles.count)")

            for file in self.rootFiles {
                print("Child count: \(file.children?.count ?? 0)")
            }

        } else {
            print("Failed to retrieve saved git repo...")
        }
        // END LOAD SAVED GIT REPO

    }

}

enum Device: Int {
    case mobile, computer
}

#if !os(macOS)


extension Color: RawRepresentable {

    public init?(rawValue: String) {

        guard let data = Data(base64Encoded: rawValue) else{
            self = .black
            return
        }

        do{
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        }catch{
            self = .black
        }

    }

    public var rawValue: String {

        do{
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()

        }catch{

            return ""

        }

    }

}
#endif


// Function to save a MyObject instance to UserDefaults
func saveGithubContentUserDefaults(object: [GitHubContent], forKey key: String) {
    let userDefaults = UserDefaults.standard

    // 2. Use JSONEncoder to encode your object into Data
    let encoder = JSONEncoder()
    do {
         let encodedData = try encoder.encode(object)
            // 3. Save the encoded data to UserDefaults
        userDefaults.set(encodedData, forKey: key)

    }
    catch {
        print("failed w error = \(error)")
    }
}
func retrieveGithubContentFromUserDefaults(forKey key: String) -> [GitHubContent]? {
    let userDefaults = UserDefaults.standard

    // 4. Retrieve the data from UserDefaults
    if let savedData = userDefaults.object(forKey: key) as? Data {
        do {

            // 5. Use JSONDecoder to decode the data back into your custom object
            let decoder = JSONDecoder()
            return try decoder.decode([GitHubContent].self, from: savedData)
        }
        catch {
            print("failed w error = \(error)")

        }
    }
    return nil
}
