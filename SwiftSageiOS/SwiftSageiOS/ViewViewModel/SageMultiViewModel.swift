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

struct ChangeRow: Identifiable {
    var id = UUID()
    var oldLine: String
    var newLine: String
}
func getLineChanges(original: String, edited: String) -> [ChangeRow] {
    let originalLines = original.split(separator: "\n")
    let editedLines = edited.split(separator: "\n")
    var changes: [ChangeRow] = []
    for (index, (originalLine, editedLine)) in zip(originalLines, editedLines).enumerated() {
        if originalLine != editedLine {
            changes.append(ChangeRow(oldLine: String(originalLine), newLine: String(editedLine)))
        }
    }
    if originalLines.count < editedLines.count {
        for line in editedLines[originalLines.count...] {
            changes.append(ChangeRow(oldLine: "", newLine: String(line)))
        }
    } else if originalLines.count > editedLines.count {
        for line in originalLines[editedLines.count...] {
            changes.append(ChangeRow(oldLine: String(line), newLine: ""))
        }
    }
    return changes
}
