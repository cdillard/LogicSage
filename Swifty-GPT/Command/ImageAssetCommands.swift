//
//  ImageAssetCommands.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 5/10/23.
//

import Foundation
func simulatorCommand(input: String) {
        multiPrinter("Not implemented... yet")

//    multiPrinter("If No screen recording permission it won't work.")
//    multiPrinter("Open System Settings and go to Privacy & Security > Screen Recording to grant permission.")
   // VideoCapture.shared.captureSimulatorWindow()

}
func pathToWallpapers() -> String {
   "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)/\("Wallpaper")"
}
func wallpaperCommand(input: String) {
    multiPrinter("Performing wallpaper command, this requires you have copied your macs Dynamic Wallpaper to the SWiftyGPTWorkspace/Wallpaper folder.")

    multiPrinter("Please copy image heic files from `/Users/$USERNAME/Library/Application Support/com.apple.mobileAssetDesktop` and `/System/Library/Desktop Pictures` into `SwiftyGPTWorkspace/Wallpaper`")

    let wallpaperFolder = URL(fileURLWithPath:pathToWallpapers())

    if input.isEmpty {

        multiPrinter("searching \(wallpaperFolder)")
        let files = try? listFiles(at: wallpaperFolder)

        multiPrinter("Found \(files?.count ?? 0) wallpapers for choice.")

        multiPrinter("For example: Exec `wallpaper random` for randomw wallpaper.\nExec `wallpaper Big Sur.heic` to get and set wallpaper to `Big Sur.heic`")

        for file in files ?? [] {
            multiPrinter("- \(file.lastPathComponent)")
        }
    }
    else if input == "random" {
        multiPrinter("searching \(wallpaperFolder)")
        let files = try? listFiles(at: wallpaperFolder)

        guard let chosenFile = files?.randomElement() else { return multiPrinter("failed to get random bg") }

        do {
            multiPrinter("Get data at \(chosenFile)")
            let data = try Data(contentsOf: chosenFile)

            multiPrinter("Send chunked file \(chosenFile.lastPathComponent) w/ size \(data)....")

            localPeerConsole.sendImageData(data)
        }
        catch {
            multiPrinter("error setting your random wallpaper")
        }
    }
    else {
        let sanitaryInput = input.replacingOccurrences(of: " ", with: "%20")
        multiPrinter("YOU CHOSE FILE \(sanitaryInput)")

        // sending to connected devices
        let wallpaperFolder = URL(fileURLWithPath:pathToWallpapers())
        let chosenFile = wallpaperFolder.appendingPathComponent(input)
        do {
            multiPrinter("Get data at \(chosenFile)")
            let data = try Data(contentsOf: chosenFile)

            multiPrinter("found \(data) oooo")


            localPeerConsole.sendImageData(data)
        }
        catch {
            multiPrinter("error setting your precious wallpaper")
        }
    }
}
func listFiles(at url: URL) throws -> [URL] {

    let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
    var retDir = [URL]()
    for content in directoryContents {
        retDir.append(content)
    }
    return retDir
}
