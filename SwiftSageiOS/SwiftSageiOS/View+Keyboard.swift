//
//  View+Keyboard.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/10/23.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
