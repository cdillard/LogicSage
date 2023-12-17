//
//  GPT.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/2/23.
//

import Foundation

extension GPT {
    func createAssistant(name: String, description: String, instructions: String, model: String = "gpt-4-1106-preview", completion: @escaping (String?) -> Void) {
        // TODO Implement Tools.

        let assistantsQuery = AssistantsQuery(model: Model(model), name: name, description: description, instructions: instructions, tools: [])
        self.openAINonBg.assistants(query: assistantsQuery, method: "POST", after: nil) { result in
            switch result {
            case .success(let result):
                print("Great successs creating assistant. \(result)")
                completion(result.id)

            case .failure(let error):
                print("FAILED  creating assistant.")
                completion(nil)
            }
        }
    }

    func createThread(messages: [Chat], completion: @escaping (String?) -> Void) {
        let assistantsQuery = ThreadsQuery(messages: messages)
        self.openAINonBg.threads(query: assistantsQuery) { result in
            switch result {
            case .success(let result):
                print("Great successs creating thread. \(result)")
                completion(result.id)
            case .failure(let error):
                print("FAILED  creating thread.")
                completion(nil)
            }
        }
    }
}
