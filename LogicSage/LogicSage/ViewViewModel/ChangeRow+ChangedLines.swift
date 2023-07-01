//
//  ChangeRow+ChangedLines.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/30/23.
//

import Foundation
struct ChangeRow: Identifiable, Equatable {
    var id = UUID()
    var oldLine: String?
    var newLine: String?
    var lineNumber: Int
}

func getLineChanges(original: String, edited: String) -> [ChangeRow] {
    let originalLines = original.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    let editedLines = edited.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

    var changes: [ChangeRow] = []
    var oldIndex = 0
    var newIndex = 0

    while oldIndex < originalLines.count && newIndex < editedLines.count {
        if originalLines[oldIndex].trimmingCharacters(in: .whitespacesAndNewlines) == editedLines[newIndex].trimmingCharacters(in: .whitespacesAndNewlines) {
            oldIndex += 1
            newIndex += 1
        } else if editedLines[newIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            changes.append(ChangeRow(oldLine: nil, newLine: editedLines[newIndex], lineNumber: newIndex + 1))
            newIndex += 1
        } else if originalLines[oldIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            changes.append(ChangeRow(oldLine: originalLines[oldIndex], newLine: nil, lineNumber: oldIndex + 1))
            oldIndex += 1
        } else {
            changes.append(ChangeRow(oldLine: originalLines[oldIndex], newLine: editedLines[newIndex], lineNumber: newIndex + 1))
            oldIndex += 1
            newIndex += 1
        }
    }

    while newIndex < editedLines.count {
        changes.append(ChangeRow(oldLine: nil, newLine: editedLines[newIndex], lineNumber: newIndex + 1))
        newIndex += 1
    }

    while oldIndex < originalLines.count {
        changes.append(ChangeRow(oldLine: originalLines[oldIndex], newLine: nil, lineNumber: oldIndex + 1))
        oldIndex += 1
    }

    return changes
}
