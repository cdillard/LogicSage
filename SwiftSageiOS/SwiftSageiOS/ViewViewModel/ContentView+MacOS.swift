//
//  ContentView+MacOS.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/28/23.
//

import Foundation
import SwiftUI
import Combine

#if !os(macOS)
import UIKit
#endif

#if os(macOS)
func openTerminal() {
    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") {
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
    }
}

func openiTerm2() {
    if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.googlecode.iterm2") {
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
    }
}

func openTerminalAndRunCommand(command: String) {
    let scriptContent = "#!/bin/sh\n" +
    "\(command)\n"

    do {
        let tempDirectory = FileManager.default.temporaryDirectory
        let appDirectory = tempDirectory.appendingPathComponent("SwiftSageiOS")
        try FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)

        let scriptURL = appDirectory.appendingPathComponent("temp_script.sh")
        try scriptContent.write(to: scriptURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: NSNumber(value: 0o755)], ofItemAtPath: scriptURL.path)

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = [scriptURL.path]
        configuration.promptsUserIfNeeded = true
        if let terminalURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") {
            NSWorkspace.shared.openApplication(at: terminalURL, configuration: configuration, completionHandler: nil)
        }
    } catch {
        logD("Error: \(error)")
    }
}

#endif
