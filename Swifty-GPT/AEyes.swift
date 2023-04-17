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
        print("Screenshot saved at:", output)



        if output.hasPrefix("Error") {
            print("Error occurred: \(output)")
        } else if output == "Window not found." {
            print("Window with title '\(title)' not found.")
        } else {
            let filePath = output
            print("Screenshot saved at:", filePath)

            if let cgImage = filePathToCGImage(filePath) {
                print("Successfully converted file path to CGImage.")
                // Do something with the CGImage

                let customData = CustomBundle()

                let swiftyTesseract = SwiftyTesseract.Tesseract(language: .english, dataSource: customData, engineMode: .lstmOnly)

                var extractedTexts: [String] = []


                guard let pngCont = cgImage.png else { return print("fail")}

                let result = swiftyTesseract.performOCR(on:pngCont)
                switch result {
                case .success(let extractedText):
                    extractedTexts.append(extractedText)
                    print("extracted text = \(extractedText)")
                case .failure(let error):
                    print("Error performing OCR: \(error.localizedDescription)")
                }


            } else {
                print("Failed to convert file path to CGImage.")
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
//
//func runAppleScript(_ scriptName: String, withParameter parameter: String) -> String {
//
//
//    let kASAppleScriptSuite: OSType = 0x61736372 // 'ascr'
//    let kASSubroutineEvent: OSType = 0x70736420 // 'psd '
//    let kAutoGenerateReturnID: Int32 = -1
//    let kAnyTransactionID: Int32 = 0
//    let keyASSubroutineName: OSType = 0x73636E61 // 'scna'
//    let keyDirectObject: OSType = 0x2d2d2d2d // '----'
//
//    let scriptURL = Bundle.main.url(forResource: scriptName, withExtension: "scpt")!
//    let appleScript = try! NSUserAppleScriptTask(url: scriptURL)
//
//    let event = NSAppleEventDescriptor(eventClass: UInt32(kASAppleScriptSuite), eventID: UInt32(kASSubroutineEvent), targetDescriptor: nil, returnID: Int16(kAutoGenerateReturnID), transactionID: AETransactionID(Int16(kAnyTransactionID)))
//    event.setParam(NSAppleEventDescriptor(string: "capture_window_by_title"), forKeyword: UInt32(keyASSubroutineName))
//
//    let parameters = NSAppleEventDescriptor.list()
//    parameters.insert(NSAppleEventDescriptor(string: parameter), at: 0)
//    event.setParam(parameters, forKeyword: UInt32(keyDirectObject))
//
//    appleScript.execute(withAppleEvent: event) {
//        (result, err) in
//           if let err = err {
//               print("Error executing AppleScript: \(err)")
//           } else if let result = result {
//               print("Result: \(result.stringValue ?? "No result")")
//           }
//           exit(0)
//       }
//
//
//
//
//    RunLoop.main.run()
//    return ""
//}

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
        print("fail") ; return ""

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


//    AXUIElementCopyAttributeValue(targetApp, kAXFocusedApplicationAttribute as CFString, appRef as AnyObject? as! UnsafeMutablePointer<CFTypeRef?>)
//
//    if let appRef = appRef {
//        var titleRef: CFTypeRef?
//        AXUIElementCopyAttributeValue(appRef, kAXTitleAttribute as CFString, &titleRef)
//        if let titleRef = titleRef as? String {
//            print(titleRef)
//        }
//    }
}
