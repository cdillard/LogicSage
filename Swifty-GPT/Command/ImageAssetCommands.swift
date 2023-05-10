//
//  ImageAssetCommands.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 5/10/23.
//

import Foundation
func simulatorCommand(input: String) {
    multiPrinter("If No screen recording permission it won't work.")
    multiPrinter("Open System Settings and go to Privacy & Security > Screen Recording to grant permission.")
    VideoCapture.shared.captureSimulatorWindow()

}
func pathToWallpapers() -> String {
   "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)/\("Wallpaper")"
}
func wallpaperCommand(input: String) {
    multiPrinter("Performing wallpaper command, this requires you have copied your macs Dynamic Wallpaper to the SWiftyGPTWorkspace/Wallpaper folder.")

    let wallpaperFolder = URL(fileURLWithPath:pathToWallpapers())

    multiPrinter("searching \(wallpaperFolder)")
    let files = try? listFiles(at: wallpaperFolder)

    multiPrinter("Found \(files?.count ?? 0) wallpapers for choice.")

}
func listFiles(at url: URL) throws -> [URL] {

    let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
    var retDir = [URL]()
    for content in directoryContents {
        retDir.append(content)
    }
    return retDir
}
