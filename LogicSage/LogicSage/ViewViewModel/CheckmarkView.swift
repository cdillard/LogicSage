//
//  CheckmarkView.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/25/23.
//

import Foundation
import SwiftUI

struct CheckmarkView: View {
    var text: String
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible {
            HStack(spacing: 10) {
                Image(systemName: "checkmark")
                Text("\(text)!")
            }
            .font(.system(size: 20, design: .monospaced))
            .background(SettingsViewModel.shared.buttonColor)
            .cornerRadius(8)
            .foregroundColor(SettingsViewModel.shared.appTextColor)
            .padding()
            .transition(.opacity)
        }
    }
}
