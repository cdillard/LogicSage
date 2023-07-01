//
//  UIColorExt.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/26/23.
//
#if !os(macOS)

import Foundation
import SwiftUI
import UIKit

extension UIColor {
    convenience init(_ color: Color) {
        let uiColor = color.uiColor()
        self.init(cgColor: uiColor.cgColor)
    }
}

extension Color {
    func uiColor() -> UIColor {
        let components = self.cgColor?.components.map { $0 }
        let colorSpace = self.cgColor?.colorSpace?.model
        
        if let components = components, let colorSpace = colorSpace {
            switch colorSpace {
            case .monochrome:
                return UIColor(white: components[0], alpha: components[1])
            case .rgb:
                return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
            default:
                return UIColor(cgColor: self.cgColor ?? UIColor.black.cgColor)
            }
        }
        return UIColor(cgColor: self.cgColor ?? UIColor.black.cgColor)
    }
}
#endif
