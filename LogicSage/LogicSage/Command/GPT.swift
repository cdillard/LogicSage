//
//  GPT.swift
//  LogicSage
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

class GPT {
    static let shared = GPT()

    var openAI: OpenAI

    init() {
        let host = SettingsViewModel.shared.openAIHost

        let configuration = OpenAI.Configuration(token: SettingsViewModel.shared.openAIKey, host: host, timeoutInterval: 120.0)
        let identifier = "\(bundleID)bger"
        let urlConfig = URLSessionConfiguration.background(withIdentifier: identifier)
        let session = URLSession(configuration: urlConfig)

        openAI = OpenAI(configuration: configuration, session: session)

        print("reset openAI global to host = \(host)")

    }

    func resetOpenAI() {
        let host = SettingsViewModel.shared.openAIHost
        let configuration = OpenAI.Configuration(token: SettingsViewModel.shared.openAIKey, host: host,timeoutInterval: 120.0)
        let identifier = "\(bundleID)bger"
        let urlConfig = URLSessionConfiguration.background(withIdentifier: identifier)
        let session = URLSession(configuration: urlConfig)

        openAI = OpenAI(configuration: configuration, session: session)
        print("reset openAI global to host = \(host)")
    }

    // Function to send a prompt to GPT via the OpenAI API
    func sendPromptToGPT(conversationId: Conversation.ID,
                         prompt: String, currentRetry: Int, isFix: Bool = false, role: Chat.Role = .user,
                         manualPrompt: Bool = false, voiceOverride: String? = nil,
                         completion: @escaping (String, Bool, Bool) -> Void) {
        if currentRetry == 0 {
            print("👨: \(prompt)")
        }
        else if isFix {
            print("💚: Try fix prompt: \(currentRetry) / \(retryLimit) \\n \(prompt)")

        }
        else if manualPrompt {
            print("👨: \(manualPrompt)")

        }
        else {
            print("prompt=\(prompt)")
            print("👨: Retry same prompt: \(currentRetry) / \(retryLimit)")
        }

        print("Prompting \(prompt.count)...\n🐑🐑🐑\n")

        guard let conversationIndex = SettingsViewModel.shared.conversations.firstIndex(where: { $0.id == conversationId }) else {
            logD("Unable to find conversations id == \(conversationId) ... failing")

            return
        }

        Task {
            SettingsViewModel.shared.appendMessageToConvoIndex(index: conversationIndex, message: Message(
                id: SettingsViewModel.shared.idProvider(),
                role: role,
                content: manualPrompt ? config.manualPromptString : prompt,
                createdAt: SettingsViewModel.shared.dateProvider()
            ))
            guard let conversation = SettingsViewModel.shared.conversations.first(where: { $0.id == conversationId }) else {
                logD("Unable to find conversations id == \(conversationId) ... failing")

                return
            }


            SettingsViewModel.shared.setSystemPromptIfNeeded(index: conversationIndex, systemMessage: conversation.systemPrompt ?? "")

            guard let conversation = SettingsViewModel.shared.conversations.first(where: { $0.id == conversationId }) else {
                logD("Unable to find conversations id == \(conversationId) ... failing")

                return
            }

            SettingsViewModel.shared.nilOutConversationErrorsAt(convoId: conversationId)

            do {
                let existingModel = conversation.model ?? ""

                let model: Model = Model(existingModel.isEmpty ? SettingsViewModel.shared.openAIModel : existingModel)

                let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = self.openAI.chatsStream(
                    query: ChatQuery(
                        model: model,
                        messages: conversation.messages.map { message in
                            Chat(role: message.role, content: message.content)
                        }
                    )
                )
                var completeMessage = ""
                for try await partialChatResult in chatsStream {
                    for choice in partialChatResult.choices {
                        let existingMessages = SettingsViewModel.shared.conversations[conversationIndex].messages

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

                            SettingsViewModel.shared.setMessageAtConvoIndex(index: conversationIndex, existingMessageIndex: existingMessageIndex, message: combinedMessage)

                        } else {
                            //logD("append to existing msg")

                            SettingsViewModel.shared.appendMessageToConvoIndex(index: conversationIndex, message: message)
                        }

                        // old hndlers
                        completion(message.content, true, false)
                        completeMessage += message.content
                    }
                }

                //logD("completed message w/ length = \(completeMessage.count)")

                completion(completeMessage, true, true)

            }
            catch {
                logD("failed wit error = \(error)")
                SettingsViewModel.shared.setConversationError(convoId: conversationId, error: error)
            }
        }
    }

    // GEN TITLE

    func genTitle(conversationId: Conversation.ID,
                  force: Bool = false,
                  completion: @escaping (String, Bool, Bool) -> Void) {

        print("BRAIN: generate title for convo = \(conversationId)")

        Task {
            guard let conversation = SettingsViewModel.shared.conversations.first(where: { $0.id == conversationId }) else {
                logD("Unable to find conversations id == \(conversationId) ... failing")

                return
            }

            var existingMsgs = [
                Message(id: UUID().uuidString, role: .system, content: "You should summarize the chat messages I send into a short chat title Only return the summarized sentence no more than 6-8 words and no explanation.", createdAt: Date())
            ]

            existingMsgs += Array(conversation.messages.filter { $0.role != .system }.prefix(2))


            guard force || conversation.messages.filter { $0.role != .system }.count <= 3 else {
                print("exit gen title because force or existing msg count")
                return
            }

            do {
                let model: Model = Model.gpt3_5Turbo

                let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = self.openAI.chatsStream(
                    query: ChatQuery(
                        model: model,
                        messages: existingMsgs.map { message in
                            Chat(role: message.role, content: message.content)
                        }
                    )
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

                        // old hndlers
                        completion(message.content, true, false)
                        completeMessage += message.content
                    }
                }
                completion(completeMessage, true, true)
            }
            catch {
                logD("failed 2 gen convo title wit error = \(error)")
            }
        }
    }

}
