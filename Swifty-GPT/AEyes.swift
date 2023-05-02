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

func startEyes() {

}
