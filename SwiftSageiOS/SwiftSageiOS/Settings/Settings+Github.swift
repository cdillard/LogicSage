//
//  Settings+Github.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/7/23.
//

import Foundation
import SwiftUI
import Combine
import UIKit

// BEGIN GITHUB API HANDLING ZONE **************************************************************************************

let githubDelay: TimeInterval = 1.5

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
    }

    struct Links: Equatable, Codable {
        let git: URL
        let html: URL
        let `self`: URL
    }
}

extension SettingsViewModel {
    func syncGithubRepo() {
        isLoading = true
        self.rootFiles = []
        SettingsViewModel.shared.fetchSubfolders(path: "", delay: githubDelay) { result in
            switch result {
            case .success(let repositoryFiles):
                logD("All file and directories structure downloaded.")
                logD("Downloading all files in repo...")
                self.rootFiles = repositoryFiles

                var allChildren = [GitHubContent]()
                for file in self.rootFiles {
                    allChildren += file.children ?? []
                }

                downloadAndStoreFiles(self.rootFiles + allChildren, accessToken: SettingsViewModel.shared.ghaPat) { success in
                    defer { self.isLoading = false }
                    switch success {
                    case .success(let files):
                        logD("Successful download of repo contents = \(files).")

                    case .failure(let error):
                        
                        logD("Error downloading repo contents. \(error)!")

                    }
                }
            case .failure(let error):
                self.isLoading = false
                logD("Error fetching files: \(error)")
            }
        }
    }

    func fetchRepositoryTreeStructure(path: String = "", completion: @escaping (Result<[GitHubContent], Error>) -> Void) {

        let urlString = "https://api.github.com/repos/\(SettingsViewModel.shared.gitUser)/\(SettingsViewModel.shared.gitRepo)/contents/\(path)?ref=\(SettingsViewModel.shared.gitBranch)".replacingOccurrences(of: " ", with: "%20")

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
                    // print("data = \(String(data: data, encoding: .utf8))")
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


// END GITHUB API HANDLING ZONE **************************************************************************************
