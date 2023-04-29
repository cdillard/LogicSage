//
//  SettingsVIew.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    let modes: [String] = ["dots", "waves", "bar", "matrix", "none"]
    @State private var currentModeIndex: Int = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)

                VStack(alignment: .leading, spacing: 15) {
                    Text("Terminal Background Color")
                        .fontWeight(.semibold)
                    ColorPicker("", selection: $settingsViewModel.terminalBackgroundColor)
                        .labelsHidden()
                        .padding(.horizontal, 8)
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("Terminal Text Color")
                        .fontWeight(.semibold)
                    ColorPicker("", selection: $settingsViewModel.terminalTextColor)
                        .labelsHidden()
                        .padding(.horizontal, 8)
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("Button Color")
                        .fontWeight(.semibold)
                    ColorPicker("", selection: $settingsViewModel.buttonColor)
                        .labelsHidden()
                        .padding(.horizontal, 8)
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("Background Color")
                        .fontWeight(.semibold)
                    ColorPicker("", selection: $settingsViewModel.backgroundColor)
                        .labelsHidden()
                        .padding(.horizontal, 8)
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("Text Size")
                        .fontWeight(.semibold)
                    HStack {
                        Text("Small")
                        Slider(value: $settingsViewModel.textSize, in: 2...22, step: 0.3)
                            .accentColor(.blue)
                        Text("Large")
                    }
                    Text("\(settingsViewModel.textSize)")
                        .font(.caption)


                    Text("LoadMode")
                        .fontWeight(.semibold)
                    HStack {
                        Button(action: {
                            withAnimation {
                                updateMode()
                            }
                        }) {
                            Text(".\(modes[currentModeIndex])")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 12)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(8)
                        }
                        .padding(.bottom)
                    }
                }
                Button(action: {
                    withAnimation {
#if !os(macOS)
                        consoleManager.print("Patience... soon this will select your avatar. Then we'll add the customization of GPT bot avatars in time.")
#endif
                    }
                }) {
                    Text("👨")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(settingsViewModel.buttonColor)
                        .cornerRadius(8)
                }
                .padding(.bottom)


                Spacer()

                Button(action: {
                    withAnimation {
                        showSettings.toggle()
                    }
                }) {
                    Text("Close")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(settingsViewModel.buttonColor)
                        .cornerRadius(8)
                }
                .padding(.bottom)
            }
            .padding()
#if !os(macOS)

            .background(Color(.systemBackground))
            #else
            .background(Color(.black))
            #endif
            .cornerRadius(16)
        }
        .scrollIndicators(.visible)
    }
    private func updateMode() {
        currentModeIndex = (currentModeIndex + 1) % modes.count

        settingsViewModel.multiLineText = "setLoadMode \(modes[currentModeIndex])"
        DispatchQueue.main.async {

            self.settingsViewModel.isInputViewShown = false

            // Execute your action here
            screamer.sendCommand(command: settingsViewModel.multiLineText)
            settingsViewModel.multiLineText = ""
//#if !os(macOS)
//
//            consoleManager.isVisible = true
//#endif
        }
    }
}
