//
//  CommandButton.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/24/23.
//

import Foundation
import SwiftUI

struct CommandButtonView: View {
    @State private var isInputViewShown = false
    @State private var multiLineText = ""
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        VStack {
            HStack {
                if !multiLineText.isEmpty {
                    Button(action: {
                        multiLineText = ""
                    }) {
                        Text( "X")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                            .padding()
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
                    }
                }

                Button(action: {
                    self.isInputViewShown.toggle()
                    consoleManager.isVisible = !isInputViewShown
                    consoleManager.fontSize = settingsViewModel.textSize

                }) {
                    Text(self.isInputViewShown ? "TERM" : "COMMAND")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding()
                        .background(settingsViewModel.buttonColor)
                        .cornerRadius(10)
                }
            }

            if isInputViewShown {
                TextEditor(text: $multiLineText)
                    .frame(height: 200)
                    .padding()
                    .border(Color.gray, width: 1)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)

                Button(action: {
                    // Execute your action here
                    screamer.sendCommand(command: multiLineText)

                    self.isInputViewShown = false
                    consoleManager.isVisible = true

                }) {
                    Text("EXEC")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
        }
        .padding()
    }
}
