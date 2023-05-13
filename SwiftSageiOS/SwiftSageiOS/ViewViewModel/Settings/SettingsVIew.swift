//
//  SettingsVIew.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI
#if !os(macOS)
import UIKit
#endif

struct SettingsView: View {
    @Binding var showSettings: Bool

    @ObservedObject var settingsViewModel: SettingsViewModel
    let modes: [String] = ["dots", "waves", "bar", "matrix", "none"]
    @State private var currentModeIndex: Int = 0

    @FocusState private var field1IsFocused: Bool
    @FocusState private var field2IsFocused: Bool
    @FocusState private var field3IsFocused: Bool
    @FocusState private var field4IsFocused: Bool
    @FocusState private var field5IsFocused: Bool
    @FocusState private var field6IsFocused: Bool
    @FocusState private var field7IsFocused: Bool
    @State private var scrollViewID = UUID()

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Group {
                        Group {
                            HStack(spacing: 4) {
                                HStack {
                                    Button(action: {
                                        withAnimation {
                                            field1IsFocused = false
                                            field2IsFocused = false
                                            field3IsFocused = false
                                            field4IsFocused = false
                                            field5IsFocused = false
                                            field6IsFocused = false
                                            field7IsFocused = false
                                            scrollViewID = UUID()
                                            showSettings.toggle()
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .fontWeight(.bold)
                                            .font(.body)
                                            .padding(.horizontal, 8)
                                                 .padding(.vertical, 8)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
                                    }
                                }

                                Text("Settings:")
                                    .font(.headline)
                                    .foregroundColor(settingsViewModel.appTextColor)

                                Text("scroll down 📜⬇️4 more")
                                    .font(.caption)
                                    .foregroundColor(settingsViewModel.appTextColor)
                            }
                            .padding(.top, 30)
                            .padding(.leading,8)
                            .padding(.trailing,8)
                        }

                        // MODE PICKER
                        Group {
                            Text("sws mode").font(.body)
                                .foregroundColor(settingsViewModel.appTextColor)

                            DevicePicker(settingsViewModel: settingsViewModel)
                        }
                        VStack {
                            if settingsViewModel.currentMode == .computer {
                                HStack {
                                    Text("sws username: ").font(.caption)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                    TextField("", text: $settingsViewModel.userName)
                                        .submitLabel(.done)
                                        .scrollDismissesKeyboard(.interactively)
                                        .font(.footnote)
                                        .border(.secondary)

                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .autocorrectionDisabled(true)
#if !os(macOS)
                                        .autocapitalization(.none)
#endif
                                    Spacer()

                                }
                                .padding(.leading, 8)
                                .padding(.trailing, 8)
                                .frame(height: 22)

                                HStack {
                                    Text("sws password: ").font(.caption)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                    TextField("", text: $settingsViewModel.password)
                                        .submitLabel(.done)
                                        .scrollDismissesKeyboard(.interactively)
                                        .border(.secondary)

                                        .font(.footnote)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .autocorrectionDisabled(true)
#if !os(macOS)
                                        .autocapitalization(.none)
#endif
                                    Spacer()

                                }
                                .padding(.leading, 8)
                                .padding(.trailing, 8)

                                .frame(height: 22)

                            }
                            else if settingsViewModel.currentMode == .mobile {
                                HStack {
                                    VStack {
                                        Group {
                                            HStack {
                                                Text("A.I. 🔑: ").font(.caption)
                                                    .foregroundColor(settingsViewModel.appTextColor)

                                                TextField(
                                                    "",
                                                    text: $settingsViewModel.openAIKey
                                                )
                                                .border(.secondary)
                                                .submitLabel(.done)

                                                .focused($field1IsFocused)

                                                .frame( maxWidth: .infinity, maxHeight: .infinity)
                                                .scrollDismissesKeyboard(.interactively)
                                                .font(.caption)
                                                .foregroundColor(settingsViewModel.appTextColor)

                                                .autocorrectionDisabled(true)
#if !os(macOS)
                                                .autocapitalization(.none)
#endif
                                                Spacer()

                                            }
                                            .frame(height: geometry.size.height / 13)

                                            HStack {
                                                Text("A.I. model: ").font(.caption)
                                                    .foregroundColor(settingsViewModel.appTextColor)

                                                TextField(
                                                    "",
                                                    text: $settingsViewModel.openAIModel
                                                )
                                                .border(.secondary)
                                                .submitLabel(.done)
                                                .focused($field2IsFocused)

                                                .frame( maxWidth: .infinity, maxHeight: .infinity)
                                                .scrollDismissesKeyboard(.interactively)
                                                .font(.caption)
                                                .foregroundColor(settingsViewModel.appTextColor)
                                                .autocorrectionDisabled(true)
#if !os(macOS)
                                                .autocapitalization(.none)
#endif
                                                Spacer()

                                            }
                                            .padding(.leading, 8)
                                            .padding(.trailing, 8)
                                            .frame(height: geometry.size.height / 13)
                                        }

                                    }
                                    .frame( maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                        }
                        Group {
                            HStack {
                                Text("GHA PAT: ").font(.caption)
                                    .foregroundColor(settingsViewModel.appTextColor)

                                TextField(
                                    "",
                                    text: $settingsViewModel.ghaPat
                                )
                                .border(.secondary)
                                .submitLabel(.done)
                                .focused($field3IsFocused)
                                .frame( maxWidth: .infinity, maxHeight: .infinity)
                                .font(.caption)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .autocorrectionDisabled(true)
#if !os(macOS)
                                .autocapitalization(.none)
#endif
                            }
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                            .frame(height: geometry.size.height / 17)
                        }




                        Group {
                            Button  {
                                withAnimation {
                                    logD("AUTOCORRECTION: \(settingsViewModel.autoCorrect ? "off" : "on.")")

                                    settingsViewModel.autoCorrect.toggle()
                                }

                            } label: {
                                ZStack {
                                    VStack {
                                        Text("Autocorrect?")
                                            .font(.body)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("📙")
                                    }
                                    if settingsViewModel.autoCorrect {
                                        Text("❌")
                                            .opacity(0.74)
                                    }
                                }
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                .lineLimit(1)
                                .background(settingsViewModel.buttonColor)
                                .fontWeight(.bold)
                                .cornerRadius(8)
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                        }

                        if settingsViewModel.currentMode == .computer {
                            Group {
                                Text("LoadMode")
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .fontWeight(.semibold)
                                HStack {
                                    Button(action: {
                                        withAnimation {
                                            updateMode()
                                        }
                                    }) {
                                        Text(".\(modes[currentModeIndex])")
                                            .background(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .cornerRadius(8)
                                    }
                                    .padding(.bottom)
                                }
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                        }


                        Group {
                            Text("\(settingsViewModel.showSizeSliders ? "🔽" : "▶️") size sliders").font(.body)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .padding(4)

                        }
                        .onTapGesture {
                            withAnimation {
                                settingsViewModel.showSizeSliders.toggle()
                            }
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            if settingsViewModel.showSizeSliders {

                                Group {
                                    Text("Terminal Text Size")
                                        .fontWeight(.semibold)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                    HStack {
                                        Text("Small")                                    .foregroundColor(settingsViewModel.appTextColor)

                                        Slider(value: $settingsViewModel.textSize, in: 2...64, step: 0.1)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    Text("\(settingsViewModel.textSize)")
                                        .font(.body)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                        .lineLimit(nil)
                                }
                                Group {
                                    Text("SrcEditor Text Size")
                                        .fontWeight(.semibold)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                    HStack {
                                        Text("Small")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Slider(value: $settingsViewModel.fontSizeSrcEditor, in: 2...64, step: 0.1)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    Text("\(settingsViewModel.fontSizeSrcEditor)")
                                        .font(.body)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .lineLimit(nil)
                                }
                                Group {
                                    Text("Toolbar size")
                                        .fontWeight(.semibold)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                    HStack {
                                        Text("Small")
                                            .foregroundColor(settingsViewModel.appTextColor)
                                        Slider(value: $settingsViewModel.buttonScale, in:  0.1...0.45, step: 0.01)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    Text("\(settingsViewModel.buttonScale)")
                                        .font(.body)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                        .lineLimit(nil)
                                }
                                Group {
                                    Text("CMD bar size")
                                        .fontWeight(.semibold)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                    HStack {
                                        Text("Small")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Slider(value: $settingsViewModel.commandButtonFontSize, in:  10...64, step: 0.01)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    Text("\(settingsViewModel.commandButtonFontSize)")
                                        .font(.body)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                        .lineLimit(nil)
                                }
                                Group {
                                    Text("middle handle size")
                                        .fontWeight(.semibold)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                    HStack {
                                        Text("Small")                                    .foregroundColor(settingsViewModel.appTextColor)

                                        Slider(value: $settingsViewModel.middleHandleSize, in:  18...48, step: 1)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    Text("\(settingsViewModel.middleHandleSize)")
                                        .font(.body)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                        .lineLimit(nil)
                                }
                                Group {
                                    Text("corner handle size")
                                        .fontWeight(.semibold)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                    HStack {
                                        Text("Small")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Slider(value: $settingsViewModel.cornerHandleSize, in:  18...48, step: 1)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    Text("\(settingsViewModel.cornerHandleSize)")
                                        .font(.body)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .lineLimit(nil)
                                }
                            }

                        }
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                    }
                    Group {
                        Text("\(settingsViewModel.showAllColorSettings ? "🔽" : "▶️") color settings").font(.body)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .padding(4)
                    }
                    .onTapGesture {
                        withAnimation {

                            settingsViewModel.showAllColorSettings.toggle()
                        }
                    }
                    if settingsViewModel.showAllColorSettings {
                        // TERMINAL COLORS SETTINGS ZONE
                        Group {
                            Group {
                                VStack(spacing: 3) {

                                    ColorPicker("Terminal Background Color", selection:
                                                    $settingsViewModel.terminalBackgroundColor)
                                    .frame(width: geometry.size.width / 2, alignment: .leading)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                }
                                VStack( spacing: 3) {

                                    ColorPicker("Terminal Text Color", selection:
                                                    $settingsViewModel.terminalTextColor)
                                    .frame(width: geometry.size.width / 2, alignment: .leading)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                }
                            }
                            Group {
                                VStack( spacing: 3) {

                                    ColorPicker("App Text Color", selection:
                                                    $settingsViewModel.appTextColor)
                                    .frame(width: geometry.size.width / 2, alignment: .leading)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                }
                                VStack( spacing: 3) {

                                    ColorPicker("App Button Color", selection:
                                                    $settingsViewModel.buttonColor)
                                    .frame(width: geometry.size.width / 2, alignment: .leading)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                }

                                VStack( spacing: 3) {

                                    ColorPicker("App Background Color", selection:
                                                    $settingsViewModel.backgroundColor)
                                    .frame(width: geometry.size.width / 2, alignment: .leading)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                }
                            }
                        }
                        // SOURCE EDITOR COLORS SETTINGS ZONE
                        Group {
                            Text("\(settingsViewModel.showSourceEditorColorSettings ? "🔽" : "▶️") srceditor colors").font(.body)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .padding(4)

                        }
                        .onTapGesture {
                            withAnimation {

                                settingsViewModel.showSourceEditorColorSettings.toggle()
                            }
                        }
                        if settingsViewModel.showSourceEditorColorSettings {
                            Group {
                                Group {
                                    VStack(spacing: 3) {

                                        ColorPicker("SrcEditor Plain text", selection: $settingsViewModel.plainColorSrcEditor)
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    VStack(spacing: 3) {

                                        ColorPicker("SrcEditor Number", selection: $settingsViewModel.numberColorSrcEditor)
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    VStack(spacing: 3) {

                                        ColorPicker("SrcEditor String", selection: $settingsViewModel.stringColorSrcEditor)
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                }
                                Group {
                                    VStack(spacing: 3) {

                                        ColorPicker("SrcEditor Identifier", selection: $settingsViewModel.identifierColorSrcEditor)
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                    VStack(spacing: 3) {

                                        ColorPicker("SrcEditor Keyword", selection: $settingsViewModel.keywordColorSrcEditor)
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                    VStack(spacing: 3) {

                                        ColorPicker("SrcEditor Comment", selection: $settingsViewModel.commentColorSrceEditor)
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                }
                                Group {
                                    VStack(spacing: 3) {

                                        ColorPicker("SrcEditor Placeholder", selection: $settingsViewModel.editorPlaceholderColorSrcEditor)
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                    VStack(spacing: 3) {

                                        ColorPicker("SrcEditor Background", selection: $settingsViewModel.backgroundColorSrcEditor)
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                    VStack(spacing: 3) {

                                        ColorPicker("SrcEditor Line number", selection: $settingsViewModel.lineNumbersColorSrcEditor)
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                }
                            }
                        }
                    }


//                    Button(action: {
//                        withAnimation {
//#if !os(macOS)
//                            consoleManager.print("Patience... soon this will select your avatar. Then we'll add the customization of GPT bot avatars in time.")
//#endif
//                        }
//                    }) {
//                        VStack {
//                            Text("Choose Avatar")
//                                .foregroundColor(settingsViewModel.appTextColor)
//                                .font(.body)
//
//                            Text("👨")
//                                .fontWeight(.bold)
//                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(8)
//                        }
//                    }
//                    .frame( maxWidth: .infinity, maxHeight: .infinity)
//                    .padding(.bottom)

                    Group {
                        Text("\(settingsViewModel.showAudioSettings ? "🔽" : "▶️") audio settings").font(.body)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .padding(4)

                    }
                    .onTapGesture {
                        withAnimation {
                            settingsViewModel.showAudioSettings.toggle()
                        }
                    }

                    if settingsViewModel.showAudioSettings {
                        // ENABLE MIC BUTTON
                        Text("\(settingsViewModel.hasAcceptedMicrophone == true ? "Mic enabled" : "Enable mic")")
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(settingsViewModel.appTextColor)

                        Button(action: {
                            withAnimation {
#if !os(macOS)
                                consoleManager.print("Requesing mic permission...")
#endif
                                requestMicrophoneAccess { granted in
                                    settingsViewModel.hasAcceptedMicrophone = granted == true
                                }
                            }
                        }) {
                            resizableButtonImage(systemName:
                                                    "mic.badge.plus",
                                                 size: geometry.size)
                            .fontWeight(.bold)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(8)

                        }
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom)

                        // IOS AUDIO SETTING ON/OFF
                        Text("\(settingsViewModel.voiceOutputenabled ? "Disable" : "Enable") iOS audio output (this device)")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                        HStack {
                            Button  {
                                withAnimation {
#if !os(macOS)
                                    consoleManager.print("toggling audio \(settingsViewModel.voiceOutputenabled ? "off" : "on.")")
                                    if settingsViewModel.voiceOutputenabled {
                                        stopVoice()
                                    }
                               
                                    configureAudioSession()
                                    printVoicesInMyDevice()

                                    settingsViewModel.voiceOutputenabled.toggle()
                                    settingsViewModel.voiceOutputenabledUserDefault.toggle()
#endif
                                }

                            } label: {
                                resizableButtonImage(systemName:
                                                        settingsViewModel.voiceOutputenabled ? "speaker.wave.2.bubble.left.fill" : "speaker.slash.circle.fill",
                                                     size: geometry.size)
                                .fontWeight(.bold)
                                .cornerRadius(8)
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)

                            if settingsViewModel.voiceOutputenabled {
                                Button  {
                                    withAnimation {
                                        logD("duck audio: \(settingsViewModel.voiceOutputenabled ? "off" : "on.")")

                                        settingsViewModel.duckingAudio.toggle()
                                    }
                                } label: {
                                    ZStack {
                                        VStack {
                                            Text("Duck Audio?")
                                                .foregroundColor(settingsViewModel.appTextColor)
                                                .font(.body)
                                            Text("🦆")
                                        }
                                        if settingsViewModel.duckingAudio {
                                            Text("❌")
                                                .opacity(0.74)
                                        }
                                    }
                                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                                    .lineLimit(1)
                                    .background(settingsViewModel.buttonColor)
                                    .fontWeight(.bold)
                                    .cornerRadius(8)
                                }
                                .frame( maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }

                    VStack {
                        if settingsViewModel.showAudioSettings && settingsViewModel.voiceOutputenabled {
                            VStack {
                                
                                Text("Pick iOS voice")
                                    .foregroundColor(settingsViewModel.appTextColor)

                                List {
                                    ForEach(0..<settingsViewModel.installedVoices.count, id: \.self) { index in
                                        let item = settingsViewModel.installedVoices[index]
                                        HStack {
                                            Text(item.voiceName)
                                                .foregroundColor(settingsViewModel.appTextColor)

                                            Spacer()
                                            if settingsViewModel.selectedVoiceIndexSaved == index {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(settingsViewModel.buttonColor)
                                                    .alignmentGuide(HorizontalAlignment.center, computeValue: { d in d[HorizontalAlignment.center] })
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            settingsViewModel.selectedVoiceIndexSaved = index
                                        }
                                        .frame(height: 30)
                                    }
                                }
                                .frame(height: CGFloat(settingsViewModel.installedVoices.count * 2))
                            }
                        }

                        VStack {
                            HStack {
                                Group {
                                    VStack {
                                        Button(action: {
                                            withAnimation {
                                                showSettings.toggle()
                                                settingsViewModel.showHelp.toggle()

                                                logD("HELP tapped")


                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
#if !os(macOS)
                                                    consoleManager.isVisible = false
#endif
                                                }
                                            }
                                        }) {
                                            resizableButtonImage(systemName:
                                                                    "questionmark.circle.fill",
                                                                 size: geometry.size)
                                            .fontWeight(.bold)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
                                        }
                                        // Button for (help)
                                        Text("help")
                                            .foregroundColor(settingsViewModel.appTextColor)


                                    }
                                    VStack {


                                        Button(action: {
                                            withAnimation {
                                                showSettings.toggle()
                                                settingsViewModel.showInstructions.toggle()

                                                logD("info tapped")

                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
#if !os(macOS)
                                                    consoleManager.isVisible = false
#endif
                                                }
                                            }
                                        }) {
                                            resizableButtonImage(systemName:
                                                                    "info.windshield",
                                                                 size: geometry.size)
                                            .fontWeight(.bold)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
                                        }
                                        // BUTTON FOR (i) info
                                        Text("info")
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                }
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            Button(action: {
                                withAnimation {
                                    field1IsFocused = false
                                    field2IsFocused = false
                                    field3IsFocused = false
                                    field4IsFocused = false
                                    field5IsFocused = false
                                    field6IsFocused = false
                                    field7IsFocused = false
                                    scrollViewID = UUID()
                                    showSettings.toggle()
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .fontWeight(.bold)
                                    .font(.body)

                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .background(settingsViewModel.buttonColor)
                                    .cornerRadius(8)
                            }
                            .padding(.bottom)
                            Spacer()
                        }
                    }
                    .frame( maxWidth: .infinity, maxHeight: .infinity)

                    Spacer()

                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
                .padding(geometry.size.width * 0.01)
                .padding(.bottom, 30)
#if !os(macOS)
                .background(settingsViewModel.backgroundColor)
#endif
                
            }
            .edgesIgnoringSafeArea(.all)
            .background(settingsViewModel.backgroundColor)

            .onAppear {
#if !os(macOS)
                UIScrollView.appearance().bounces = false
#endif
            }
            .id(self.scrollViewID)
            .scrollIndicators(.visible)
        }
    }

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
            .tint(settingsViewModel.buttonColor)
#if !os(macOS)

            .background(settingsViewModel.backgroundColor)
#endif

    }
    private func updateMode() {
        currentModeIndex = (currentModeIndex + 1) % modes.count

        settingsViewModel.multiLineText = "setLoadMode \(modes[currentModeIndex])"
        DispatchQueue.main.async {

            self.settingsViewModel.isInputViewShown = false
            // Execute your action here
            screamer.sendCommand(command: settingsViewModel.multiLineText)
            settingsViewModel.multiLineText = ""
        }
    }
}

struct DevicePicker: View {
    @State  var isExpanded = true
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: isExpanded ? 10 : 30)
                .fill(settingsViewModel.appTextColor)
                .frame(width: isExpanded ? 250 : 60, height: 60)

            HStack(spacing: 30) {
                Image(systemName: "iphone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(settingsViewModel.buttonColor)
                    .opacity(settingsViewModel.currentMode == .mobile ? 1 : 0.5)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            settingsViewModel.currentMode = .mobile
                            logD(settingsViewModel.logoAscii5())
                        }
                    }
                Image(systemName: "desktopcomputer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(settingsViewModel.buttonColor)

                    .opacity(settingsViewModel.currentMode == .computer ? 1 : 0.5)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            settingsViewModel.currentMode = .computer
                            logD(settingsViewModel.logoAscii5())
                        }
                    }
            }
            .padding(.horizontal, isExpanded ? 20 : 0)
            .opacity(isExpanded ? 1 : 0)
        }
    }
}

