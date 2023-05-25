//
//  ConversationsViewModel.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/24/23.
//

import Foundation

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

extension Conversation: Equatable, Codable, Hashable, Identifiable {}
