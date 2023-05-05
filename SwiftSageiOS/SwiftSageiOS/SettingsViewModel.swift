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
let repoURL = "https://api.github.com/repos/cdillard/SwiftSage/git/trees/main?recursive=1"
class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()
    let keychainManager = KeychainManager()
    @Published var sourceEditorCode = """
    """
    @Published var rootFiles: [RepositoryFile] = []
    @Published var isLoading: Bool = false
    var cancellable: AnyCancellable?

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
    @Published var showHelp: Bool = false

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

    let aiKeyKey = "openAIKeySec"
    let ghaKeyKey = "ghaPat"
    // CLIENT API KEYS
    // TODO: USER THE KEYCHAIN

    @Published var openAIKey = "" {
        didSet {
            if keychainManager.saveToKeychain(key:aiKeyKey, value: openAIKey) {
               // print("openAIKey saved successfully")
            } else {
                print("Error saving key")
            }
        }
    }


    @AppStorage("openAIModel") var openAIModel = "\(gptModel)"


    @Published var ghaPat = ""  {
        didSet {
            if keychainManager.saveToKeychain(key: ghaKeyKey, value: ghaPat) {
                //print("ghPat saved successfully")
            } else {
                print("Error saving key")
            }
        }

    }

    // END CLIENT APIS ZONE

    init() {
#if !os(macOS)

        self.terminalBackgroundColor = UserDefaults.standard.data(forKey: "terminalBackgroundColor").flatMap { Color.color(data: $0) } ?? .black
        self.terminalTextColor = UserDefaults.standard.data(forKey: "terminalTextColor").flatMap { Color.color(data: $0) } ?? .white
        self.buttonColor = UserDefaults.standard.data(forKey: "buttonColor").flatMap { Color.color(data: $0) } ?? .green
        self.backgroundColor = UserDefaults.standard.data(forKey: "backgroundColor").flatMap { Color.color(data: $0) } ?? .black
        self.textSize = CGFloat(UserDefaults.standard.float(forKey: "textSize"))

        if let key = keychainManager.retrieveFromKeychain(key: aiKeyKey) {

            self.openAIKey = key
 //           print("Retrieved value: \(openAIKey)")
        } else {
//            print("Error retrieving openAIKey")
//            keychainManager.saveToKeychain(key:openAIKey, value: "")

        }
        if let key = keychainManager.retrieveFromKeychain(key: ghaKeyKey) {

            self.ghaPat = key
  //          print("Retrieved value: \(ghaPat)")
        } else {
   //         print("Error retrieving ghaPat == reset")
 //           keychainManager.saveToKeychain(key:ghaKeyKey, value: "")


        }
        if let key = keychainManager.retrieveFromKeychain(key: "swsPassword") {

            self.password = key
  //          print("Retrieved value: \(ghaPat)")
        } else {
   //         print("Error retrieving ghaPat == reset")
 //           keychainManager.saveToKeychain(key:ghaKeyKey, value: "")


        }

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


extension SettingsViewModel {
    private func fetchFileContentPublisher(accessToken: String, filePath: String) -> AnyPublisher<String, Error> {
        let apiUrl = URL(string: "https://api.github.com/repos/cdillard/SwiftSage/contents/\(filePath)?ref=main")!
        var request = URLRequest(url: apiUrl)
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .tryMap { data -> String in
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let fileContentUrlString = json?["download_url"] as? String,
                      let fileContentUrl = URL(string: fileContentUrlString) else {
                    throw URLError(.badURL)
                }
                let fileContentData = try Data(contentsOf: fileContentUrl)
                return String(data: fileContentData, encoding: .utf8) ?? ""
            }
            .eraseToAnyPublisher()
    }

    func fetchRepositoryTreeStructure(accessToken: String) {
        isLoading = true
        cancellable = fetchRepositoryTreeStructurePublisher(accessToken: accessToken)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                logD("fetched repository at url = \(repoURL)")
                if case .failure(let error) = completion {
                    print("Error fetching repository tree structure: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] filePaths in
                self?.rootFiles = self?.buildFileHierarchy(from: filePaths) ?? []
            }
    }

    private func buildFileHierarchy(from filePaths: [String]) -> [RepositoryFile] {
        var fileDict: [String: RepositoryFile] = [:]
        var directoryPaths: Set<String> = []

        // Identify directory paths
        for path in filePaths {
            let components = path.split(separator: "/")
            if components.count > 1 {
                let parentComponents = components.dropLast()
                let parentPath = parentComponents.joined(separator: "/")
                directoryPaths.insert(parentPath)
            }
        }

        // Create hierarchical structure
        for path in filePaths {
            let components = path.split(separator: "/")
            var currentFolder: RepositoryFile? = nil

            for (index, component) in components.enumerated() {
                let currentPath = components[0...index].joined(separator: "/")

                if let existingFile = fileDict[currentPath] {
                    currentFolder = existingFile
                } else {
                    let isDirectory = directoryPaths.contains(currentPath)
                    let newFile = RepositoryFile(id: currentPath, name: String(component), path: currentPath, isDirectory: isDirectory)
                    fileDict[currentPath] = newFile

                    if let parentPath = components.dropLast().joined(separator: "/").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed), var parentFolder = fileDict[parentPath] {
                        parentFolder.children.append(newFile)
                        fileDict[parentPath] = parentFolder
                    }

                    currentFolder = newFile
                }
            }
        }

        return fileDict.values.filter { $0.path.split(separator: "/").count == 1 }.sorted(by: { $0.name < $1.name })
    }


    func fetchFileContent(accessToken: String, filePath: String, completion: @escaping (Result<String, Error>) -> Void) {
        cancellable = fetchFileContentPublisher(accessToken: accessToken, filePath: filePath)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionStatus in
                if case .failure(let error) = completionStatus {
                    completion(.failure(error))
                }
            }, receiveValue: { fileContent in
                completion(.success(fileContent))
            })
    }


    private func fetchRepositoryTreeStructurePublisher(accessToken: String) -> AnyPublisher<[String], Error> {
        let apiUrl = URL(string: "https://api.github.com/repos/cdillard/SwiftSage/git/trees/main?recursive=1")!
        var request = URLRequest(url: apiUrl)
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .tryMap { data -> [String] in
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let tree = json?["tree"] as? [[String: Any]] else { return [] }
                return tree.compactMap { $0["path"] as? String }
            }
            .eraseToAnyPublisher()
    }

}
