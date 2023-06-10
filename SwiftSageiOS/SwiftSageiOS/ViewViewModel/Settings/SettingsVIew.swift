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
    @Binding var showHelp: Bool
    @Binding var showInstructions: Bool

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

    @State private var showAPISettings = false


    @State var presentRenamer: Bool = false
    @State private var newName: String = ""
    @State var renamingConvo: Conversation? = nil


    @State var presentUserAvatarRenamer: Bool = false
    @State var presentGptAvatarRenamer: Bool = false

    @State private var newUsersName: String = ""
    @State private var newGPTName: String = ""

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
                            HStack {
                                // PLugItIn BUTTON
                                Button("🔌:Reconnect") {
                                    logD("force reconnect")
                                    logD("If this is not working make sure that in Settings Allow LogicSage Access to Local Network is set tot true.")

                                    serviceDiscovery?.startDiscovering()

                                    if settingsViewModel.ipAddress.isEmpty || settingsViewModel.port.isEmpty {
#if !os(macOS)
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
#endif
                                    }
                                    else {
                                        logD("If this is not working make sure that in Settings Allow LogicSage Access to Local Network is set tot true.")

                                    }
                                }
                                .font(.body)
                                .lineLimit(nil)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .background(settingsViewModel.buttonColor)
                            }

                        }
                        VStack {
                            Group {
                                Text("\(showAPISettings ? "🔽" : "▶️") API settings")

                                    .font(.headline)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .padding(8)
                            }
                            .onTapGesture {
                                playSelect()

                                withAnimation {
                                    showAPISettings.toggle()
                                }
                            }
                        }
                        if showAPISettings {
                            
                            Group {
                                VStack {
                                    Text("A.I. 🔑: ")
                                        .font(.caption)
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

                                    Text("A.I. model: ")
                                        .font(.caption)
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

                                        .padding(.leading, 8)
                                        .padding(.trailing, 8)

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

                                    HStack {
                                        Text("swiftsage username: ").font(.caption)
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
                                        Text("swiftsage password: ").font(.caption)
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
                                .padding(.leading, 8)
                                .padding(.trailing, 8)
                            }
                        }

                        Group {
                            Toggle(isOn: $settingsViewModel.autoCorrect) {
                                Text("Autocorrect📙:")
                                    .font(.caption)
                                    .foregroundColor(settingsViewModel.appTextColor)
                            }
                            .frame( maxWidth: geometry.size.width / 3)
#if !os(macOS)
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                
                                Group {
                                    VStack {

                                        Toggle(isOn: $settingsViewModel.hapticsEnabled) {
                                            Text("Haptic Feedback📳:")
                                                .font(.caption)
                                                .foregroundColor(settingsViewModel.appTextColor)
                                        }
                                        .frame( maxWidth: geometry.size.width / 3)

                                        Text("feedback won't play when low battery (< 0.30)")
                                            .font(.caption)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                }
                            }
#endif
                        }

                        Group {

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
                            }
                            Text("Set Load mode")
                                .foregroundColor(settingsViewModel.appTextColor)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .frame( maxWidth: .infinity, maxHeight: .infinity)

                        Group {
                            Text("\(settingsViewModel.showSizeSliders ? "🔽" : "▶️") sizes")
                                .font(.headline)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .padding(4)

                        }
                        .onTapGesture {
                            withAnimation {
                                playSelect()

                                settingsViewModel.showSizeSliders.toggle()
                            }
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            if settingsViewModel.showSizeSliders {
                                Group {

                                    HStack {
                                        Text("Small")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Slider(value: $settingsViewModel.fontSizeSrcEditor, in: 2...64, step: 0.5)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    HStack {
                                        Text("Text")
                                            .fontWeight(.semibold)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                        Text("\(settingsViewModel.fontSizeSrcEditor)")
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .lineLimit(nil)
                                    }
                                }
                                .font(.caption)

                                Group {

                                    HStack {
                                        Text("Small")
                                            .foregroundColor(settingsViewModel.appTextColor)
                                        Slider(value: $settingsViewModel.buttonScale, in:  0.1...0.45, step: 0.01)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    HStack {
                                        Text("Buttons")
                                            .fontWeight(.semibold)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("\(settingsViewModel.buttonScale)")
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .lineLimit(nil)
                                    }
                                }
                                .font(.caption)

                                Group {

                                    HStack {
                                        Text("Small")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Slider(value: $settingsViewModel.commandButtonFontSize, in:  10...64, step: 0.01)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    HStack {
                                        Text("Cmd buttons")
                                            .fontWeight(.semibold)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("\(settingsViewModel.commandButtonFontSize)")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                            .lineLimit(nil)
                                    }
                                }
                                .font(.caption)


                                Group {

                                    HStack {
                                        Text("Small")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Slider(value: $settingsViewModel.cornerHandleSize, in:  18...48, step: 1)
                                            .accentColor(settingsViewModel.buttonColor)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("Large")
                                            .foregroundColor(settingsViewModel.appTextColor)

                                    }
                                    HStack {
                                        Text("Window Header")
                                            .fontWeight(.semibold)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Text("\(settingsViewModel.cornerHandleSize)")
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .lineLimit(nil)
                                    }
                                }
                                .font(.caption)

                            }


                        }
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                    }
                    Group {
                        Text("\(settingsViewModel.showAllColorSettings ? "🔽" : "▶️") color")
                            .font(.headline)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .padding(8)
                    }
                    .onTapGesture {
                        playSelect()

                        withAnimation {

                            settingsViewModel.showAllColorSettings.toggle()
                        }
                    }
                    if settingsViewModel.showAllColorSettings {
                        // TERMINAL COLORS SETTINGS ZONE
                        Group {
                            Group {

                                HStack {
                                    Text("Themes:").font(.body)

                                    Text("Deep Space Sparkle")
                                        .foregroundColor(settingsViewModel.appTextColor)

//                                         .foregroundColor(UIColor(red: 245, green: 255, blue: 250))
//                                          .background( UIColor(red: 74, green: 100, blue: 108))
                                        .font(.body)
                                        .padding()
                                        .onTapGesture {
                                            logD("Tapped Deep Space Sparkle theme")

                                            settingsViewModel.applyTheme(theme: .deepSpace)


                                        }
                                    Text("Hackeresque")
                                        .foregroundColor(settingsViewModel.appTextColor)

//                                         .foregroundColor(UIColor(red: 57, green: 255, blue: 20))
//                                         .background( UIColor.black)
                                        .font(.body)
                                        .padding()
                                        .onTapGesture {
                                            logD("Tapped Hackeresque theme")

                                            settingsViewModel.applyTheme(theme: .hacker)

                                        }
                                }

                                //                                VStack(spacing: 3) {
                                //
                                //                                    ColorPicker("Terminal Background Color", selection:
                                //                                                    $settingsViewModel.terminalBackgroundColor)
                                //                                    .frame(width: geometry.size.width / 2, alignment: .leading)
                                //                                    .foregroundColor(settingsViewModel.appTextColor)
                                //                                }
                                //                                VStack( spacing: 3) {
                                //
                                //                                    ColorPicker("Terminal Text Color", selection:
                                //                                                    $settingsViewModel.terminalTextColor)
                                //                                    .frame(width: geometry.size.width / 2, alignment: .leading)
                                //                                    .foregroundColor(settingsViewModel.appTextColor)
                                //                                }
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
                            Text("\(settingsViewModel.showSourceEditorColorSettings ? "🔽" : "▶️") srceditor colors")
                                .font(.headline)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .padding(4)

                        }
                        .onTapGesture {
                            playSelect()

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
                    HStack {
                        Group {
                            Button(action: {
                                withAnimation {
                                    logD("change your name")
                                    presentUserAvatarRenamer = true
                                }
                            }) {
                                VStack {
                                    Text("Avatar")
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .font(.body)

                                    Text("\(settingsViewModel.savedUserAvatar)")
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .background(settingsViewModel.buttonColor)
                                        .cornerRadius(8)
                                }
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.bottom)

                            Button(action: {
                                withAnimation {
                                    logD("change gpt name")
                                    presentGptAvatarRenamer = true

                                }
                            }) {
                                VStack {
                                    Text("Gpt")
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .font(.body)

                                    Text("\(settingsViewModel.savedBotAvatar)")
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .background(settingsViewModel.buttonColor)
                                        .cornerRadius(8)
                                }

                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.bottom)
                        }
                    }

                    Group {
                        Text("\(settingsViewModel.showAudioSettings ? "🔽" : "▶️") audio settings")
                            .font(.headline)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .padding(8)

                    }
                    .onTapGesture {
                        playSelect()

                        withAnimation {

                            settingsViewModel.showAudioSettings.toggle()
                        }
                    }
                    // TODO:Double check toggling ducing Audio and audio output this way works.
                    if settingsViewModel.showAudioSettings {
                        // IOS AUDIO SETTING ON/OFF
                        Toggle(isOn: $settingsViewModel.voiceOutputenabled) {
                            VStack(spacing: 4) {
                                Text("Audio Output")
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .frame( maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .frame( maxWidth: geometry.size.width / 3)
                        .onChange(of: settingsViewModel.voiceOutputenabled) { value in
                            withAnimation {
#if !os(macOS)
                                SettingsViewModel.shared.logText("toggling audio \(settingsViewModel.voiceOutputenabled ? "off" : "on.")")
                                if settingsViewModel.voiceOutputenabled {
                                    settingsViewModel.stopVoice()
                                }

                                settingsViewModel.configureAudioSession()
                                settingsViewModel.printVoicesInMyDevice()

                                settingsViewModel.voiceOutputenabled.toggle()
                                settingsViewModel.voiceOutputenabledUserDefault.toggle()
#endif
                            }

                        }
                        HStack {
                            if settingsViewModel.voiceOutputenabled {
                                // IOS AUDIO SETTING ON/OFF
                                Toggle(isOn: $settingsViewModel.duckingAudio) {
                                    VStack(spacing: 4) {
                                        Text("Duck Audio")
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                                    }
                                }
                                .frame( maxWidth: geometry.size.width / 3)
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
                                        .listRowBackground(settingsViewModel.backgroundColor)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            settingsViewModel.selectedVoiceIndexSaved = index
                                        }
                                        .frame(height: 30)
                                    }
                                }
                                .listRowBackground(settingsViewModel.backgroundColor)
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
                                                showHelp.toggle()

                                                logD("HELP tapped")


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
                                                showInstructions.toggle()

                                                logD("info tapped")

                                            }
                                        }) {
                                            resizableButtonImage(systemName:
                                                                    "info.bubble.fill",
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
            .alert("Rename self", isPresented: $presentUserAvatarRenamer, actions: {
                TextField("New name", text: $newUsersName)

                Button("Rename", action: {
                    settingsViewModel.savedUserAvatar = newUsersName

                })
                Button("Cancel", role: .cancel, action: {
                    presentGptAvatarRenamer = false
                })
            }, message: {
                Text("Please enter new name for yourself")
            })
            .alert("Rename gpt", isPresented: $presentGptAvatarRenamer, actions: {
                TextField("New name", text: $newGPTName)

                Button("Rename", action: {
                    settingsViewModel.savedBotAvatar = newGPTName

                })
                Button("Cancel", role: .cancel, action: {
                    presentGptAvatarRenamer = false
                })
            }, message: {
                Text("Please enter new name for gpt")
            })
            .background(settingsViewModel.backgroundColor
                .edgesIgnoringSafeArea(.all))

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

        DispatchQueue.main.async {

            // Execute your action here
            screamer.sendCommand(command: "setLoadMode \(modes[currentModeIndex])")
        }
    }
}
