//
//  ImageAssetCommands.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 5/10/23.
//

import Foundation
import ZIPFoundation

// Replace contents of swifty-gpt workspace with provided zip contents
func uploadCommand(input: String) {
    multiPrinter("performing uploading")
}
func downloadCommand(input: String) {
    multiPrinter("performing downloading")


    // zip swiftygptworkspace/workspace
    do {
        do {
            try FileManager.default.removeItem(atPath: pathToOutputArchiveOfWorkspace())
        }
        catch {
            multiPrinter("failed to zip workspace")
        }
        let inputDir = URL(fileURLWithPath: pathToWorkspace())
        let outputArchiveURL = URL(fileURLWithPath: pathToOutputArchiveOfWorkspace())

        try FileManager.default.zipItem(at: inputDir, to: outputArchiveURL)

        multiPrinter("zip success")

        do {
            let data = try Data(contentsOf: outputArchiveURL)
            multiPrinter("got data from url zip success")

            localPeerConsole.sendWorkspaceData(data)
            multiPrinter("sendWorkspaceData success")

        }
        catch {
            multiPrinter("failed to get data")
        }

    }
    catch {
        multiPrinter("failed to zip workspace")
    }
}
func pathToWorkspace() -> String {
   "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/"
}
func pathToOutputArchiveOfWorkspace() -> String {
   "\(getWorkspaceFolder())\("workspace_archive.zip")"
}
