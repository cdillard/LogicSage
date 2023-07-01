//
//  Googler.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/2/23.
//

//import Foundation
//
//struct SearchResult: Codable {
//    let items: [SearchItem]
//}
//
//struct SearchItem: Codable {
//    let title: String?
//    let link: String?
//    let snippet: String?
//}
//
//func search(query: String, apiKey: String, searchEngineId: String, completion: @escaping (Result<[SearchItem], Error>) -> Void) {
//    var urlComponents = URLComponents(string: "https://www.googleapis.com/customsearch/v1")
//    urlComponents?.queryItems = [
//        URLQueryItem(name: "q", value: query),
//        URLQueryItem(name: "key", value: apiKey),
//        URLQueryItem(name: "cx", value: searchEngineId)
//    ]
//
//    guard let url = urlComponents?.url else {
//        completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
//        return
//    }
//    let configuration = URLSessionConfiguration.default
//    configuration.timeoutIntervalForRequest = 10
//    let customSession = URLSession(configuration: configuration)
//    let task = customSession.dataTask(with: url) { data, response, error in
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//
//        guard let data = data else {
//            completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
//            return
//        }
//        customSession.finishTasksAndInvalidate()
//
//        do {
//            let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
//            // TODO : Double check this prefixing, its just to test less serach results now
//            completion(.success(Array(searchResult.items.prefix(2))))
//        } catch {
//            completion(.failure(error))
//        }
//    }
//    task.resume()
//}
