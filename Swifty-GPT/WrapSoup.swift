//
//  WrapSoup.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/20/23.
//

import Foundation
import SwiftSoup

func extractText(from html: String) throws -> String {
    let document = try SwiftSoup.parse(html)
    return try document.text()
}
