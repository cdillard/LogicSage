//
//  StringSLug.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/18/23.
//

import Foundation

func preprocessStringForFilename(_ input: String) -> String {
    // Define a CharacterSet with the characters that are safe for filenames
    let safeCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")

    // Replace any characters not in the safeCharacters set with an underscore
    let safeString = input.unicodeScalars.map { safeCharacters.contains($0) ? String($0) : "_" }.joined()

    return safeString
}
