//
//  Googler.Swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/18/23.
//

import Foundation

struct SearchResult: Codable {
    let items: [SearchItem]
}

struct SearchItem: Codable {
    let title: String
    let link: String
    let snippet: String
}

func search(query: String, apiKey: String, searchEngineId: String, completion: @escaping (Result<[SearchItem], Error>) -> Void) {
    var urlComponents = URLComponents(string: "https://www.googleapis.com/customsearch/v1")
    urlComponents?.queryItems = [
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "key", value: apiKey),
        URLQueryItem(name: "cx", value: searchEngineId)
    ]

    guard let url = urlComponents?.url else {
        completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
        return
    }
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 10
    let customSession = URLSession(configuration: configuration)
    let task = customSession.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
            return
        }
        customSession.finishTasksAndInvalidate()

        do {
            let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
            // TODO : Double check this prefixing, its just to test less serach results now
            completion(.success(Array(searchResult.items.prefix(2))))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}


func searchIt(query: String, completion: @escaping (String?) -> Void) {
    print("Searching it... \(query)")
    search(query: query, apiKey: GOOGLE_KEY, searchEngineId: GOOGLE_ID) { result in
        switch result {
        case .success(let searchItems):
            for item in searchItems {
                print("Title: \(item.title)")
                print("Link: \(item.link)")
                print("Snippet: \(item.snippet)")
                print("\n")
            }

            func searchItemsToJSONString(_ searchItems: [SearchItem]) -> String? {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted

                do {
                    let jsonData = try encoder.encode(searchItems)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        return jsonString
                    }
                } catch {
                    print("Error encoding SearchItem array to JSON: \(error.localizedDescription)")
                }

                return nil
            }

            completion(searchItemsToJSONString(searchItems))
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
            completion(nil)
        }
    }
}
