//
//  String+Base64.swift
//  
//
//  Created by Alberto Espinilla Garrido on 2/4/23.
//

import Foundation

extension String {
    func base64Encoded() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .ascii)
    }
}
