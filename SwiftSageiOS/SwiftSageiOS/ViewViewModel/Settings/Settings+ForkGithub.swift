//
//  Settings+ForkGithub.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/17/23.
//

import Foundation


var forkObservation: NSKeyValueObservation?

extension SettingsViewModel {
    func forkGithubRepo(defaulBranch: String = "main", newBranchName: String = UUID().uuidString, titleOfPR: String = UUID().uuidString, forkCompletion: @escaping (Bool) -> Void) {
#if !os(macOS)
        // Create the URL for the request
        guard let url = URL(string: "https://api.github.com/repos/\(gitUser)/\(gitRepo)/forks") else {
            logD("Invalid URL")
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("token \(ghaPat)", forHTTPHeaderField: "Authorization")

        // Create the URLSession task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                logD("Error: \(error)")
                forkCompletion(false)

            } else if let data = data {
                // Handle the data from the response
                let str = String(data: data, encoding: .utf8)
                logD("Received data:\n\(str ?? "")")
                forkCompletion(true)
            }
        }
        forkObservation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {

                self.forkProgress = progress.fractionCompleted
            }
        }
        // Start the task
        task.resume()
#endif
    }

}
