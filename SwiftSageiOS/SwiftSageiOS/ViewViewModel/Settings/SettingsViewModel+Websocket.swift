//
//  SettingsViewModel+Websocket.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 6/8/23.
//

import Foundation
import SwiftUI

extension SettingsViewModel {

    func recieveImageData(recievedImageData: Data?) {
#if !os(macOS)

        actualReceivedImage = UIImage(data: recievedImageData  ?? Data())
        if let  receivedWallpaperFileName, let receivedImageData {
            let receivedWallpaperFileName = receivedWallpaperFileName.replacingOccurrences(of: " ", with: "%20")
            // print("REC -- going to write -- \(receivedWallpaperFileName) c: \(receivedWallpaperFileSize ?? 0)")

            do {
                try FileManager.default.createDirectory(at: getDocumentsDirectory().appendingPathComponent("LogicSageWallpapers"), withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("fail to create LogicSageWallpapers dir")
            }

            let fileURL = getDocumentsDirectory().appendingPathComponent("LogicSageWallpapers/\(receivedWallpaperFileName)")


            do {
                try FileManager.default.removeItem(at: fileURL)
            }
            catch {
                print("didnt rmv or exist old m")
            }

            do {
                try receivedImageData.write(to: fileURL)

                print("Successfully wrote out wallpaper  \(fileURL)")
                logD("LogicSage set your wallpaper.")
            }
            catch {
                print("Failed to write out rec wallpaper")
            }

            self.receivedWallpaperFileName = nil
            receivedWallpaperFileSize = nil

            refreshDocuments()
        }
#endif
    }

    func recieveWorkspaceData(receivedWorkspaceData: Data) {
#if !os(macOS)

        logD("received workspace data of size = \(receivedWorkspaceData.count)")
        let fileURL = getDocumentsDirectory().appendingPathComponent("workspace_archive.zip")

        do {
            try FileManager.default.removeItem(at: fileURL)

        }
        catch {
            logD("fil enot exist or deketed")
        }
        do {
            try receivedWorkspaceData.write(to: fileURL)

            logD("wrote file \(fileURL) out successfully")
            let existingExtraction = getDocumentsDirectory().appendingPathComponent("Workspace")

            do {
                try FileManager.default.removeItem(at:  existingExtraction)
            }
            catch {
                logD("did not delete or didn't exist old REPO")
            }
            let myProgress = Progress()
            do {
                // Workspace is already included in this folder.
                try FileManager.default.unzipItem(at: fileURL, to: getDocumentsDirectory(), progress: myProgress)

                logD("unzipped to \(existingExtraction) successfully")

                do {
                    try FileManager.default.removeItem(at:  fileURL)
                }
                catch {
                    print("did not delete or didn't exist old REPO")
                }

                self.refreshDocuments()
            }
            catch {
                logD("failed to unzip workspace")
            }
        }
        catch {
            logD("failed to write out zip")
        }
#endif

    }
}
