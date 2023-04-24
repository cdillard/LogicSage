//
//  AEyes.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/16/23.
//

import Foundation
import Vision
import SwiftyTesseract
import CoreGraphics

let tessaRectTrainingFileLoc = "tessdata_fast-main"
class CustomBundle: LanguageModelDataSource {
  public var pathToTrainedData: String {
     "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)/\(tessaRectTrainingFileLoc)"
  }
}

let lookInterval: TimeInterval = 30.0

let eyes = AEyes()

class AEyes{

}

import SwiftyTesseract

var extractedTexts: [String] = []
func startEyes() {

    // doAccessiblity(procID: getpid())

    let inputQueue = DispatchQueue(label: "capturerQueue")

    inputQueue.async {
        //let image = captureWindowWithTitle("Xcode")
        " Swifty-GPT — AEyes.swift"
        let title = "Swifty-GPT — AEyes.swift"

//        (*App: Xcode, Window title: Swifty-GPT — AEyes.swift*)


        let output = runAppleScript("app_screenshot", withParameter: title)
        multiPrinter("Screenshot saved at:", output)



        if output.hasPrefix("Error") {
            multiPrinter("Error occurred: \(output)")
        } else if output == "Window not found." {
            multiPrinter("Window with title '\(title)' not found.")
        } else {
            let filePath = output
            multiPrinter("Screenshot saved at:", filePath)

            if let cgImage = filePathToCGImage(filePath) {
                multiPrinter("Successfully converted file path to CGImage.")
                // Do something with the CGImage

                let customData = CustomBundle()

                let swiftyTesseract = SwiftyTesseract.Tesseract(language: .english, dataSource: customData, engineMode: .lstmOnly)

                var extractedTexts: [String] = []


                guard let pngCont = cgImage.png else { return multiPrinter("fail")}

                let result = swiftyTesseract.performOCR(on:pngCont)
                switch result {
                case .success(let extractedText):
                    extractedTexts.append(extractedText)
                    multiPrinter("extracted text = \(extractedText)")
                case .failure(let error):
                    multiPrinter("Error performing OCR: \(error.localizedDescription)")
                }


            } else {
                multiPrinter("Failed to convert file path to CGImage.")
            }
        }

        Thread.sleep(forTimeInterval: lookInterval)
    }
}
private var thread: Thread?

func captureWindowWithTitle(_ title: String) -> CGImage? {
    let windowListInfo = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]]

    if let windowInfoList = windowListInfo {
        for windowInfo in windowInfoList {
            if let windowTitle = windowInfo[kCGWindowOwnerName as String] as? String, windowTitle == title {
                if let windowNumber = windowInfo[kCGWindowNumber as String] as? NSNumber {
                    let windowID = CGWindowID(windowNumber.uintValue)
                    let windowBoundsRect = CGRect(dictionaryRepresentation: windowInfo[kCGWindowBounds as String] as! CFDictionary)!
                    let image = CGWindowListCreateImage(windowBoundsRect, .optionIncludingWindow, windowID, .bestResolution)
                    return image
                }
            }
        }
    }

    return nil
}

extension CGImage {
    var png: Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}


import Foundation
import AppKit


func runAppleScript(_ scriptName: String, withParameter parameter: String) -> String {
    let scriptURL = Bundle.main.url(forResource: scriptName, withExtension: "applescript")!
    let task = Process()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = [scriptURL.path, parameter]

    let pipe = Pipe()
    task.standardOutput = pipe

    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    guard let stringData = String(data: data, encoding: .utf8) else {
        multiPrinter("fail") ; return ""

    }

    let output = stringData.trimmingCharacters(in: .whitespacesAndNewlines)

 
    return output
}

func filePathToCGImage(_ filePath: String) -> CGImage? {
    let fileURL = URL(fileURLWithPath: filePath)
    if let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil),
       let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
        return image
    }
    return nil
}

import Foundation
import ApplicationServices

func doAccessiblity(procID: pid_t) {
    let targetApp = AXUIElementCreateApplication(1234) // Replace with target app's process ID
    var appRef: AXUIElement?

}
