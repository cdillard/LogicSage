//
//  CommitDownloader.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/7/23.
//

import Foundation

struct Commit: Codable {
    let sha: String
    let commit: CommitDetails
}

struct CommitDetails: Codable {
    let author: CommitAuthor
    let message: String
}

struct CommitAuthor: Codable {
    let name: String
    let email: String
    let date: String
}

// TODO: IMPLEMENT COMMIT FETCHING AN DSIPLAY 
class GitHubAPI {
    private let baseURL = "https://api.github.com"
    private let personalAccessToken = "your_personal_access_token"

    func fetchLatestCommits(owner: String, repo: String, completion: @escaping (Result<[Commit], Error>) -> Void) {
        let latestCommitsURL = URL(string: "\(baseURL)/repos/\(owner)/\(repo)/commits")!

        var request = URLRequest(url: latestCommitsURL)
        request.httpMethod = "GET"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(personalAccessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "GitHubAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let commits = try JSONDecoder().decode([Commit].self, from: data)
                completion(.success(commits))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // PREVIOUS CODE WILL FETCH FOR DEFAULT (main) branch only. this one can specify sha
    //can replace sha=all with sha=branch_name in the URL, where branch_name is the name of the branch you want to fetch commits from.
    /*
     func fetchLatestCommits(owner: String, repo: String, completion: @escaping (Result<[Commit], Error>) -> Void) {
         let latestCommitsURL = URL(string: "\(baseURL)/repos/\(owner)/\(repo)/commits?sha=all")!

         var request = URLRequest(url: latestCommitsURL)
         request.httpMethod = "GET"
         request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
         request.setValue("Bearer \(personalAccessToken)", forHTTPHeaderField: "Authorization")

         let task = URLSession.shared.dataTask(with: request) { data, response, error in
             if let error = error {
                 completion(.failure(error))
                 return
             }

             guard let data = data else {
                 completion(.failure(NSError(domain: "GitHubAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                 return
             }

             do {
                 let commits = try JSONDecoder().decode([Commit].self, from: data)
                 completion(.success(commits))
             } catch {
                 completion(.failure(error))
             }
         }

         task.resume()
     }

     */
}
