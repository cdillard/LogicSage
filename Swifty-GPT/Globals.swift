//
//  Globals.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/19/23.
//

import Foundation

// Main.swift Sema
let sema = DispatchSemaphore(value: 0)

var projectName = "MyApp"
var globalErrors = [String]()
var manualPromptString = ""
var blockingInput = true
var promptingRetryNumber = 0

var lastFileContents = [String]()
var lastNameContents = [String]()
var searchResultHeadingGlobal: String?
var linkResultGlobal: String?

var appName: String? //= "MyApp"
var appType = "iOS"
var language = "Swift"


// Trivia
var chosenTQ: TriviaQuestion?
var streak = 0
