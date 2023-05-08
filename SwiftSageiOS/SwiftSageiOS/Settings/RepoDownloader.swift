//
//  RepoDownloader.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/7/23.
//

import Foundation
func downloadAndStoreFiles(_ files: [GitHubContent], accessToken: String, completionHandler: @escaping (Result<Void, Error>) -> Void) {
    let dispatchGroup = DispatchGroup()
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    for file in files {
        if file.type == "file", let downloadUrl = file.downloadUrl {
            dispatchGroup.enter()

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
                        logD("Wrote \(fileURL)")

                    } catch {
                        logD("error writing file: \(error)")

                        completionHandler(.failure(error))
                        return
                    }
                }.resume()
            }

        }
    }

    dispatchGroup.notify(queue: .main) {
        print("Successfully downloaded all files of repository.")
        completionHandler(.success(()))
    }
}
