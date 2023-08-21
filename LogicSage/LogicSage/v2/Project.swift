//
//  Project.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/17/23.
//

import Foundation

struct Project: Identifiable, Codable {
    var id = UUID()
    var name: String
    var organizationName: String
    var identifier: String
    var projectTemplate: String
    var location: String
    var fileSystemItems: [FileSystemItem]
}
struct FileSystemItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isDirectory: Bool
    var children: [FileSystemItem]?
}
