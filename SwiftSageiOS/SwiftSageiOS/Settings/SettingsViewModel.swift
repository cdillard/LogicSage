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

let defaultOwner = "cdillard"
let defaultRepo = "SwiftSage"
let defaultBranch = "main"

class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()

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
    @Published var showInstructions: Bool = !hasSeenInstructions()
    @Published var showHelp: Bool = false

    // 📙
    @AppStorage("autoCorrect") var autoCorrect: Bool = true


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
//            }
//            else {
//                print("failed to set user def for terminalBackgroundColor")
//            }
           // consoleManager.fontSize = self.textSize

#endif
        }
    }
    @Published var terminalTextColor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(terminalTextColor.rawValue , forKey: "terminalTextColor")
            print("saved terminalTextColor to userdefaults")

//            if let data = terminalTextColor.colorData() {
//                UserDefaults.standard.set(data, forKey: "terminalTextColor")
//            }
//            else {
//                print("failed to set user def for termTextColor")
//            }

           // consoleManager.fontSize = self.textSize
            consoleManager.refreshAtributedText()
#endif

        }
    }
    @Published var buttonColor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(buttonColor.rawValue , forKey: "buttonColor")
            print("saved buttonColor to userdefaults")

//            if let data = buttonColor.colorData() {
//                UserDefaults.standard.set(data, forKey: "buttonColor")
//            }
//            else {
//                print("failed to set user def for buttonColor")
//            }

            //consoleManager.fontSize = self.textSize

#endif
        }
    }
    @Published var backgroundColor: Color {
        didSet {
#if !os(macOS)
            UserDefaults.standard.set(backgroundColor.rawValue, forKey: "backgroundColor")
            print("saved backgroundColor to userdefaults")
//            if let data = backgroundColor.colorData() {
//                UserDefaults.standard.set(data, forKey: "backgroundColor")
//            }
//            else {
//                print("failed to set user def for backgroundColor")
//            }

           // consoleManager.fontSize = self.textSize

#endif
        }
    }
    // END SAVED COLORS ZONE **************************************************************************************

    // BEGIN SAVED SECRETS ZONE **************************************************************************************


    @AppStorage("userName") var userName = "chris" {
        didSet {
            // screamer.disconnect()
        }
    }
    @Published var password = "swiftsage" {
        didSet {
            // screamer.disconnect()
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

        }
        else {
            self.buttonScale = defaultToolbarButtonScale
        }
        if UserDefaults.standard.float(forKey: "commandButtonFontSize") != 0 {
            self.commandButtonFontSize = CGFloat(UserDefaults.standard.float(forKey: "commandButtonFontSize"))

        }
        else {
            self.commandButtonFontSize = defaultCommandButtonSize
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

    }

    func setColorsToDisk() {
//        UserDefaults.standard.set(Color.white.rawValue , forKey: "terminalTextColor")
//
//        UserDefaults.standard.set(Color.black.rawValue , forKey: "terminalBackgroundColor")
//
//        UserDefaults.standard.set(Color.gray.rawValue , forKey: "backgroundColor")
//
//        UserDefaults.standard.set(Color.green.rawValue , forKey: "buttonColor")

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


