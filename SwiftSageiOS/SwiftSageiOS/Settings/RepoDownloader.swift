//
//  RepoDownloader.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/7/23.
//

import Foundation
func downloadAndStoreFiles(_ rootFile: GitHubContent?, _ files: [GitHubContent], accessToken: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
    let dispatchGroup = DispatchGroup()
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    for file in files {
        dispatchGroup.enter()

        if file.type == "file", let downloadUrl = file.downloadUrl {


            
            var request = URLRequest(url: URL(string: downloadUrl)!)
            request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

            DispatchQueue.main.asyncAfter(deadline: .now() + githubDelay) {

                URLSession.shared.dataTask(with: request) { data, response, error in
                     defer { dispatchGroup.leave() }

                    if let error = error {
                        completionHandler(.failure(error))
                        return
                    }

                    guard let data = data else {
                        logD("error writing file: DownloadError")

                        completionHandler(.failure(NSError(domain: "DownloadError", code: -1, userInfo: nil)))
                        return
                    }

                    let fileURL = documentsDirectory.appendingPathComponent(SettingsViewModel.shared.gitUser).appendingPathComponent(SettingsViewModel.shared.gitRepo).appendingPathComponent(SettingsViewModel.shared.gitBranch).appendingPathComponent(file.path)
                    do {
                        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                        try data.write(to: fileURL)
                        //logD("Wrote \(fileURL)")

                    } catch {
                        logD("error writing file: \(error)")

                        completionHandler(.failure(error))
                        return
                    }
                }.resume()
            }

        }
        else if file.type == "dir" && file.children?.isEmpty == false {
            downloadAndStoreFiles(file, file.children ?? [], accessToken: SettingsViewModel.shared.ghaPat) { success in
                defer { dispatchGroup.leave() }
                switch success {
                case .success(_):
//                    logD("Successful download of dir children.")
                    break
                case .failure(let error):

                    logD("Error download of dir children.error =  \(error)!")

                }
            }
        }
    }

    dispatchGroup.notify(queue: .main) {
        completionHandler(.success(()))
    }
}
