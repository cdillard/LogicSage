//
//  Settings+WriteGithub.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/14/23.
//

import Foundation

extension SettingsViewModel {
    func actualCreateDraftPR() {
        var hasSentPRCreation = false
        print("actually creating draft pr")
        getDefaultHeadSha(defaultBranch: "main") { sha in
            let newBranchName = UUID().uuidString
            self.createDrafBranch(newBranchName: newBranchName, commitSha: sha) { success in
                if success {
                    // For each file in the staged Changes, get the sha ref and put the new file Contents.
                    for file in self.stagedFileChanges {
                        let pathString = file.fileURL.absoluteString
                        let trailingPathComps = pathString.components(separatedBy: "\(self.gitUser)/\(self.gitRepo)-\(self.gitBranch)/")
                        if trailingPathComps.count > 1 {
                            let trailingPath = trailingPathComps[1]

                            self.getShaOfFileFromPath(path: trailingPath) { sha in
                                print("got sha of changed file")
                                self.updateFileWithNewContent(branch: newBranchName, sha: sha, path: trailingPath, fileContent: file.newFileContents) { success in
                                    if success {
                                        print("Update file success")

                                        if !hasSentPRCreation {
                                            hasSentPRCreation = true
                                            self.createPR(branchName: newBranchName) { success in
                                                if success {
                                                    print("Successful PR creation")

                                                }
                                                else {
                                                    print("fail to create draft PR")
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        print("Update file FAIL")
                                    }
                                }
                            }

                        }
                        else {
                            print("failed to extract trailing path")
                        }

                    }

                }
                else {
                    print("fail to create draf branch")
                }
            }
        }
    }
    func getDefaultHeadSha(defaultBranch: String, completion: @escaping (String) -> Void) {
        let url = URL(string: "https://api.github.com/repos/\(gitUser)/\(gitRepo)/branches/\(defaultBranch)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(SettingsViewModel.shared.ghaPat)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let commit = json["commit"] as? [String: Any] {
                        print(commit["sha"] as? String ?? "")

                        completion(commit["sha"] as? String ?? "")
                    }
                } catch {
                    print("Error: \(error)")
                    completion("")
                }
            }
        }
        task.resume()
    }
    func createDrafBranch(newBranchName: String = UUID().uuidString, commitSha: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://api.github.com/repos/\(gitUser)/\(gitRepo)/git/refs")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(SettingsViewModel.shared.ghaPat)", forHTTPHeaderField: "Authorization")
        let json: [String: Any] = ["ref": "refs/heads/\(newBranchName)",
                                   "sha": "\(commitSha)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(false)
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("Received data:\n\(str ?? "")")

                print("Continuing on to create PR")
                completion(true)
            }
        }
        task.resume()
    }
    func createPR(titleOfPR: String = UUID().uuidString, branchName: String, baseBranch: String = "main", completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://api.github.com/repos/\(gitUser)/\(gitRepo)/pulls")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(SettingsViewModel.shared.ghaPat)", forHTTPHeaderField: "Authorization")
        let json: [String: Any] = ["title": "\(titleOfPR)",
                                   "head": "\(branchName)",
                                   "base": "\(baseBranch)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print(jsonResponse)
                    completion(true)
                } catch {
                    print("Error: \(error)")
                    completion(false)
                }
            }
        }
        task.resume()
    }
    func getShaOfFileFromPath(path: String,completion: @escaping (String) -> Void) {
        let url = URL(string: "https://api.github.com/repos/\(gitUser)/\(gitRepo)/contents/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(SettingsViewModel.shared.ghaPat)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion("")
            } else if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json["sha"] as? String ?? "")
                        completion(json["sha"] as? String ?? "")
                    }
                } catch {
                    print("Error: \(error)")
                    completion("")
                }
            }
        }
        task.resume()
    }

    func updateFileWithNewContent(branch: String, commitMessage: String = UUID().uuidString, sha: String, path: String, fileContent: String, completion: @escaping (Bool) -> Void) {

        let url = URL(string: "https://api.github.com/repos/\(gitUser)/\(gitRepo)/contents/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(SettingsViewModel.shared.ghaPat)", forHTTPHeaderField: "Authorization")

        let newFileContent = "\(fileContent)".data(using: .utf8)!.base64EncodedString()
        let json: [String: Any] = ["message": "\(commitMessage)", // Replace <commit-message> with your commit message
                                   "content": newFileContent,
                                   "sha": "\(sha)", // Replace <file-sha> with the SHA of the file you got from the previous request
                                   "branch": "\(branch)"] // The branch where you want to commit your changes
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(false)
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("Received data:\n\(str ?? "")")
                completion(true)
            }
        }

        task.resume()
    }
}
