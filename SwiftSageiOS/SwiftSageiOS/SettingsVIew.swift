//
//  SettingsVIew.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI


// Mac OS Cereproc voices for Sw-S: cmd line voices - not streamed to device. SwiftSageiOS acts as remote for this if you have your headphones hooked up to your mac and
// are using muliple iOS devices for screens, etc.
let cereprocVoicesNames = [
    "Heather",
    "Hannah",
    "Carolyn",
    "Sam",
    "Lauren",
    "Isabella",
    "Megan",
    "Katherine"
]

struct SettingsView: View {
    @Binding var showSettings: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    let modes: [String] = ["dots", "waves", "bar", "matrix", "none"]
    @State private var currentModeIndex: Int = 0

    @State private var selectedIOSVoiceIndex: Int?
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
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
                    .frame( maxWidth: .infinity, maxHeight: .infinity)
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
                    // IOS AUDIO SETTING ON/OFF
                    Text("\(settingsViewModel.voiceOutputenabled ? "Disable" : "Enable.") iOS audio output (this device)")
                    Button  {
                        withAnimation {
#if !os(macOS)
                            consoleManager.print("toggling audio \(settingsViewModel.voiceOutputenabled ? "off" : "on.")")
                            if settingsViewModel.voiceOutputenabled {
                                stopVoice()
                            }
                            else {
                                configureAudioSession()
                                printVoicesInMyDevice()
                            }
                            settingsViewModel.voiceOutputenabled.toggle()
                            settingsViewModel.voiceOutputenabledUserDefault.toggle()


#endif
                        }

                    } label: {
                        resizableButtonImage(systemName:
                                                settingsViewModel.voiceOutputenabled ? "speaker.wave.2.bubble.left.fill" : "speaker.slash.circle.fill",
                                             size: geometry.size)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(settingsViewModel.buttonColor)
                        .cornerRadius(8)
                    }

                    VStack {
                        if settingsViewModel.voiceOutputenabled {
                            VStack {
                                
                                Text("Pick iOS voice")
                                List {
                                    ForEach(0..<settingsViewModel.installedVoices.count, id: \.self) { index in
                                        let item = settingsViewModel.installedVoices[index]
                                        HStack {
                                            Text(item.voiceName)
                                            Spacer()
                                            if selectedIOSVoiceIndex == index {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                                    .alignmentGuide(HorizontalAlignment.center, computeValue: { d in d[HorizontalAlignment.center] })
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedIOSVoiceIndex = index
                                            settingsViewModel.selectedVoice = settingsViewModel.installedVoices[selectedIOSVoiceIndex ?? 0]
                                        }
                                        .frame(height: 30)
                                    }
                                }
                                .frame(height: CGFloat(settingsViewModel.installedVoices.count * 30))
                            }

                        }

                        HStack {
                            VStack {
                                Text("\(settingsViewModel.voiceOutputenabled ? "Disable" : "Enable.") MACOS audio output")
                                Button  {
                                    withAnimation {
#if !os(macOS)
                                        print("TODO: IMPLEMENT ENABLE/DISABLE MAC OS AUDIO FROM IOS")
                                        //                                    consoleManager.print("toggling audio \(settingsViewModel.voiceOutputenabled ? "off" : "on.")")
                                        //                                    if settingsViewModel.voiceOutputenabled {
                                        //                                        stopVoice()
                                        //                                    }
                                        //                                    else {
                                        //                                        configureAudioSession()
                                        //                                    }
                                        //                                    settingsViewModel.voiceOutputenabled.toggle()
                                        //                                    settingsViewModel.voiceOutputenabledUserDefault.toggle()

#endif
                                    }

                                } label: {
                                    resizableButtonImage(systemName:
                                                            settingsViewModel.voiceOutputenabled ? "speaker.wave.2.bubble.left.fill" : "speaker.slash.circle.fill",
                                                         size: geometry.size)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 12)
                                    .background(settingsViewModel.buttonColor)
                                    .cornerRadius(8)
                                }


                                Text("Pick macOS server voice")
                            }
                            Spacer()
                        }

                        List(cereprocVoicesNames, id: \.self) { name in
                            Text(name)
                                .frame(height: 30)
                        }
                        .frame(height: CGFloat(cereprocVoicesNames.count * 40))

                    }
                    Spacer()


                    HStack {
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
                    .frame( maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
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
    }

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: min(size.width * 0.05, maxButtonSize), height: min(size.width * 0.05, maxButtonSize))
            .padding(size.width * 0.02)
            .background(settingsViewModel.buttonColor)
            .foregroundColor(.white)
            .cornerRadius(size.width * 0.05)
            .padding(.bottom, size.width * 0.01)
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
