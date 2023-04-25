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
    @Published var terminalBackgroundColor: Color = .black
    @Published var terminalTextColor: Color = .white
    @Published var buttonColor: Color = .blue
    @Published var backgroundColor: Color = .gray
}
