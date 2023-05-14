//
//  Settings+Github.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/7/23.
//

import Foundation
import SwiftUI
import Combine
#if !os(macOS)

import UIKit
#endif
import ZIPFoundation

// BEGIN GITHUB API HANDLING ZONE **************************************************************************************

let githubDelay: TimeInterval = 1.2666

struct GitHubContent: Equatable, Codable, Identifiable {
    static func == (lhs: GitHubContent, rhs: GitHubContent) -> Bool {
        return lhs.name == rhs.name &&
               lhs.path == rhs.path &&
               lhs.type == rhs.type &&
               lhs.size == rhs.size &&
               lhs.downloadUrl == rhs.downloadUrl &&
               lhs.htmlUrl == rhs.htmlUrl &&
               lhs.gitUrl == rhs.gitUrl &&
               lhs.url == rhs.url &&
               lhs.sha == rhs.sha &&
               lhs.links == rhs.links &&
               lhs.children == rhs.children
    }

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
        case children = "children"
    }

    struct Links: Equatable, Codable {
        let git: URL
        let html: URL
        let `self`: URL
    }
}
 var unzipObservation: NSKeyValueObservation?
var downloadobservation: NSKeyValueObservation?

extension SettingsViewModel {
    func syncGithubRepo(_ syncCompletion: @escaping (Bool) -> Void ) {
        isLoading = true

        let urlString = "http://github.com/\(gitUser)/\(gitRepo)/archive/\(gitBranch).zip"
        let outputFileName = "\(gitBranch).zip"

        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }

        let destinationUrl = getDocumentsDirectory().appendingPathComponent(outputFileName)

        do {
            try FileManager.default.removeItem(at:  destinationUrl)
        }
        catch {
            print("did not delete or didn't exist old zip")
        }
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            DispatchQueue.main.async {
                self.downloadProgress = 0.0
            }
            defer {
                let childs = getFiles(in: getDocumentsDirectory())
                DispatchQueue.main.async {
                    self.root = RepoFile(name: "Root", url: getDocumentsDirectory(), isDirectory: true, children: childs)

                    self.isLoading = false
                }
            }

            if let location = location {
                do {
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    logD("File downloaded to: \(destinationUrl)")

                    // Unzipping

                    let fileURL = getDocumentsDirectory().appendingPathComponent(self.currentGitRepoKey())

                    try FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
                    var myProgress = Progress()
                    unzipObservation = myProgress.observe(\.fractionCompleted) { progress, _ in
                        DispatchQueue.main.async {
                            self.unzipProgress = progress.fractionCompleted
                        }
                    }
                    try FileManager.default.unzipItem(at: destinationUrl, to: fileURL, progress: myProgress)

                    DispatchQueue.main.async {
                        
                        self.unzipProgress = 0.0
                    }
                    logD("File unzipped to: \(fileURL)")
                    do {
                        try FileManager.default.removeItem(at:  destinationUrl)
                        print("rm .zip sucess")
                    }
                    catch {
                        print("did not delete or didn't exist zip")
                    }
                    syncCompletion(true)

                } catch {
                    logD("Error: \(error)")

                    do {
                        try FileManager.default.removeItem(at:  destinationUrl)
                        print("rm .zip sucess")
                    }
                    catch {
                        print("rm .zip fail")

                    }

                    syncCompletion(false)

                }
            }
        }
        downloadobservation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                
                self.downloadProgress = progress.fractionCompleted
            }
        }
        task.resume()
    }

    func fetchRepositoryTreeStructure(path: String = "", completion: @escaping (Result<[GitHubContent], Error>) -> Void) {

        let urlString = "https://api.github.com/repos/\(SettingsViewModel.shared.gitUser)/\(SettingsViewModel.shared.gitRepo)/contents/\(path)?ref=\(SettingsViewModel.shared.gitBranch)"
            .replacingOccurrences(of: " ", with: "%20")

        if let apiUrl = URL(string: urlString)  {


            var request = URLRequest(url: apiUrl)
            request.addValue("token \(ghaPat)", forHTTPHeaderField: "Authorization")
            //logD("Execute github API req with path = \(path)")


            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

                if let error = error {
                    print("failed to get repotree w error = \(error)")
                    print(String(data: data ?? Data(), encoding: .utf8))

                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    print("failed to get repotree  w error = \(error)")
                    print(String(data: data ?? Data(), encoding: .utf8))

                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                    return
                }

                do {
                    let decodedData = try JSONDecoder().decode([GitHubContent].self, from: data)
                    completion(.success(decodedData))
                } catch {
                    print("failed to get repotree w error = \(error)")
                    print(String(data: data ?? Data(), encoding: .utf8))

                    completion(.failure(error))
                    return
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
                                completion(.failure(error))
                                return
                            }
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    completion(.success(githubContents))
                }
            case .failure(let error):
                print("Error fetching subfolder: \(error)")

                completion(.failure(error))
            }
        }
    }

    // Fetch specific file
    private func fetchFileContentPublisher(filePath: String) throws -> AnyPublisher<String, Error> {
        if let apiUrl = URL(string: "https://api.github.com/repos/\(SettingsViewModel.shared.gitUser)/\(SettingsViewModel.shared.gitRepo)/contents/\(filePath)?ref=\(SettingsViewModel.shared.gitBranch)".replacingOccurrences(of: " ", with: "%20")) {
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
        else {
                print("catastrophic error dling github repo. faling...")
                throw URLError(.badURL)
        }
    }
    func fetchFileContent(accessToken: String, filePath: String, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            cancellable = try fetchFileContentPublisher(filePath: filePath)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completionStatus in
                    if case .failure(let error) = completionStatus {
                        completion(.failure(error))
                    }
                }, receiveValue: { fileContent in
                    completion(.success(fileContent))
                })
        }
        catch {
            print("failed to fetch file content w/ error = \(error)")
        }
    }
}

let maxFolderTraversalDepth = 3

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

extension SettingsViewModel {
//   func loadDirectories() -> [URL] {
//       let documentsDirectory = getDocumentsDirectory()
//
//       var retDir = [URL]()
//
//         do {
//             retDir = try listDirectories(at: documentsDirectory, depth: 1)
//         } catch {
//             print("Error loading directories: \(error)")
//         }
//
//       return retDir
//     }

   func listDirectories(at url: URL, depth: Int) throws -> [URL] {
       guard depth <= maxFolderTraversalDepth else { return [] }

       let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
       var retDir = [URL]()
       for content in directoryContents {
           let resourceValues = try content.resourceValues(forKeys: Set([URLResourceKey.isDirectoryKey]))
           let isDirectory = resourceValues.isDirectory ?? false
           if isDirectory {
               if depth == 3 {
                   retDir.append(content)
               }
               let childs = try listDirectories(at: content, depth: depth + 1)
               retDir += childs
           }
       }
       return retDir
   }
}
// Function to save a MyObject instance to UserDefaults
func saveGithubContentToDisk(object: [GitHubContent], forKey key: String) {

   let encoder = JSONEncoder()
   do {
       let encodedData = try encoder.encode(object)

       saveJSONData(encodedData, filename: "\(key).json")
   }
   catch {
       print("failed w error = \(error)")
   }
}
func retrieveGithubContentFromDisk(forKey key: String) -> [GitHubContent]? {

   if let savedData = loadJSONData(filename: "\(key).json") {
       do {
           let decoder = JSONDecoder()
           return try decoder.decode([GitHubContent].self, from: savedData)
       }
       catch {
           print("failed w error = \(error)")
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
        print("Failed to read JSON data: \(error.localizedDescription)")
        return nil
    }
}
func saveJSONData(_ data: Data, filename: String) {
    let fileURL = getDocumentsDirectory().appendingPathComponent(filename)

    do {
        try data.write(to: fileURL)
    } catch {
        print("Failed to write JSON data: \(error.localizedDescription)")
    }
}
// END GITHUB API HANDLING ZONE **************************************************************************************
