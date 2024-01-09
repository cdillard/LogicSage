//
//  plistHelper.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/18/23.
//

import Foundation

class plistHelper {
    
    static func objectFor(key: String, plist: String) -> Any? {
        if let plistPath = Bundle.main.url(forResource: plist, withExtension: ".plist") {
            do {
                let plistData = try Data(contentsOf: plistPath)
                if let dict = try PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] {
                    return dict[key]
                }
            } catch {
                print(error)
            }
        }
        return nil
    }
}
