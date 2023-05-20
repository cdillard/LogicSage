//
//  GPT.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/2/23.
//
//
//  GPT.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

class GPT: NSObject {
    static let shared = GPT()

    let openAI: OpenAI

    override init() {

        let configuration = OpenAI.Configuration(token: OPEN_AI_KEY, timeoutInterval: 120.0)
        //let configuration = OpenAI.Configuration(token: SettingsViewModel.shared.openAIKey, organizationIdentifier: "", timeoutInterval: 120.0)
        openAI = OpenAI(configuration: configuration)

        super.init()
    }

    // Function to send a prompt to GPT via the OpenAI API
    func sendPromptToGPT( conversationId: Conversation.ID, prompt: String, currentRetry: Int, isFix: Bool = false, manualPrompt: Bool = false,
                          voiceOverride: String? = nil, disableSpinner: Bool = false, completion: @escaping (String, Bool, Bool) -> Void) {

        if currentRetry == 0 {
            multiPrinter("👨: \(prompt)")
        }
        else if isFix {
            multiPrinter("💚: Try fix prompt: \(currentRetry) / \(retryLimit) \\n \(prompt)")

        }
        else if manualPrompt {
            multiPrinter("👨: \(manualPrompt)")

        }
        // Look into a better way to handle prompts..... 3
        else {
            multiPrinter("prompt=\(prompt)")
            multiPrinter("👨: Retry same prompt: \(currentRetry) / \(retryLimit)")
        }

//        if !disableSpinner {
//            startRandomSpinner()
//        }

        multiPrinter("Prompting \(prompt.count)...\n🐑🐑🐑\n")

        Task {
            do {
                // TODO: CHECK OUT  "gpt4_32k" and support all future models easily
                let model: Model = gptModel == "gpt-3.5-turbo" ? .gpt3_5Turbo : .gpt4
                var query = ChatQuery(model: model, messages: [.init(role: .user, content: manualPrompt ? config.manualPromptString : prompt)])
                query.stream = true

                let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = self.openAI.chatsStream(
                    query: query
                )
                var completeMessage = ""
                for try await partialChatResult in chatsStream {
                    for choice in partialChatResult.choices {
                        let message = Message(
                            id: partialChatResult.id,
                            role: choice.delta.role ?? .assistant,
                            content: choice.delta.content ?? "",
                            createdAt: Date(timeIntervalSince1970: TimeInterval(partialChatResult.created))
                        )

                        completion(message.content, true, false)
                        completeMessage += message.content
                    }
                }
                completion(completeMessage, true, true)

            }
            catch {
                multiPrinter("failed wit error = \(error)")
            }
        }
    }
}

struct Message {
    var id: String
    var role: Chat.Role
    var content: String
    var createdAt: Date
}

extension Message: Equatable, Codable, Hashable, Identifiable {}

struct Conversation {
    init(id: String, messages: [Message] = []) {
        self.id = id
        self.messages = messages
    }

    typealias ID = String

    let id: String
    var messages: [Message]
}

extension Conversation: Equatable, Identifiable {}
