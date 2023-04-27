//
//  File.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/26/23.
//

import Foundation
import SwiftUI

struct InstructionsPopup: View {
    @Binding var isPresented: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        VStack {
            Text("Welcome to SwiftSage!")
                .font(.largeTitle)
                .bold()
                .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text("DISCLAIMER: I am not responsible for any issues (legal or otherwise) that may arise from using the code in this repository. This is an experimental project, and I cannot guarantee its contents.")
                Text("Check out SwiftSage GitHub: https://github.com/cdillard/SwiftSage for instructions.")
                Text("Make sure you are have at minimum:")
                Text("0. Set your API Key for Open AI and enabled feature flag swiftSageIOSEnabled.")
                Text("1. Running SwiftSage Swifty-GPT cmd line target on your command line Mac.")
                Text("2. Running the vapor server.")
                Text("Without this, it will not work.")

                Text("Due to this being an alpha please do this on launch:\n1. Force quit / restart app.\nrTap gear, set font size, terminal font color, tap command to open COMMAND , tap TERM. BOOM! your term colors.")
                Text("You can dock terminals to side of screen to get them out of way")
            }
            .padding()

            Button(action: {

                if !hasSeenInstructions() {
                    settingsViewModel.textSize = defaultTerminalFontSize
                    settingsViewModel.terminalTextColor = .green
                }

                isPresented = false
                setHasSeenInstructions(true)

                consoleManager.isVisible = true
                consoleManager.fontSize = settingsViewModel.textSize
            }) {
                Text("Got it!")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        .edgesIgnoringSafeArea(.all)
    }
}
