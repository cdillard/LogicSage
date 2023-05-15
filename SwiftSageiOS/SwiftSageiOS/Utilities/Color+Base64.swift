//
//  Color+Base64.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/15/23.
//

import Foundation
import SwiftUI
import UIKit

#if !os(macOS)

extension Color: RawRepresentable {

    public init?(rawValue: String) {

        guard let data = Data(base64Encoded: rawValue) else{
            self = .black
            return
        }

        do{
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        }catch{
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

#endif
