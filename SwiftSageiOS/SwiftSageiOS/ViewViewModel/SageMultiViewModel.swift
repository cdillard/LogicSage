//
//  SageMultiViewModel.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/9/23.
//

import Foundation
#if !os(macOS)

class SageMultiViewModel: ObservableObject {
    @Published var windowInfo: WindowInfo
    @Published var sourceCode: String
    @Published var changes: [ChangeRow] = []
    
    var originalSourceCode: String

    init(windowInfo: WindowInfo) {
        self.windowInfo = windowInfo
        self.sourceCode = windowInfo.fileContents
        self.originalSourceCode = windowInfo.fileContents
    }

    func refreshChanges(newText: String) {
        DispatchQueue.global(qos: .default).async {
            let calcChange = getLineChanges(original: self.originalSourceCode, edited: newText)
           DispatchQueue.main.async {
                self.changes = calcChange
           }
        }
    }
}
#endif

import SwiftUI

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
