//
//  SettingsViewModel.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI
import Combine
let defaultTerminalFontSize: CGFloat = 12.666

class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()
    @Published var isInputViewShown = false
    @Published var commandMode: EntryMode = .commandBar

    @AppStorage("savedText") var multiLineText = ""
    @Published var voiceOutputenabled = false
    @AppStorage("voiceOutputEnabled") var voiceOutputenabledUserDefault = false

    // TODO
    // add the code for server 
    @Published var serverVoiceOutputEnabled = false
    @Published var installedVoices = [VoicePair]()
    @Published var selectedVoice: VoicePair?
    @Published var isRecording = false
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Published var recognizedText: String = ""


    @Published var hasAcceptedMicrophone = false
    @AppStorage("device") var currentMode: Device = .mobile

    @Published var showAddView = false
    @Published var showInstructions: Bool = !hasSeenInstructions()

    @AppStorage("savedButtonSize") var buttonScale: Double = 0.2 {
        didSet {
            buttonScalerFloat = CGFloat(  buttonScale)
        }
    }
    @Published var buttonScalerFloat: CGFloat = 0.2

    // COMMAND BUTTON SIZE
    @AppStorage("commandButtonFontSize")var commandButtonFontSize: Double = 24 {
        didSet {
            commandButtonFontSizeFloat = CGFloat(  commandButtonFontSize)
        }
    }

    @Published var commandButtonFontSizeFloat: CGFloat = 24



    @AppStorage("userName") var userName = "chris" {
        didSet {
           // screamer.disconnect()
        }
    }
    @AppStorage("password") var password = "swiftsage" {
        didSet {
           // screamer.disconnect()
        }
    }


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
    @Published var textSize: CGFloat = defaultTerminalFontSize {
        didSet {
            UserDefaults.standard.set(Float(textSize), forKey: "textSize")
        }
    }
    @Published var terminalBackgroundColor: Color = .black {
        didSet {
#if !os(macOS)

            if let data = terminalBackgroundColor.colorData() {
                UserDefaults.standard.set(data, forKey: "terminalBackgroundColor")
            }
#endif
        }
    }
    @Published var terminalTextColor: Color = .white {
        didSet {
#if !os(macOS)

            if let data = terminalTextColor.colorData() {
                UserDefaults.standard.set(data, forKey: "terminalTextColor")
            }
            #endif
        }
    }
    @Published var buttonColor: Color = .green {
        didSet {
#if !os(macOS)
            if let data = buttonColor.colorData() {
                UserDefaults.standard.set(data, forKey: "buttonColor")
            }
#endif
        }
    }
    @Published var backgroundColor: Color = .gray {
        didSet {
#if !os(macOS)
            if let data = backgroundColor.colorData() {
                UserDefaults.standard.set(data, forKey: "backgroundColor")
            }
#endif
        }
    }


    @Published var isEditorVisible: Bool = false {
        didSet {

        }
    }

    @Published var isWebViewVisible: Bool = false {
        didSet {

        }
    }


// CLIENT API KEYS
    // TODO: USER THE KEYCHAIN

    @AppStorage("openAIKey") var openAIKey = "sk-"

// END CLIENT APIS ZONE

    init() {
#if !os(macOS)

        self.terminalBackgroundColor = UserDefaults.standard.data(forKey: "terminalBackgroundColor").flatMap { Color.color(data: $0) } ?? .black
        self.terminalTextColor = UserDefaults.standard.data(forKey: "terminalTextColor").flatMap { Color.color(data: $0) } ?? .white
        self.buttonColor = UserDefaults.standard.data(forKey: "buttonColor").flatMap { Color.color(data: $0) } ?? .green
        self.backgroundColor = UserDefaults.standard.data(forKey: "backgroundColor").flatMap { Color.color(data: $0) } ?? .black
        self.textSize = CGFloat(UserDefaults.standard.float(forKey: "textSize"))

        voiceOutputenabled = voiceOutputenabledUserDefault
#endif
        
    }
}
#if !os(macOS)

extension Color {
    static func color(data: Data) -> Color {
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .clear

            return Color(color)
        } catch {
            print("Error converting Data to Color: \(error)")
            return Color.clear
        }
    }

    func colorData() -> Data? {
        do {
            let uiColor = uiColor()
            let data = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            return data
        } catch {
            print("Error converting Color to Data: \(error)")
            return nil
        }
    }
}
#endif
enum Device: Int {
    case mobile, computer
}
