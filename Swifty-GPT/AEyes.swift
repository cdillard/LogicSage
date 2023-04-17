//
//  AEyes.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/16/23.
//

import Foundation
import Vision
import SwiftyTesseract

let tessaRectTrainingFileLoc = "tessdata_fast-main"
class CustomBundle: LanguageModelDataSource {
  public var pathToTrainedData: String {
     "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)/\(tessaRectTrainingFileLoc)"
  }
}

let eyes = AEyes()

class AEyes{

}

import SwiftyTesseract

func takeScreenshotOfAppWindows(named appName: String, windowName: String? = nil) -> [String] {
    let task = Process()
    let pipe = Pipe()
    guard let xtermrunnerURL = Bundle.main.url(forResource: "xTermRunner", withExtension: "") else {  print("FAILEd at xTermrunn"); return []  }

    task.executableURL = xtermrunnerURL

    //exectute command
    //
//    let comArr = ["-c", "/opt/X11/bin/xwininfo", "-tree", "-root"]
//    print(comArr)
    //task.arguments = ["arg1", "arg2"]

    task.standardOutput = pipe
    task.standardError = pipe

    task.environment = ProcessInfo.processInfo.environment
    task.environment?["DISPLAY"] = ":0"

    if let xquartzPath = ProcessInfo.processInfo.environment["PATH"]?.split(separator: ":").first(where: { $0.hasSuffix("/XQuartz.app/Contents/MacOS") }) {
        task.environment?["PATH"] = "\(xquartzPath):\(task.environment?["PATH"] ?? "")"
    }

        task.launch()
        task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard !data.isEmpty else {
        return[""]

    }
    guard let output = String(data: data, encoding: .utf8) else {
        print("Error: Unable to get window information")
        return []
    }

    print("xq: \(output)")
    let windowPairs = extractWindowInfo(from: output)


    //et matches = regex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count))
  //  var windowIDs: [String] = []
//
//    for match in matches {
//        let windowIDRange = match.1
//        let windowID = (output as NSString).substring(with: windowIDRange)
//        windowIDs.append(windowID)
//    }
    let customData = CustomBundle()

    let swiftyTesseract = SwiftyTesseract.Tesseract(language: .english, dataSource: customData, engineMode: .lstmOnly)

    var extractedTexts: [String] = []

    // namwe look like Swifty-GPT -- SWifty-GPT.xcodepoj
    print("windowPairs = \(windowPairs)")
    for windowPair in windowPairs {
        let index = Int.random(in: 0..<90000)
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)"

        let screenShot = "\(projectPath)/picture-\(index)\(".png")"

        let tempFile = URL(fileURLWithPath: screenShot)

        if (windowPair.isEmpty){ continue}
        print("windowPair = \(windowPair), loading screenshot = \(tempFile)")
        let contents = executeXwininfoScreencapture(windowID: windowPair[0], tempFile: tempFile)
        guard let contents = contents else { continue  }
//            let imageData = try Data(contentsOf: URL(fileURLWithPath: contents))

            guard let data = contents.data(using: .utf8) else { continue }
            let result = swiftyTesseract.performOCR(on: data)
            switch result {
            case .success(let extractedText):
                extractedTexts.append(extractedText)
            case .failure(let error):
                print("Error performing OCR: \(error.localizedDescription)")
            }
            do {
                try FileManager.default.removeItem(at: tempFile)
            }
            catch {
                print("fail")
            }

    }

    return extractedTexts
}

func executeXwininfoScreencapture(windowID: String, tempFile: URL) -> String? {
    let task = Process()
    let pipe = Pipe()

    guard let xtermrunnerURL = Bundle.main.url(forResource: "xTermRunner", withExtension: "") else {  print("FAILEd at xTermrunn"); return ""  }

    task.executableURL = xtermrunnerURL
    //
    //    let comArr = ["-c", "/opt/X11/bin/xwininfo", "-id", "\(windowID)", "-root", "-tree", "-all", "-frame", "-shape" ,"-extents", "-size" ,"-stats", "-wm", "-events", "-version"] //["-c", "/opt/X11/bin/xwininfo", "-tree", "-root"]
    // print(comArr)

    if (!windowID.isEmpty) {
        task.arguments = ["\(windowID)"]
    }
    task.standardOutput = pipe
    task.environment = ProcessInfo.processInfo.environment
    task.environment?["DISPLAY"] = ":0"

    if let xquartzPath = ProcessInfo.processInfo.environment["PATH"]?.split(separator: ":").first(where: { $0.hasSuffix("/XQuartz.app/Contents/MacOS") }) {
        task.environment?["PATH"] = "\(xquartzPath):\(task.environment?["PATH"] ?? "")"
    }

    do {
        try task.run()
        task.waitUntilExit()

        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()

        let outputString = String(data: outputData, encoding: .utf8)

        if !windowID.isEmpty {
            let imageTask = Process()
            imageTask.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/import")
            imageTask.arguments = ["-window", "\(windowID)", tempFile.path]

            
            try imageTask.run()
            imageTask.waitUntilExit()
            print("Screenshot saved to: \(tempFile.path)")
        }

        return outputString
    } catch {
        print("Error: \(error.localizedDescription)")
        return nil
    }
}


func startEyes() {
    let appName = "Xcode"
    let specificWindowName = "Swifty-GPT -- Swifty-GPT.xcodepoj"
//    let projectName = "Swifty-GPT"

    let texts = takeScreenshotOfAppWindows(named: appName, windowName: specificWindowName)

    print("Texts from app windows named '\(appName)' ")
    print("Texts from app windows named '\(appName)' with specific window name '\(specificWindowName)':")
    for (index, text) in texts.enumerated() {
        print("Window \(index + 1):")
        print(text)
    }

}

func extractWindowInfo(from outputString: String) -> [[String]] {
    var ids: [String] = []
    var names: [String] = []

    let lines = outputString.split(separator: "\n")
    let windowIDRegex = try! NSRegularExpression(pattern: "^\\s*0x([0-9a-fA-F]+)\\s+")
    let windowNameRegex = try! NSRegularExpression(pattern: "^\\s*\\\"(.*)\\\"$")

    for line in lines {
        if let lineString = String(line).removingPercentEncoding {
            let idMatches = windowIDRegex.matches(in: lineString, options: [], range: NSRange(location: 0, length: lineString.count))
            let nameMatches = windowNameRegex.matches(in: lineString, options: [], range: NSRange(location: 0, length: lineString.count))

            if let idMatch = idMatches.first, idMatch.numberOfRanges == 2 {
                let idRange = idMatch.range(at: 1)
                let id = (lineString as NSString).substring(with: idRange)
                ids.append(id)
            }

            if let nameMatch = nameMatches.first, nameMatch.numberOfRanges == 2 {
                let nameRange = nameMatch.range(at: 1)
                let name = (lineString as NSString).substring(with: nameRange)
                names.append(name)
            }
        }
    }

    return [ids, names]
}
