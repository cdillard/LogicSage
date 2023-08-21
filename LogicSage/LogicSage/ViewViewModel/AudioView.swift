//
//  SettingsVIew.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI

struct AudioView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var windowManager: WindowManager

    @Binding var isInputViewShown: Bool
    @Binding var tabSelection: Int

    @State var audioSettingsTitleLabelString: String = "Audio:"

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {

                    audioSettingsArea(size: geometry.size)
                    Button(action: {
                        withAnimation {
                            tabSelection = 1
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .cornerRadius(8)
#if !os(macOS)
                            .hoverEffect(.lift)
#endif
                    }
                }
                .padding(.top, 30)

                .padding(.bottom, geometry.size.height / 8)
                .cornerRadius(16)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .accentColor(settingsViewModel.buttonColor)
            .foregroundColor(settingsViewModel.appTextColor)
        }
#if !os(macOS)
        .background(settingsViewModel.backgroundColor)
#endif
    }
    func audioSettingsArea(size: CGSize) -> some View {
        Group {
            HStack {
                Button(action: {
                    withAnimation {
                        tabSelection = 1
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .foregroundColor(settingsViewModel.appTextColor)
                        .cornerRadius(8)
#if !os(macOS)
                        .hoverEffect(.lift)
#endif
                }
            
                Text(audioSettingsTitleLabelString)
                    .font(.title)
                    .foregroundColor(settingsViewModel.appTextColor)
                    .padding(8)
            }
            // TODO:Double check toggling ducing Audio and audio output this way works.
                // IOS AUDIO SETTING ON/OFF
                Toggle(isOn: $settingsViewModel.voiceOutputEnabled) {
                    VStack(spacing: 4) {
                        Text("Audio Output")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame( maxWidth: size.width / 3)
                .onChange(of: settingsViewModel.voiceOutputEnabled) { value in
                    withAnimation {
#if !os(macOS)
                        SettingsViewModel.shared.logText("toggling audio \(settingsViewModel.voiceOutputEnabled ? "off" : "on.")")
                        if settingsViewModel.voiceOutputEnabled {
                            settingsViewModel.stopVoice()
                        }

                        settingsViewModel.configureAudioSession()
                        settingsViewModel.printVoicesInMyDevice()

                        settingsViewModel.voiceOutputEnabled.toggle()
#endif
                    }

                }
                HStack {
                    if settingsViewModel.voiceOutputEnabled {
                        // IOS AUDIO SETTING ON/OFF
                        Toggle(isOn: $settingsViewModel.duckingAudio) {
                            VStack(spacing: 4) {
                                Text("Duck Audio")
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .frame( maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .frame( maxWidth: size.width / 3)
                    }
                }

            VStack {
                    VStack {
                        Text("Pick voice")
                            .foregroundColor(settingsViewModel.appTextColor)

                        List {
                            ForEach(0..<settingsViewModel.installedVoices.count, id: \.self) { index in
                                let item = settingsViewModel.installedVoices[index]
                                HStack {
                                    Text(item.voiceName)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                    Spacer()
                                    if settingsViewModel.selectedVoice?.voiceName == item.voiceName {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(settingsViewModel.buttonColor)
                                            .alignmentGuide(HorizontalAlignment.center, computeValue: { d in d[HorizontalAlignment.center] })
                                    }
                                }
                                .listRowBackground(settingsViewModel.backgroundColor)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    settingsViewModel.voiceOutputSavedName = item.voiceName
                                }
                            }
                        }
                        .listRowBackground(settingsViewModel.backgroundColor)
                        .frame(height: CGFloat(size.height / 2.5))
                    }
            }
            .frame( maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
#if os(macOS) || os(tvOS)
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
#else
        if #available(iOS 16.0, *) {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
                .tint(settingsViewModel.appTextColor)
                .foregroundColor(settingsViewModel.appTextColor)
            #if !os(xrOS)
                .background(settingsViewModel.buttonColor)
#endif

        } else {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
                .foregroundColor(settingsViewModel.appTextColor)
#if !os(xrOS)

                .background(settingsViewModel.buttonColor)
#endif

        }
#endif
    }
}
