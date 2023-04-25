//
//  SettingsViewModel.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    
    @Published var textSize: CGFloat {
        didSet {
            UserDefaults.standard.set(Float(textSize), forKey: "textSize")

            terminalFontSize = textSize

        }
    }

    @Published var terminalBackgroundColor: Color = .black {
        didSet {
                   if let data = terminalBackgroundColor.colorData() {
                       UserDefaults.standard.set(data, forKey: "terminalBackgroundColor")
                   }
               }
           }
@Published var terminalTextColor: Color = .white {
    didSet {

        if let data = terminalTextColor.colorData() {
            UserDefaults.standard.set(data, forKey: "terminalTextColor")
        }
    }
}
    
    @Published var buttonColor: Color = .blue {
        didSet {
            if let data = buttonColor.colorData() {
                UserDefaults.standard.set(data, forKey: "buttonColor")
            }
        }
    }
@Published var backgroundColor: Color = .gray {
    didSet {
        if let data = backgroundColor.colorData() {
            UserDefaults.standard.set(data, forKey: "backgroundColor")
        }
    }
}

init() {
    self.terminalBackgroundColor = UserDefaults.standard.data(forKey: "terminalBackgroundColor").flatMap { Color.color(data: $0) } ?? .black
    self.terminalTextColor = UserDefaults.standard.data(forKey: "terminalTextColor").flatMap { Color.color(data: $0) } ?? .green
    self.buttonColor = UserDefaults.standard.data(forKey: "buttonColor").flatMap { Color.color(data: $0) } ?? .green
    self.backgroundColor = UserDefaults.standard.data(forKey: "backgroundColor").flatMap { Color.color(data: $0) } ?? .black

    self.textSize = CGFloat(UserDefaults.standard.float(forKey: "textSize"))
}
}


import SwiftUI

extension Color {
    static func color(data: Data) -> Color {
        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .clear
            return Color(color)
        } catch {
            print("Error converting Data to Color: \(error)")
            return Color.clear
        }
    }

    func colorData() -> Data? {
        do {
            let uiColor = UIColor(self)
            let data = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            return data
        } catch {
            print("Error converting Color to Data: \(error)")
            return nil
        }
    }
}
