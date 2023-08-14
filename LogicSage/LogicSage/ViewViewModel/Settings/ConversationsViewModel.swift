//
//  ConversationsViewModel.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/24/23.
//

import Foundation

struct Message {
    var id: String
    var role: Chat.Role
    var content: String
    var createdAt: Date
    var culled: Bool?
}

extension Message: Equatable, Codable, Hashable, Identifiable {}

struct Conversation {
    init(id: String, messages: [Message] = [], model: String? = nil) {
        self.id = id
        self.messages = messages
        self.model = model
    }
    
    typealias ID = String
    
    let id: String
    var messages: [Message]
    
    //Everything fromt his point for must be OPtional so we retain compat with early LogicSage versions.
    var name: String?
    var model: String?
    var systemPrompt: String?
    var tokens: Int?
    var hasAddedToolPrompt: Bool?


}

extension Conversation: Equatable, Codable, Hashable, Identifiable {}
