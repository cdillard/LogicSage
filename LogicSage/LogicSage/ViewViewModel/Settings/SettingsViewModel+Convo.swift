//
//  SettingsViewModel+Convo.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/8/23.
//

import Foundation
import SwiftUI
extension SettingsViewModel {
    func renameConvo(_ convoId: Conversation.ID, newName: String) {
        print("rename convo id = \(convoId) to \(newName)")
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return
        }
        SettingsViewModel.shared.conversations[conversationIndex].name = newName

        saveConvosToDisk()
    }
    func saveConvosToDisk() {
        saveConversationContentToDisk(object: conversations, forKey: jsonFileName)

    }
    func appendMessageToConvoIndex(index: Int, message: Message) {
        self.conversations[index].model = openAIModel
        self.conversations[index].messages.append(message)
    }
    func setMessageAtConvoIndex(index: Int, existingMessageIndex: Int, message: Message) {
        self.conversations[index].messages[existingMessageIndex] = message
    }
    func nilOutConversationErrorsAt(convoId: Conversation.ID) {
        self.conversationErrors[convoId] = nil
    }
    func setConversationError(convoId: Conversation.ID, error: Error) {
        self.conversationErrors[convoId] = error
    }

    func sendChatText(_ convoID: Conversation.ID, chatText: String) {
        gptCommand(conversationId: convoID, input: chatText)
    }
    func createConversation() -> Conversation.ID {
        let conversation = Conversation(id: idProvider(), messages: [])
        conversations.append(conversation)
        print("created new convo = \(conversation.id)")
        return conversation.id
    }
    func deleteConversation(_ conversationId: Conversation.ID) {
        conversations.removeAll(where: { $0.id == conversationId })
        latestWindowManager?.removeWindowsWithConvoId(convoID: conversationId)
        saveConvosToDisk()
    }
    func createAndOpenNewConvo() {
        let convo = createConversation()
        saveConvosToDisk()
        openConversation(convo)
    }
    func openConversation(_ convoId: Conversation.ID) {
        latestWindowManager?.removeWindowsWithConvoId(convoID: convoId)
        latestWindowManager?.addWindow(windowType: .chat, frame: defChatSize, zIndex: 0, url: defaultURL, convoId: convoId)
    }
    func createAndOpenServerChat() {

        openConversation(Conversation.ID(-1))
    }
    func saveConversationContentToDisk(object: [Conversation], forKey key: String) {

        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(object)

            saveJSONData(encodedData, filename: "\(key).json")
        }
        catch {
            print("failed w error = \(error)")
        }
    }
    func retrieveConversationContentFromDisk(forKey key: String) -> [Conversation]? {

        if let savedData = loadJSONData(filename: "\(key).json") {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode([Conversation].self, from: savedData)
            }
            catch {
                print("failed w error = \(error)")
            }
        }
        return nil
    }
    func loadJSONData(filename: String) -> Data? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            print("Failed to read JSON data: \(error.localizedDescription)")
            return nil
        }
    }
    func saveJSONData(_ data: Data, filename: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
    func getConvo(_ convoId: Conversation.ID) -> Conversation? {
        if let conversation = conversations.first(where: { $0.id == convoId }) {
            return conversation

        }
        return nil
    }
    func convoText(_ newConversations: [Conversation], window: WindowInfo?) -> String {
        var retString  = "model: \(newConversations.first?.model ?? "")"
        if let conversation = newConversations.first(where: { $0.id == window?.convoId }) {
            for msg in conversation.messages {
                retString += "\(msg.role == .user ? savedUserAvatar : savedBotAvatar):\n\(msg.content.trimmingCharacters(in: .whitespacesAndNewlines))\n"
            }
            if conversation.id == Conversation.ID(-1) {
                retString = consoleManagerText
            }

        }
        return retString
    }

    func convoText(_ newConversation: Conversation) -> String {
        var retString  = "model: \(newConversation.model ?? "")"
        for msg in newConversation.messages {
            retString += "\(msg.role == .user ? savedUserAvatar : savedBotAvatar):\n\(msg.content.trimmingCharacters(in: .whitespacesAndNewlines))\n"
        }
        if newConversation.id == Conversation.ID(-1) {
            retString = consoleManagerText
        }
        return retString
    }

    func convoName(_ convoId: Conversation.ID) -> String {
        if let conversation = conversations.first(where: { $0.id == convoId }) {
            return conversation.name ?? String(convoId.prefix(4))
        }

        return "Term"
    }
}
