//
//  Linker.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/20/23.
//

import Foundation

func linkIt(link: String, completion: @escaping (String?) -> Void) {
    logD("Linking it... \(link)")
    linkReq(linkString: link) { result in
            switch result {
            case .success(let text):

                completion(text)
            case .failure(let error):
                logD("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
}

func linkReq(linkString: String, completion: @escaping (Result<String, Error>) -> Void) {
    let string2 = linkString.replacingOccurrences(of: "\\", with: "")
    let urlComponents = URLComponents(string: string2)

    guard let url = urlComponents?.url else {
        completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
        return
    }
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 10
    let customSession = URLSession(configuration: configuration)

    let urlreq = URLRequest(url: url)
    let task =  URLSession.shared.dataTask(with: urlreq) { data, response, error in
        do {
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let dataString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            customSession.finishTasksAndInvalidate()

            let extractedText = try extractText(from: dataString)

            completion(.success(extractedText))
        }
        catch {
            logD("failed to link w e=\(error)")
        }
    }
    task.resume()
}
