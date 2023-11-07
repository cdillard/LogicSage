//
//  CommandTable.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation

var commandTable: [String: (String) -> Void] = [
    "0": zeroCommand,

    "1": runAppDesc,
    "2": showLoadedPrompt,

    "3": openProjectCommand,
    "4": buildCommand,
    "build": buildCommand,    "Build": buildCommand,
    "run": runProjectCommand, "Run": runProjectCommand,
    "test": testProjectCommand, "Test": testProjectCommand,

    "5": voiceSettingsCommand,

    "r": runAppDesc,    "R": runAppDesc,

    "s": showLoadedPrompt,  "S": showLoadedPrompt,
    "o": openProjectCommand, "O": openProjectCommand,
    "b": buildCommand, "B": buildCommand,

    "xcode:": xcodeCommand,
    "idea:": ideaCommand,
    "end": endCommand,

    "i": ideaCommand,  "I": ideaCommand,

    "google:": googleCommand,    "Google:": googleCommand,

    "link:": linkCommand,  "Link:": linkCommand,

    "image:": imageCommand,

    "g": gptCommand,     "G": gptCommand,

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
    "stop": stopCommand,  "Stop": stopCommand,
    "say": sayCommand,     "Say": sayCommand,


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
    "debate": debateCommand,     "Debate": debateCommand,
    "debates": debatesCommand,    "Debates": debatesCommand,

    "setLoadMode": setLoadMode,
    "setVoice": setVoice,


    "delete": deleteCommand,
    "del": deleteCommand,
    "globals": globalsCommand,


    // VERY Experimental
    "simulator": simulatorCommand,
    "wallpaper": wallpaperCommand,

    "mirror": mirrorCommand,
    "upload": uploadCommand,
    "download": downloadCommand,

    // Testing
    "testLoad": testLoadCommand,
    "ethics": ethicsCommand,
    // Eggs
    "encourage": encourageCommand,
    "sage": sageCommand,
    "alien": alienCommand,
    "movies": moviesCommand,
]
