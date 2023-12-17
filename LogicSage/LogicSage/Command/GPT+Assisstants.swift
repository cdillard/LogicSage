//
//  GPT.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/2/23.
//

import Foundation

extension GPT {
    func createAssistant(name: String, description: String, instructions: String, codeInterpreter: Bool, retrievel: Bool, fileIds: [String]? = nil, completion: @escaping (AssistantsResult?) -> Void) {
        // TODO Implement Tools.
        let tools = createToolsArray(codeInterpreter: codeInterpreter, retrieval: retrievel)

        let assistantsQuery = AssistantsQuery(model: Model.gpt4_1106_preview, name: name, description: description, instructions: instructions, tools: tools, fileIds: fileIds)
        self.openAINonBg.assistants(query: assistantsQuery, method: "POST", after: nil) { result in
            switch result {
            case .success(let assistantResult):
                print("Great successs creating assistant. \(assistantResult)")
                completion(assistantResult)

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

    func createToolsArray(codeInterpreter: Bool, retrieval: Bool) -> [Tool] {
        var tools = [Tool]()
        if codeInterpreter {
            tools.append(Tool(toolType: "code_interpreter"))
        }
        if retrieval {
            tools.append(Tool(toolType: "retrieval"))
        }
        return tools
    }
}
