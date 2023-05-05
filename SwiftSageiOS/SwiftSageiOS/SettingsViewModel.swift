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
    @Published var rootFiles: [GitHubContent] = []
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
struct GitHubContent: Codable, Identifiable {
    var id: String {
        return path
    }
    let name: String
    let path: String
    let type: String
    let size: Int
    let downloadUrl: String?
    let htmlUrl: URL
    let gitUrl: URL
    let url: URL
    let sha: String
    let links: Links
    var children: [GitHubContent]?

    enum CodingKeys: String, CodingKey {
        case name
        case path
        case type
        case size
        case downloadUrl = "download_url"
        case htmlUrl = "html_url"
        case gitUrl = "git_url"
        case url
        case sha
        case links = "_links"
    }

    struct Links: Codable {
        let git: URL
        let html: URL
        let `self`: URL
    }
}

extension SettingsViewModel {
    func syncGithubRepo() {
        SettingsViewModel.shared.fetchSubfolders(path: "", delay: 1.0) { result in
            switch result {
            case .success(let repositoryFiles):
                print("All files and directories: \(repositoryFiles)")
                self.rootFiles = repositoryFiles
            case .failure(let error):
                print("Error fetching files: \(error)")
            }
        }
    }

    func fetchRepositoryTreeStructure(path: String = "", completion: @escaping (Result<[GitHubContent], Error>) -> Void) {
        let owner = "cdillard"
         let repo = "SwiftSage"
         let branch = "main"
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/contents/\(path)?ref=\(branch)".replacingOccurrences(of: " ", with: "%20")

        if let apiUrl = URL(string: urlString)  {


            var request = URLRequest(url: apiUrl)
            request.addValue("token \(ghaPat)", forHTTPHeaderField: "Authorization")
            logD("Execute github API req with path = \(path)")


            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                    return
                }

                do {
                    print("data = \(String(data: data, encoding: .utf8))")
                    let decodedData = try JSONDecoder().decode([GitHubContent].self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        else {
            print("failed to make URL")
        }
    }

    func fetchSubfolders(path: String, delay: TimeInterval, completion: @escaping (Result<[GitHubContent], Error>) -> Void) {
        fetchRepositoryTreeStructure(path: path) { [weak self] result in
            switch result {
            case .success(var githubContents):
                let directories = githubContents.filter { $0.type == "dir" }
                let group = DispatchGroup()

                for directory in directories {
                    group.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self?.fetchSubfolders(path: directory.path, delay: delay) { result in
                            switch result {
                            case .success(let files):
                                if let index = githubContents.firstIndex(where: { $0.id == directory.id }) {
                                    githubContents[index].children = files
                                }
                            case .failure(let error):
                                print("Error fetching subfolder: \(error)")
                            }
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    completion(.success(githubContents))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // Fetch specific file
    private func fetchFileContentPublisher(filePath: String) -> AnyPublisher<String, Error> {
        let apiUrl = URL(string: "https://api.github.com/repos/cdillard/SwiftSage/contents/\(filePath)?ref=main")!
        var request = URLRequest(url: apiUrl)
        request.addValue("token \(ghaPat)", forHTTPHeaderField: "Authorization")
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
    func fetchFileContent(accessToken: String, filePath: String, completion: @escaping (Result<String, Error>) -> Void) {
        cancellable = fetchFileContentPublisher(filePath: filePath)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionStatus in
                if case .failure(let error) = completionStatus {
                    completion(.failure(error))
                }
            }, receiveValue: { fileContent in
                completion(.success(fileContent))
            })
    }
}
