//
//  SageMultiViewModel.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/9/23.
//

import Foundation
#if !os(macOS)
private var lastConsoleUpdate = Date()
class SageMultiViewModel: ObservableObject, Identifiable {
    let id = UUID()
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var windowManager: WindowManager

    @Published var windowId: UUID

    @Published var sourceCode: String
    @Published var changes: [ChangeRow] = []

    var originalSourceCode: String
    @Published var windowInfo: WindowInfo
    @Published var position: CGSize = .zero
    @Published var viewSize: CGRect = .zero
    @Published var resizeOffset: CGSize = .zero
    @Published var frame: CGRect
    @Published var conversation: Conversation?

    @State var webViewStore = WebViewStore()
    @State private var navigationInProgress = false

    static func convoText(_ settingsViewModel: SettingsViewModel, _ conversation: Conversation?, windowInfo: WindowInfo) -> String {
        if windowInfo.convoId == Conversation.ID(-1) {
            return settingsViewModel.consoleManagerText
        }
        else if let conversation {
            return settingsViewModel.convoText(conversation)
        }
        else {
            return windowInfo.fileContents

        }
    }

    init(settingsViewModel: SettingsViewModel, windowId: UUID, windowManager: WindowManager, windowInfo: WindowInfo, frame: CGRect, conversation: Conversation?) {
        self.settingsViewModel = settingsViewModel
        self.windowId = windowId
        self.windowManager = windowManager
        self.windowInfo = windowInfo

        self.sourceCode =  SageMultiViewModel.convoText(settingsViewModel, conversation, windowInfo: windowInfo)

        self.originalSourceCode = windowInfo.fileContents
        self.frame = frame

        self.conversation = conversation
    }

    func refreshChanges(newText: String) {
        DispatchQueue.global(qos: .default).async {
            let calcChange = getLineChanges(original: self.originalSourceCode, edited: newText)
           DispatchQueue.main.async {
                self.changes = calcChange
           }
        }
    }

    func getConvoText() -> String {
        SageMultiViewModel.convoText(settingsViewModel, conversation, windowInfo: windowInfo)
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
