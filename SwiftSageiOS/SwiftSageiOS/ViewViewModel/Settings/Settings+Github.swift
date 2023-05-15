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

struct RepoFile: Identifiable, Equatable {
    var id = UUID()
    let name: String
    let url: URL
    let isDirectory: Bool
    var children: [RepoFile]?
}
func getFiles(in directory: URL) -> [RepoFile] {
    let fileManager = FileManager.default

    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)

        return fileURLs.map { url -> RepoFile in
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
            return RepoFile(name: url.lastPathComponent, url: url, isDirectory: isDirectory.boolValue, children: isDirectory.boolValue ? getFiles(in: url) : nil)
        }
    } catch {
        print("Error getting files in directory: \(error)")
        return []
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
                    self.root = RepoFile(name: "repos", url: getDocumentsDirectory(), isDirectory: true, children: childs)

                    self.isLoading = false
                }
            }

            if let location = location {
                do {
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    logD("File downloaded to: \(destinationUrl)")

                    // Unzipping

                    let fileURL = getDocumentsDirectory().appendingPathComponent(self.gitUser)

                    // TODO: Double check this for multiple repos in same user/org....
                    do {
                        try FileManager.default.removeItem(at:  fileURL)
                    }
                    catch {
                        print("did not delete or didn't exist old REPO")
                    }

                    try FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
                    let myProgress = Progress()
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

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

// Function to save a MyObject instance to UserDefaults
//func saveGithubContentToDisk(object: [GitHubContent], forKey key: String) {
//
//   let encoder = JSONEncoder()
//   do {
//       let encodedData = try encoder.encode(object)
//
//       saveJSONData(encodedData, filename: "\(key).json")
//   }
//   catch {
//       print("failed w error = \(error)")
//   }
//}
//func retrieveGithubContentFromDisk(forKey key: String) -> [GitHubContent]? {
//
//   if let savedData = loadJSONData(filename: "\(key).json") {
//       do {
//           let decoder = JSONDecoder()
//           return try decoder.decode([GitHubContent].self, from: savedData)
//       }
//       catch {
//           print("failed w error = \(error)")
//       }
//   }
//   return nil
//}
//func loadJSONData(filename: String) -> Data? {
//    let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
//
//    do {
//        let data = try Data(contentsOf: fileURL)
//        return data
//    } catch {
//        print("Failed to read JSON data: \(error.localizedDescription)")
//        return nil
//    }
//}
//func saveJSONData(_ data: Data, filename: String) {
//    let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
//
//    do {
//        try data.write(to: fileURL)
//    } catch {
//        print("Failed to write JSON data: \(error.localizedDescription)")
//    }
//}
// END GITHUB API HANDLING ZONE **************************************************************************************
