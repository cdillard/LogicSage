//
//  SettingsViewModel+Convo.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/8/23.
//

import Foundation
import SwiftUI
extension SettingsViewModel {

    func cullToXTokens(_ convoId: Conversation.ID, limit: Int) async {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")
            
            return
        }
        let convo = conversations[conversationIndex]
        var total = 0

        let encoder = try? await Tiktoken.shared.getEncoding("gpt-4")
        for msg in convo.messages {
            if total < 5400 {
                let encoded = encoder?.encode(value: msg.content)
                let length = encoded?.count ?? 0
                total += length
            }
        }

        saveConvosToDisk()

    }

     func tokens(_ convoId: Conversation.ID) async -> Int {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return 0
        }
        let convo = conversations[conversationIndex]
         var total = 0
         let encoder = try? await Tiktoken.shared.getEncoding("gpt-4")
        for msg in convo.messages {
            let encoded = encoder?.encode(value: msg.content)
            let length = encoded?.count ?? 0
            total += length
        }
         return total
    }
    func updateConvoTokenCount(_ convoId: Conversation.ID, tokenCount: Int) {
        print("update convo id = \(convoId) token cnt \(tokenCount)")
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")
            
            return
        }
        SettingsViewModel.shared.conversations[conversationIndex].tokens = tokenCount
    }

    func setHasAddedToolPrompt(_ convoId: Conversation.ID, added: Bool) {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return
        }
        SettingsViewModel.shared.conversations[conversationIndex].hasAddedToolPrompt = added
    }

    func getHasAddedToolPrompt(_ convoId: Conversation.ID) -> Bool {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return false
        }
        return SettingsViewModel.shared.conversations[conversationIndex].hasAddedToolPrompt ?? false
    }


    func renameConvo(_ convoId: Conversation.ID, newName: String) {
        print("rename convo id = \(convoId) to \(newName)")
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return
        }
        SettingsViewModel.shared.conversations[conversationIndex].name = newName

        saveConvosToDisk()

        performConvoUpdate(index: conversationIndex)

    }
    func saveConvosToDisk() {
        saveConversationContentToDisk(object: conversations, forKey: jsonFileName)
    }
    func setSystemPromptIfNeeded(index: Int, systemMessage: String) {
        let msgCount = self.conversations[index].messages.count
        if msgCount == 0 {
            self.conversations[index].messages.insert(Message(
                id: SettingsViewModel.shared.idProvider(),
                role: .system,
                content: systemMessage,
                createdAt: SettingsViewModel.shared.dateProvider()
            ), at: 0)
        }
    }
    func cullEmptyConvos() {
        var newConvos = [Conversation]()

        for convo in conversations where !convo.messages.isEmpty {
            newConvos.append(convo)
        }
        self.conversations = newConvos
    }
    func appendMessageToConvoIndex(index: Int, message: Message) {
        self.conversations[index].model = openAIModel
        self.conversations[index].messages.append(message)
        
        performConvoUpdate(index: index)

    }

    func appendMessageToConvoId(_ convoId: Conversation.ID, message: Message) {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return
        }
        self.conversations[conversationIndex].model = openAIModel
        self.conversations[conversationIndex].messages.append(message)

        performConvoUpdate(index: conversationIndex)

        saveConvosToDisk()
    }


    func setMessageWithConvoId(_ convoId: Conversation.ID, localMessageIndex: Int, message: Message) {
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return
        }
        //TODO: Investigatge model update ass
        
//        self.conversations[conversationIndex].model = openAIModel
        self.conversations[conversationIndex].messages[localMessageIndex] = message

        performConvoUpdate(index: conversationIndex)

        saveConvosToDisk()
    }

    func setMessageAtConvoIndex(index: Int, existingMessageIndex: Int, message: Message) {
        self.conversations[index].messages[existingMessageIndex] = message

        performConvoUpdate(index: index)

    }
    func nilOutConversationErrorsAt(convoId: Conversation.ID) {
        self.conversationErrors[convoId] = nil
    }
    func setConversationError(convoId: Conversation.ID, error: Error) {
        self.conversationErrors[convoId] = error
    }

    func sendChatText(_ convoID: Conversation.ID, chatText: String) {
        let googleAvail = SettingsViewModel.shared.googleAvailable()
        gptCommand(conversationId: convoID, input: chatText, useGoogle: googleAvail, useLink: googleAvail, qPrompt: googleAvail)
    }
    func createConversation(mode: ConvoMode = .chat, assId: String? = nil) -> Conversation.ID {
        let conversation = Conversation(id: idProvider(), messages: [], model: openAIModel, temperature: 0.7, mode: mode, assId: assId)
        conversations.append(conversation)
        print("created new convo = \(conversation.id)")
        return conversation.id
    }
    func deleteConversation(_ conversationId: Conversation.ID) {
        conversations.removeAll(where: { $0.id == conversationId })
        latestWindowManager?.removeWindowsWithConvoId(convoID: conversationId)
        saveConvosToDisk()
    }

    // NEW CONVERSATION (CHAT STREAM)

    func createAndOpenNewConvo() {
        let convo = createConversation()
        saveConvosToDisk()
        openConversation(convo)
    }

    func createAndOpenNewAssConvo(assId: String) {
        let convo = createConversation(mode: .assistant, assId: assId)
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

    func performConvoUpdate(index: Int) {
        let convoId = self.conversations[index].id

        for vm in self.latestWindowManager?.windowViewModels ?? [] {
            if convoId == vm.conversation.id {
                DispatchQueue.main.async {
                    vm.conversation = self.conversations[index]
                }
            }
        }
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
        var retString  = "model: \(newConversations.first?.model ?? "")\nsystem: \(newConversations.first?.systemPrompt ?? "")\n"
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
        let sysText = ""//newConversation.systemPrompt == nil ? "" : "system 🌱: \(newConversation.systemPrompt ?? "")"
        var retString  = "model: \(newConversation.model ?? "")\n\(sysText)\n"


        if let assId = newConversation.assId {
            retString += "Assistant Id: \(assId)\n"
        }

        for msg in newConversation.messages {
            if msg.role == .system && msg.content == "" { continue }
            // TODO: Fix invisible messages
           // if msg.invisible == true { continue }

            retString += "\(avatarTextForRole(role: msg.role)):\n\(msg.content.trimmingCharacters(in: .whitespacesAndNewlines))\n"
        }
        if newConversation.id == Conversation.ID(-1) {
            retString = consoleManagerText
        }
        return retString
    }

    func convoName(_ convoId: Conversation.ID) -> String {
        if let conversation = conversations.first(where: { $0.id == convoId }) {
            if let convoName = conversation.name {
                return convoName
            }
            else {
                if conversation.mode == .assistant {
                    return "New Assistant"
                }
                else {
                    return "New Chat"
                }
            }
        }

        return "Term"
    }

    func setConvoSystemMessage(_ convoId: Conversation.ID, newMessage: String) {
        print("set system messge of  convo id = \(convoId) to \(newMessage)")
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return
        }
        SettingsViewModel.shared.conversations[conversationIndex].systemPrompt = newMessage

        saveConvosToDisk()

        setSystemPromptIfNeeded(index: conversationIndex, systemMessage: newMessage)

        performConvoUpdate(index: conversationIndex)
    }

    func avatarTextForRole(role: Chat.Role) -> String {
        switch role {
        case .system:
            return "system 🌱"
        case .assistant:
            return savedBotAvatar

        case .function:
            return "GPT FUNCTION"

        case .user:
            return savedUserAvatar

        }
    }

    func genTitle(_ convoId: Conversation.ID, force: Bool = false, completion: @escaping (Bool) -> Void) {
        GPT.shared.genTitle(conversationId: convoId, force: force) { content, success, isDone in
            if !success {
                logD("A.P.I. error gen Title, try again.")
                completion(false)

                return
            }

            if !isDone {
            }
            else {
                logD("gen title =  \(content)")

                self.renameConvo(convoId, newName: content)
                completion(true)
            }
        }
    }

    func setTemp(_ convoId: Conversation.ID, newTemp: Double) {
        print("Set convo id = \(convoId) temperature to \(newTemp)")
        guard let conversationIndex = conversations.firstIndex(where: { $0.id == convoId }) else {
            logD("Unable to find conversations id == \(convoId) ... failing")

            return
        }
        SettingsViewModel.shared.conversations[conversationIndex].temperature = newTemp

        saveConvosToDisk()
    }
}
