//
//  SrcCat.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/20/23.
//
//
import Foundation
import SourceKittenFramework
//
//
func startPurring(filePath: String, cursorOffset: Int) {
    //    // Initialize SourceKit
    //
    //    // Use SourceKit for context-aware suggestions here
    //    // Prepare a code completion request for the SourceKit service

    guard let fileContent = try? String(contentsOfFile: filePath, encoding: .utf8) else {
        multiPrinter("Error: Unable to read the Swift file")
        return
    }

    let request = Request.codeCompletionRequest(file: filePath, contents: fileContent, offset: ByteCount(cursorOffset), arguments: [])
    do {
        let response = try request.send()
        for item in response {

            multiPrinter(item)

        }
    } catch {
        multiPrinter("Error: Unable to get completion suggestions")
    }

}
