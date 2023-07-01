//
//  Color+Base64.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/15/23.
//

import Foundation
import SwiftUI

#if !os(macOS)
import UIKit

extension Color: RawRepresentable {
    public init?(rawValue: String) {

        guard let data = Data(base64Encoded: rawValue) else{
            self = .black
            return
        }

        do{
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        } catch{
            self = .black
        }
    }

    public var rawValue: String {
        do{
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()

        }catch{

            return ""

        }
    }
}
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
#endif
