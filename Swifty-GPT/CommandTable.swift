//
//  CommandTable.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation
//
//var commandTable: [String: (String) -> Void] = [
//    "0": zeroCommand,
//
//    "1": runAppDesc,
//    "2": showLoadedPrompt,
//    "3": openProjectCommand,
//    "4": closeCommand,
//    "5": fixItCommand,
//    "6": openProjectCommand,
//
//    "r": runAppDesc,
//    "s": showLoadedPrompt,
//    "o": openProjectCommand,  // TODO: If its not set. let them pick one via the Sage task bar item menu.
//    "b": buildCommand,
//    //"x": voiceSettingsCommand,
//
//    "xcode:": xcodeCommand,
//    "idea:": ideaCommand,
//    "i": ideaCommand,
//
//    "google:": googleCommand,
//    "link:": linkCommand,
//
//    "image:": imageCommand,
//    "gpt:": gptCommand,
//    "gptVoice:": gptVoiceCommand,
//    "gv": gptVoiceCommand,
//    "gptFile": gptFileCommand,
//    "gf": gptFileCommand,
//    "ideaFile": ideaFileCommand,
//    "if": ideaFileCommand,
//
//    "q": exitCommand,
//    "exit": exitCommand,
//    "e": exitCommand,
//    "stop": stopCommand,
//    "st": stopCommand,
//    "random": randomCommand,
//    "rand": randomCommand,
//    "prompts": promptsCommand,
//    "p": promptsCommand,
//    "sing": singCommand,
//    "sn": singCommand,
//    "reset": resetCommand,
//    "rs": resetCommand,
//    "commands": commandsCommand,
//    "c": commandsCommand,
//
//    "delete": deleteCommand,
//    "del": deleteCommand,
//    "globals": globalsCommand,
//
//    // Experimental
//    "trivia": triviaCommand,
//    "t": triviaCommand,
//
//    // Testing
//    "testLoad": testLoadCommand,
//
//    // Eggs
//    "encourage": encourageCommand,
//    "sage": sageCommand,
//    "alien": alienCommand,
//    "movies": moviesCommand,
//]

var commandTable: [String: (String) -> Void] = [
    "0": zeroCommand,

    "1": runAppDesc,
    "2": showLoadedPrompt,
    "3": openProjectCommand,
    "4": buildCommand,
    "5": voiceSettingsCommand,

    "r": runAppDesc,
    "s": showLoadedPrompt,
    "o": openProjectCommand,
    "b": buildCommand,
    //"x": voiceSettingsCommand,

    "xcode:": xcodeCommand,
    "idea:": ideaCommand,
    "i": ideaCommand,

    "google:": googleCommand,
    "link:": linkCommand,

    "image:": imageCommand,

    "g": gptCommand,
    "gpt:": gptCommand,
    "gptVoice:": gptVoiceCommand,
    "gv": gptVoiceCommand,
    "gptFile": gptFileCommand,
    "gf": gptFileCommand,
    "ideaFile": ideaFileCommand,
    "if": ideaFileCommand,

    "q": exitCommand,
    "exit": exitCommand,
    "e": exitCommand,
    "stop": stopCommand,
    "st": stopCommand,
    "random": randomCommand,
    "rand": randomCommand,
    "prompts": promptsCommand,
    "p": promptsCommand,
    "sing": singCommand,
    "sn": singCommand,
    "reset": resetCommand,
    "rs": resetCommand,
    "commands": commandsCommand,
    "c": commandsCommand,

    "delete": deleteCommand,
    "del": deleteCommand,
    "globals": globalsCommand,

    // Experimental
    "trivia": triviaCommand,
    "t": triviaCommand,

    // Testing
    "testLoad": testLoadCommand,

    // Eggs
    "encourage": encourageCommand,
    "sage": sageCommand,
    "alien": alienCommand,
    "movies": moviesCommand,
]
