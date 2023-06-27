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

    @State private var scrollViewID = UUID()
    @State private var showAPISettings = false

    @State var presentRenamer: Bool = false
    @State private var newName: String = ""
    @State var renamingConvo: Conversation? = nil

    @State var apiSettingsTitleLabelString: String = "▶️ API settings"
    @State var sizesSettingsTitleLabelString: String = "▶️ Size settings"
    @State var colorSettingsTitleLabelString: String = "▶️ Color settings"
    @State var audioSettingsTitleLabelString: String = "▶️ Audio settings"

    @State var presentUserAvatarRenamer: Bool = false {
        didSet {
            if #available(iOS 16.0, *) {
            }
            else {
#if !os(macOS)
                if presentUserAvatarRenamer {
                    LogicSage.alert(subject: "self")
                }
#endif
            }
        }
    }
    @State var presentGptAvatarRenamer: Bool = false {
        didSet {
            if #available(iOS 16.0, *) {
            }
            else {
#if !os(macOS)
                if presentGptAvatarRenamer {
                    LogicSage.alert(subject: "GPT")
                }
#endif
            }
        }
    }

    @State private var newUsersName: String = ""
    @State private var newGPTName: String = ""
    @Binding var tabSelection: Int

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
                                            scrollViewID = UUID()
                                            tabSelection = 1
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                        //.fontWeight(.bold)
                                            .font(.body)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
#if !os(macOS)
                                            .hoverEffect(.lift)
#endif
                                    }
                                }

                                Text("Settings:")
                                    .font(.title2)
                                    .foregroundColor(settingsViewModel.appTextColor)

                                Text("scroll down 📜⬇️4 more")
                                    .font(.title3)
                                    .foregroundColor(settingsViewModel.appTextColor)
                            }
                            .padding(.top, 30)
                            .padding(.leading,8)
                            .padding(.trailing,8)
                        }

                        VStack {
                            HStack {
                                Group {
                                    VStack {
                                        Button(action: {
                                            withAnimation {
                                                showSettings.toggle()
                                                showHelp.toggle()
//                                                tabSelection = 1

                                                logD("HELP tapped")
                                            }
                                        }) {
                                            resizableButtonImage(systemName:
                                                                    "questionmark",
                                                                 size: geometry.size)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
#if !os(macOS)
                                            .hoverEffect(.lift)
#endif
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
//                                                tabSelection = 1

                                                logD("info tapped")
                                            }
                                        }) {
                                            resizableButtonImage(systemName:
                                                                    "info",
                                                                 size: geometry.size)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
#if !os(macOS)
                                            .hoverEffect(.lift)
#endif
                                        }
                                        // BUTTON FOR (i) info
                                        Text("info")
                                            .foregroundColor(settingsViewModel.appTextColor)
                                    }
                                }
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)

                            Spacer()
                        }


                        VStack {
                            Group {
                                Text(apiSettingsTitleLabelString)

                                    .font(.title3)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .padding(8)
#if !os(macOS)
                                    .hoverEffect(.automatic)
#endif
                            }
                            .onTapGesture {
                                playSelect()
                                withAnimation {
                                    showAPISettings.toggle()
                                    apiSettingsTitleLabelString = "\(showAPISettings ? "🔽" : "▶️") API settings"

                                }
                            }
                        }
                        if showAPISettings {

                            Group {
                                VStack {
                                    Text("A.I. 🔑: ")
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                    if #available(iOS 16.0, *) {

                                        TextField(
                                            "",
                                            text: $settingsViewModel.openAIKey
                                        )
                                        .border(.secondary)
                                        .submitLabel(.done)
                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(xrOS)
                                        .scrollDismissesKeyboard(.interactively)
#endif
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .autocorrectionDisabled(true)
#if !os(macOS)
                                        .autocapitalization(.none)
#endif
                                    }
                                    else {
                                        TextField(
                                            "",
                                            text: $settingsViewModel.openAIKey
                                        )
                                        //.border(.secondary)
                                        // .submitLabel(.done)

                                        //     .focused($field1IsFocused)

                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                                        //.scrollDismissesKeyboard(.interactively)
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                        .autocorrectionDisabled(true)
#if !os(macOS)
                                        .autocapitalization(.none)
#endif
                                    }
                                    Spacer()

                                    Text("A.I. model: ")
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                    if #available(iOS 16.0, *) {

                                        TextField(
                                            "",
                                            text: $settingsViewModel.openAIModel
                                        )
                                        .border(.secondary)
                                        .submitLabel(.done)
                                        // .focused($field2IsFocused)

                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(xrOS)

                                        .scrollDismissesKeyboard(.interactively)
#endif
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .autocorrectionDisabled(true)
#if !os(macOS)
                                        .autocapitalization(.none)
#endif
                                    }
                                    else {
                                        TextField(
                                            "",
                                            text: $settingsViewModel.openAIModel
                                        )

                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .autocorrectionDisabled(true)
#if !os(macOS)
                                        .autocapitalization(.none)
#endif
                                    }
                                    Spacer()

                                        .padding(.leading, 8)
                                        .padding(.trailing, 8)

                                    Text("GHA PAT: ")
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                    if #available(iOS 16.0, *) {

                                        TextField(
                                            "",
                                            text: $settingsViewModel.ghaPat
                                        )
                                        .border(.secondary)
                                        .submitLabel(.done)
                                        //   .focused($field3IsFocused)
                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .autocorrectionDisabled(true)
#if !os(macOS)
                                        .autocapitalization(.none)
#endif
                                    }
                                    else {
                                        TextField(
                                            "",
                                            text: $settingsViewModel.ghaPat
                                        )
                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .autocorrectionDisabled(true)
#if !os(macOS)
                                        .autocapitalization(.none)
#endif
                                    }
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

                            if USE_CHATGPT {
                                Toggle(isOn: $settingsViewModel.chatGPTAuth) {
                                    Text("ChatGPT Auth:")
                                        .font(.caption)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                }
                                .frame( maxWidth: geometry.size.width / 3)
                            }
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


                        Group {
                            Text(sizesSettingsTitleLabelString)
                                .font(.title3)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .padding(4)
#if !os(macOS)
                                .hoverEffect(.automatic)
#endif

                        }
                        .onTapGesture {
                            withAnimation {
                                playSelect()
                                
                                settingsViewModel.showSizeSliders.toggle()

                                sizesSettingsTitleLabelString = "\(settingsViewModel.showSizeSliders ? "🔽" : "▶️") Size settings"
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
                        Text(colorSettingsTitleLabelString)
                            .font(.title3)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .padding(8)
#if !os(macOS)
                            .hoverEffect(.automatic)
#endif
                    }
                    .onTapGesture {
                        playSelect()

                        withAnimation {

                            settingsViewModel.showAllColorSettings.toggle()

                            colorSettingsTitleLabelString =  "\(settingsViewModel.showAllColorSettings ? "🔽" : "▶️") Color settings"
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
                                        .font(.body)
                                        .padding()
                                        .onTapGesture {
                                            logD("Tapped Deep Space Sparkle theme")
                                            settingsViewModel.applyTheme(theme: .deepSpace)
                                        }
                                    Text("Hackeresque")
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .font(.body)
                                        .padding()
                                        .onTapGesture {
                                            logD("Tapped Hackeresque theme")
                                            settingsViewModel.applyTheme(theme: .hacker)
                                        }
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
                            Text("\(settingsViewModel.showSourceEditorColorSettings ? "🔽" : "▶️") More Color settings")
                                .font(.title3)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .padding(4)
#if !os(macOS)
                                .hoverEffect(.automatic)
#endif
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
                        Text(audioSettingsTitleLabelString)
                            .font(.title3)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .padding(8)
#if !os(macOS)
                            .hoverEffect(.automatic)
#endif

                    }
                    .onTapGesture {
                        playSelect()

                        withAnimation {

                            settingsViewModel.showAudioSettings.toggle()

                            audioSettingsTitleLabelString = "\(settingsViewModel.showAudioSettings ? "🔽" : "▶️") Audio settings"
                        }
                    }
                    // TODO:Double check toggling ducing Audio and audio output this way works.
                    if settingsViewModel.showAudioSettings {
                        // IOS AUDIO SETTING ON/OFF
                        Toggle(isOn: $settingsViewModel.voiceOutputEnabled) {
                            VStack(spacing: 4) {
                                Text("Audio Output")
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .frame( maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .frame( maxWidth: geometry.size.width / 3)
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
                                .frame( maxWidth: geometry.size.width / 3)
                            }
                        }
                    }

                    VStack {
                        if settingsViewModel.showAudioSettings && settingsViewModel.voiceOutputEnabled {
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
                                .frame(height: CGFloat(settingsViewModel.installedVoices.count * 2))
                            }
                        }
                    }
                    .frame( maxWidth: .infinity, maxHeight: .infinity)
                    Button(action: {
                        withAnimation {
                            scrollViewID = UUID()
                            showSettings.toggle()
                            tabSelection = 1
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(8)
                    }
                    .padding(.bottom)

                    .modify { view in

                        if #available(iOS 16.0, *) {

                            view.alert("Rename self", isPresented: $presentUserAvatarRenamer, actions: {
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
                        }
                        else {
                        }
                    }
                    .modify { view in

                        if #available(iOS 16.0, *) {
                            view.alert("Rename gpt", isPresented: $presentGptAvatarRenamer, actions: {
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
                        }
                        else {
                        }

                    }
                    Spacer()
                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
                .padding(geometry.size.width * 0.01)
                .padding(.bottom, 30)
#if !os(macOS)
                .background(settingsViewModel.backgroundColor)
#endif
            }
            .background(settingsViewModel.backgroundColor
                .edgesIgnoringSafeArea(.all))

            .onAppear {
#if !os(macOS)
                UIScrollView.appearance().bounces = false
#endif
            }
            .id(self.scrollViewID)
        }
    }

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        if #available(iOS 16.0, *) {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
                .tint(settingsViewModel.buttonColor)
#if !os(macOS)
                .background(settingsViewModel.backgroundColor)
#endif

        } else {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
#if !os(macOS)
                .background(settingsViewModel.backgroundColor)
#endif
        }
    }
}


public extension View {
    @ViewBuilder
    func modify<Content: View>(@ViewBuilder _ transform: (Self) -> Content?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }

}
#if !os(macOS)

func alert(subject: String, convoId: Conversation.ID? = nil) {
    let alert = UIAlertController(title: "Rename \(subject)?", message: nil, preferredStyle: .alert)
    alert.addTextField() { textField in
        textField.placeholder = "New name"
    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
    alert.addAction(UIAlertAction(title: "Rename", style: .default) { text in
        if subject == "self" {
            SettingsViewModel.shared.savedUserAvatar = alert.textFields?.first?.text ?? ""
        }
        else if subject == "GPT" {
            SettingsViewModel.shared.savedBotAvatar = alert.textFields?.first?.text ?? ""
        }
        else if subject == "convo" {
            if let convoID = convoId {
                SettingsViewModel.shared.renameConvo(convoID, newName: alert.textFields?.first?.text ?? "")

            }
            else {
                logD("no rn")
            }

        }
    })
    showAlert(alert: alert)
}

func showAlert(alert: UIAlertController) {
    if let controller = topMostViewController() {
        controller.present(alert, animated: true)
    }
}

private func keyWindow() -> UIWindow? {
    return UIApplication.shared.connectedScenes
        .filter {$0.activationState == .foregroundActive}
        .compactMap {$0 as? UIWindowScene}
        .first?.windows.filter {$0.isKeyWindow}.first
}

private func topMostViewController() -> UIViewController? {
    guard let rootController = keyWindow()?.rootViewController else {
        return nil
    }
    return topMostViewController(for: rootController)
}

private func topMostViewController(for controller: UIViewController) -> UIViewController {
    if let presentedController = controller.presentedViewController {
        return topMostViewController(for: presentedController)
    } else if let navigationController = controller as? UINavigationController {
        guard let topController = navigationController.topViewController else {
            return navigationController
        }
        return topMostViewController(for: topController)
    } else if let tabController = controller as? UITabBarController {
        guard let topController = tabController.selectedViewController else {
            return tabController
        }
        return topMostViewController(for: topController)
    }
    return controller
}
#endif
