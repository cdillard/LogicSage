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


var conversation: Conversation?

class GPT {
    static let shared = GPT()

    let openAI: OpenAI

    init() {

        let configuration = OpenAI.Configuration(token: OPEN_AI_KEY, timeoutInterval: 120.0)
        //let configuration = OpenAI.Configuration(token: SettingsViewModel.shared.openAIKey, organizationIdentifier: "", timeoutInterval: 120.0)
        openAI = OpenAI(configuration: configuration)

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
                let model: Model = Model(gptModel)

                var query = ChatQuery(model: model, messages: [.init(role: .system, content: manualPrompt ? config.manualPromptString : prompt)])
                query.stream = true
                
                let msgContent = manualPrompt ? config.manualPromptString : prompt;

                let messages = [ Message(
                    id: UUID().uuidString,
                    role: .user,
                    content: msgContent,
                    createdAt: Date()
                )]
                if conversation != nil {
                    conversation?.messages.append(messages.first!)
                }
                var convo = conversation == nil ? Conversation(id: UUID().uuidString, messages: messages) : conversation!

                conversation = convo

                let useTemp = convo.temperature == nil ? 0.7 : convo.temperature ?? 0.7
                let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = self.openAI.chatsStream(
                    query: ChatQuery(
                        model: model,
                        messages: convo.messages.map { message in
                            Chat(role: message.role, content: message.content)
                        },
                        temperature: useTemp
                    )
                )

                var completeMessage = ""
                for try await partialChatResult in chatsStream {
                    for choice in partialChatResult.choices {
                        let existingMessages = convo.messages

                        let message = Message(
                            id: partialChatResult.id,
                            role: choice.delta.role ?? .assistant,
                            content: choice.delta.content ?? "",
                            createdAt: Date(timeIntervalSince1970: TimeInterval(partialChatResult.created))
                        )

                        if let existingMessageIndex = existingMessages.firstIndex(where: { $0.id == partialChatResult.id }) {
                            // Meld into previous message
                            let previousMessage = existingMessages[existingMessageIndex]
                            let combinedMessage = Message(
                                id: message.id, // id stays the same for different deltas
                                role: message.role,
                                content: previousMessage.content + message.content,
                                createdAt: message.createdAt
                            )
                            //logD("melding to existing msg")
                            conversation?.messages[existingMessageIndex] = combinedMessage
//                            conversation?.messages.append(combinedMessage)

                           // SettingsViewModel.shared.setMessageAtConvoIndex(index: conversationIndex, existingMessageIndex: existingMessageIndex, message: combinedMessage)

                        } else {
                            //logD("append to existing msg")
                            conversation?.messages.append(message)
                           // SettingsViewModel.shared.appendMessageToConvoIndex(index: conversationIndex, message: message)
                        }

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
    init(id: String, messages: [Message] = [], temperature: Double? = nil) {
        self.id = id
        self.messages = messages
        self.temperature = temperature
    }

    typealias ID = String

    let id: String
    var messages: [Message]
    var temperature: Double?
}

extension Conversation: Equatable, Identifiable {}
