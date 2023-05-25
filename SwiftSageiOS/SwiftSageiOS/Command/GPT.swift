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

class GPT {
    static let shared = GPT()

    let openAI: OpenAI

    init() {
        let configuration = OpenAI.Configuration(token: SettingsViewModel.shared.openAIKey, timeoutInterval: 120.0)
        openAI = OpenAI(configuration: configuration)
    }

    // Function to send a prompt to GPT via the OpenAI API
    func sendPromptToGPT(conversationId: Conversation.ID,
                         prompt: String, currentRetry: Int, isFix: Bool = false,
                         manualPrompt: Bool = false, voiceOverride: String? = nil,
                         disableSpinner: Bool = false, completion: @escaping (String, Bool, Bool) -> Void) {

        if currentRetry == 0 {
            logD("👨: \(prompt)")
        }
        else if isFix {
            logD("💚: Try fix prompt: \(currentRetry) / \(retryLimit) \\n \(prompt)")

        }
        else if manualPrompt {
            logD("👨: \(manualPrompt)")

        }
        // Look into a better way to handle prompts..... 3
        else {
            logD("prompt=\(prompt)")
            logD("👨: Retry same prompt: \(currentRetry) / \(retryLimit)")
        }

        if !disableSpinner {
            startRandomSpinner()
        }

        logD("Prompting \(prompt.count)...\n🐑🐑🐑\n")

        Task {
            defer {
                if !disableSpinner {
                    stopRandomSpinner()
                }
            }
            guard let conversationIndex = await SettingsViewModel.shared.conversations.firstIndex(where: { $0.id == conversationId }) else {
                logD("Unable to find conversations id == \(conversationId) ... failing")

                return
            }

            await SettingsViewModel.shared.appendMessageToConvoIndex(index: conversationIndex, message: Message(
                id: SettingsViewModel.shared.idProvider(),
                role: .user,
                content: manualPrompt ? config.manualPromptString : prompt,
                createdAt: SettingsViewModel.shared.dateProvider()
            ))
            
            guard let conversation = await SettingsViewModel.shared.conversations.first(where: { $0.id == conversationId }) else {
                logD("Unable to find conversations id == \(conversationId) ... failing")

                return
            }

            await SettingsViewModel.shared.nilOutConversationErrorsAt(convoId: conversationId)
            
            do {
                let model: Model = await Model(SettingsViewModel.shared.openAIModel)

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

                    if !disableSpinner {
                        stopRandomSpinner()
                    }

                    for choice in partialChatResult.choices {
                        let existingMessages = await SettingsViewModel.shared.conversations[conversationIndex].messages
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
                            //                            logD("melding to existing msg")

                            await SettingsViewModel.shared.setMessageAtConvoIndex(index: conversationIndex, existingMessageIndex: existingMessageIndex, message: combinedMessage)

                        } else {
                            //                            logD("append to existing msg")

                            await SettingsViewModel.shared.appendMessageToConvoIndex(index: conversationIndex, message: message)
                        }

                        // old hndlers
                        completion(message.content, true, false)
                        completeMessage += message.content
                    }
                }
                completion(completeMessage, true, true)

            }
            catch {
                logD("failed wit error = \(error)")
                await SettingsViewModel.shared.setConversationError(convoId: conversationId, error: error)
            }
        }
    }
}


