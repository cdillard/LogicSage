//
//  ImageAssetCommands.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 5/10/23.
//

import Foundation

func mirrorCommand(input: String) {

    let inputComps = input.components(separatedBy: " ")
    guard inputComps.count > 1 else {
        multiPrinter("Invalid `mirror` invocation.")
        multiPrinter("Proper mirror syntax is: `mirror ApplicationName WindowName")

        return
    }
    multiPrinter("mirror \(inputComps[0]) \(inputComps[1])")

    multiPrinter("Proper mirror syntax is: `mirror ApplicationName WindowName")
    multiPrinter("If No screen recording permission it won't work.")
    multiPrinter("Open System Settings and go to Privacy & Security > Screen Recording to grant permission.")
    multiPrinter("* Only works running Swifty-GPT from Terminal or iTerm2 *")

    Task {
        await VideoCapture.shared.captureAppWindow(applicationName: inputComps[0], windowName: inputComps[1])
    }

}


func simulatorCommand(input: String) {

    // TODO: ALLOW SELECTION, of simulator, start if not already running

    multiPrinter("If No screen recording permission it won't work.")
    multiPrinter("Open System Settings and go to Privacy & Security > Screen Recording to grant permission.")
    multiPrinter("* Only works running Swifty-GPT from Terminal or iTerm2 *")

    Task {
        await VideoCapture.shared.captureSimulatorWindow()
    }

}
func pathToWallpapers() -> String {
   "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)/\("Wallpaper")"
}
func wallpaperCommand(input: String) {
    multiPrinter("Performing wallpaper command, this requires you have copied your macs Dynamic Wallpaper to the LogicSageWorkspace/Wallpaper folder.")

    multiPrinter("Please copy image heic files from `/Users/$USERNAME/Library/Application Support/com.apple.mobileAssetDesktop` and `/System/Library/Desktop Pictures` into `SwiftyGPTWorkspace/Wallpaper`")

    let wallpaperFolder = URL(fileURLWithPath:pathToWallpapers())

    if input.isEmpty {

        multiPrinter("searching \(wallpaperFolder)")
        let files = try? listFiles(at: wallpaperFolder)

        multiPrinter("Found \(files?.count ?? 0) wallpapers for choice.")

        multiPrinter("For example: Exec `wallpaper random` for randomw wallpaper.\nExec `wallpaper Big Sur.heic` to get and set wallpaper to `Big Sur.heic`")

        for file in files ?? [] {
            multiPrinter("- \(file.lastPathComponent)")
            multiPrinter("\n")

        }
    }
    else if input == "random" || input == "rand" || input == "rand " || input == "random " {
        multiPrinter("searching \(wallpaperFolder)")
        let files = try? listFiles(at: wallpaperFolder)

        guard let chosenFile = files?.randomElement() else { return multiPrinter("failed to get random bg") }

        do {
            multiPrinter("Get data at \(chosenFile)")
            let data = try Data(contentsOf: chosenFile)

            multiPrinter("Send chunked file \(chosenFile.lastPathComponent) w/ size \(data)....")

            localPeerConsole.sendImageData(data, name: chosenFile.lastPathComponent)
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
        if content.pathExtension == "heic" ||
           content.pathExtension == "jpg"  ||
           content.pathExtension == "jpeg" ||
            content.pathExtension == "png" {
            retDir.append(content)
        }
        else {
           // print("non supported image")
        }
    }
    return retDir
}
