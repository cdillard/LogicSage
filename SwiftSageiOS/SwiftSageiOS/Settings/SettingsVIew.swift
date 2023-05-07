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

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                        Group {
                            HStack {
                                Text("Settings:")
                                    .font(.body)

                                    .padding(.bottom)

                                Text("for more scroll down 📜⬇️")
                                    .font(.body)

                                    .padding(.bottom)
                            }
                            Group {
                                VStack(alignment: .leading, spacing: 3) {

                                    ColorPicker("Terminal Background Color", selection: $settingsViewModel.terminalBackgroundColor)
                                    .padding(.horizontal, 8)
                                }
                                VStack(alignment: .leading, spacing: 3) {

                                    ColorPicker("Terminal Text Color", selection: $settingsViewModel.terminalTextColor)
                                    .padding(.horizontal, 8)
                                }
                                VStack(alignment: .leading, spacing: 3) {

                                    ColorPicker("Button Color", selection: $settingsViewModel.buttonColor)
                                    .padding(.horizontal, 8)
                                }

                                VStack(alignment: .leading, spacing: 3) {

                                    ColorPicker("Background Color", selection: $settingsViewModel.backgroundColor)
                                    .padding(.horizontal, 8)
                                }
                            }
                            Group {
                                Text("\(settingsViewModel.showSourceEditorColorSettings ? "hide" : "show") srceditor colors").font(.body)
                            }
                            .onTapGesture {
                                settingsViewModel.showSourceEditorColorSettings.toggle()
                            }
                            if settingsViewModel.showSourceEditorColorSettings {
                                // SOURCE CODE EDITOR CUSTOM COLORS
                                // TODO FINISH THE ADDITIONS IN Settings VM
                                Group {


                                    VStack(alignment: .leading, spacing: 3) {

                                        ColorPicker("Plain srceditor clr", selection: $settingsViewModel.plainColorSrcEditor)
                                            .padding(.horizontal, 8)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {

                                        ColorPicker("Number srceditor clr", selection: $settingsViewModel.numberColorSrcEditor)
                                            .padding(.horizontal, 8)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {

                                        ColorPicker("String srceditor clr", selection: $settingsViewModel.stringColorSrcEditor)
                                            .padding(.horizontal, 8)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {

                                        ColorPicker("Identifier srceditor clr", selection: $settingsViewModel.identifierColorSrcEditor)
                                            .padding(.horizontal, 8)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {

                                        ColorPicker("Keyword srceditor clr", selection: $settingsViewModel.keywordColorSrcEditor)
                                            .padding(.horizontal, 8)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {

                                        ColorPicker("Comment srceditor clr", selection: $settingsViewModel.commentColorSrceEditor)
                                            .padding(.horizontal, 8)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {

                                        ColorPicker("Editor plchold srceditor clr", selection: $settingsViewModel.editorPlaceholderColorSrcEditor)
                                            .padding(.horizontal, 8)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {

                                        ColorPicker("Bg srceditor clr", selection: $settingsViewModel.backgroundColorSrcEditor)
                                            .padding(.horizontal, 8)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {

                                        ColorPicker("Line number srceditor clr", selection: $settingsViewModel.lineNumbersColorSrcEditor)
                                            .padding(.horizontal, 8)
                                    }

                                }
                            }

                            Group {
                                Text("sws mode").font(.body)
                                DevicePicker(settingsViewModel: settingsViewModel)
                            }
                            VStack(alignment: .leading) {
                                if settingsViewModel.currentMode == .computer {
                                    HStack {
                                        Text("sws username: ").font(.body)
                                        TextEditor(text: $settingsViewModel.userName)
                                            .scrollDismissesKeyboard(.interactively)

                                            .font(.footnote)
                                            .autocorrectionDisabled(true)
#if !os(macOS)

                                            .autocapitalization(.none)
#endif

                                    }
                                    .frame(height: 22)

                                    HStack {
                                        Text("sws password: ").font(.body)

                                        TextEditor(text: $settingsViewModel.password)
                                            .scrollDismissesKeyboard(.interactively)

                                            .font(.footnote)
                                            .autocorrectionDisabled(true)
#if !os(macOS)

                                            .autocapitalization(.none)
#endif


                                    }
                                    .frame(height: 22)

                                }
                                else if settingsViewModel.currentMode == .mobile {
                                    HStack {
                                            VStack {
                                                HStack {
                                                    Text("A.I. 🔑: ").font(.body)

                                                    TextEditor(text: $settingsViewModel.openAIKey)
                                                        .frame( maxWidth: .infinity, maxHeight: .infinity)

                                                        .scrollDismissesKeyboard(.interactively)
                                                        .font(.body)
                                                        .autocorrectionDisabled(true)
#if !os(macOS)

                                                        .autocapitalization(.none)
#endif
                                                }
                                                .frame(height: geometry.size.height / 13)

                                                HStack {
                                                    Text("A.I. model: ").font(.body)

                                                    TextEditor(text: $settingsViewModel.openAIModel)
                                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                                                        .scrollDismissesKeyboard(.interactively)
                                                        .font(.body)
                                                        .autocorrectionDisabled(true)
#if !os(macOS)

                                                        .autocapitalization(.none)

#endif
                                                }
                                                .frame(height: geometry.size.height / 13)

                                                HStack {
                                                    Text("GHA PAT: ").font(.body)

                                                    TextEditor(text: $settingsViewModel.ghaPat)
                                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                                                        .scrollDismissesKeyboard(.interactively)
                                                        .font(.body)
                                                        .autocorrectionDisabled(true)
#if !os(macOS)

                                                        .autocapitalization(.none)

#endif
                                                }
                                                .frame(height: geometry.size.height / 17)

                                                HStack {
                                                    Text("git user: ").font(.body)

                                                    TextEditor(text: $settingsViewModel.gitUser)
                                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                                                        .scrollDismissesKeyboard(.interactively)
                                                        .font(.body)
                                                        .autocorrectionDisabled(true)
#if !os(macOS)

                                                        .autocapitalization(.none)

#endif
                                                }
                                                .frame(height: geometry.size.height / 17)
                                                HStack {
                                                    Text("git repo: ").font(.body)

                                                    TextEditor(text: $settingsViewModel.gitRepo)
                                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                                                        .scrollDismissesKeyboard(.interactively)
                                                        .font(.body)
                                                        .autocorrectionDisabled(true)
#if !os(macOS)

                                                        .autocapitalization(.none)

#endif
                                                }
                                                .frame(height: geometry.size.height / 17)
                                                HStack {
                                                    Text("git branch: ").font(.body)

                                                    TextEditor(text: $settingsViewModel.gitBranch)
                                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                                                        .scrollDismissesKeyboard(.interactively)
                                                        .font(.body)
                                                        .autocorrectionDisabled(true)
#if !os(macOS)

                                                        .autocapitalization(.none)

#endif
                                                }
                                                .frame(height: geometry.size.height / 17)
                                            }
                                            .frame( maxWidth: .infinity, maxHeight: .infinity)

                                    }

                                }
                            }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Group {
                            Text("Text Size")
                                .fontWeight(.semibold)
                            HStack {
                                Text("Small")
                                Slider(value: $settingsViewModel.textSize, in: 2...30, step: 0.1)
                                    .accentColor(settingsViewModel.buttonColor)
                                Text("Large")
                            }
                            Text("\(settingsViewModel.textSize)")
                                .font(.body)
                                .lineLimit(nil)
                        }
                        Group {
                            Text("SrcEditor Text Size")
                                .fontWeight(.semibold)
                            HStack {
                                Text("Small")
                                Slider(value: $settingsViewModel.sourceEditorFontSizeFloat, in: 4...64, step: 1)
                                    .accentColor(settingsViewModel.buttonColor)
                                Text("Large")
                            }
                            Text("\(settingsViewModel.sourceEditorFontSizeFloat)")
                                .font(.body)
                                .lineLimit(nil)
                        }
                        Group {
                            Text("Toolbar size")
                                .fontWeight(.semibold)
                            HStack {
                                Text("Small")
                                Slider(value: $settingsViewModel.buttonScale, in:  0.1...0.45, step: 0.01)
                                    .accentColor(settingsViewModel.buttonColor)
                                Text("Large")
                            }
                            Text("\(settingsViewModel.buttonScale)")
                                .font(.body)
                                .lineLimit(nil)
                        }
                        Group {
                            Text("CMD bar size")
                                .fontWeight(.semibold)
                            HStack {
                                Text("Small")
                                Slider(value: $settingsViewModel.commandButtonFontSize, in:  10...64, step: 0.01)
                                    .accentColor(settingsViewModel.buttonColor)
                                Text("Large")
                            }
                            Text("\(settingsViewModel.commandButtonFontSize)")
                                .font(.body)
                                .lineLimit(nil)
                        }
                        Group {
                            Text("middle handle size")
                                .fontWeight(.semibold)
                            HStack {
                                Text("Small")
                                Slider(value: $settingsViewModel.middleHandleSize, in:  18...48, step: 1)
                                    .accentColor(settingsViewModel.buttonColor)
                                Text("Large")
                            }
                            Text("\(settingsViewModel.middleHandleSize)")
                                .font(.body)
                                .lineLimit(nil)
                        }
                        Group {
                            Text("corner handle size")
                                .fontWeight(.semibold)
                            HStack {
                                Text("Small")
                                Slider(value: $settingsViewModel.cornerHandleSize, in:  18...48, step: 1)
                                    .accentColor(settingsViewModel.buttonColor)
                                Text("Large")
                            }
                            Text("\(settingsViewModel.cornerHandleSize)")
                                .font(.body)
                                .lineLimit(nil)
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
                                        Text("📙")
                                    }
                                    if settingsViewModel.autoCorrect {
                                        Text("❌")
                                            .opacity(0.74)
                                    }
                                }
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSizeFloat))
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
                                    .fontWeight(.semibold)
                                HStack {
                                    Button(action: {
                                        withAnimation {
                                            updateMode()
                                        }
                                    }) {
                                        Text(".\(modes[currentModeIndex])")
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
                                    }
                                    .padding(.bottom)
                                }
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
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
                        VStack {
                            Text("Choose Avatar")
                                .foregroundColor(settingsViewModel.buttonColor)
                                .font(.body)

                            Text("👨")
                                .fontWeight(.bold)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(8)
                        }
                    }
                    .frame( maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom)


                    // ENABLE MIC BUTTON
                    Text("\(settingsViewModel.hasAcceptedMicrophone == true ? "Mic enabled" : "Enable mic")")
                        .frame( maxWidth: .infinity, maxHeight: .infinity)

                    Button(action: {
                        withAnimation {
#if !os(macOS)
                            consoleManager.print("Requesing mic permission...")
#endif
                            requestMicrophoneAccess { granted in
//                                microphoneAccess = granted
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
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                    HStack {
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
                            //.foregroundColor(.white)
                            //                        .padding(.horizontal, 40)
                            //                        .padding(.vertical, 12)
                            //.background(settingsViewModel.buttonColor)
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
                                            .font(.body)
                                        Text("🦆")
                                    }
                                    if settingsViewModel.duckingAudio {
                                        Text("❌")
                                            .opacity(0.74)
                                    }
                                }
                                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSizeFloat))
                                .lineLimit(1)
                                .background(settingsViewModel.buttonColor)
                                .fontWeight(.bold)
                                .cornerRadius(8)
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                        }
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
                                            if settingsViewModel.selectedVoiceIndexSaved == index {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(settingsViewModel.buttonColor)
                                                    .alignmentGuide(HorizontalAlignment.center, computeValue: { d in d[HorizontalAlignment.center] })
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            settingsViewModel.selectedVoiceIndexSaved = index
                                            settingsViewModel.selectedVoice = settingsViewModel.installedVoices[settingsViewModel.selectedVoiceIndexSaved]
                                        }
                                        .frame(height: 30)
                                    }
                                }
                                .frame(height: CGFloat(settingsViewModel.installedVoices.count * 2))
                            }

                        }

                        HStack {
                            VStack {
                                // Button for (help)
                                Text("help")
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
                                .padding(.bottom)

                                // BUTTON FOR (i) info
                                Text("info")
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
                                .padding(.bottom)
// TODO: Implement changing mac os voice from ios app
//                                if settingsViewModel.currentMode == .computer {
//                                    Text("\(settingsViewModel.voiceOutputenabled ? "Disable" : "Enable") MACOS audio output")
//                                    Button  {
//                                        withAnimation {
//#if !os(macOS)
//                                            print("TODO: IMPLEMENT ENABLE/DISABLE MAC OS AUDIO FROM IOS")
//                                            //                                    consoleManager.print("toggling audio \(settingsViewModel.voiceOutputenabled ? "off" : "on.")")
//                                            //                                    if settingsViewModel.voiceOutputenabled {
//                                            //                                        stopVoice()
//                                            //                                    }
//                                            //                                    else {
//                                            //                                        configureAudioSession()
//                                            //                                    }
//                                            //                                    settingsViewModel.voiceOutputenabled.toggle()
//                                            //                                    settingsViewModel.voiceOutputenabledUserDefault.toggle()
//
//#endif
//                                        }
//
//                                    } label: {
//                                        resizableButtonImage(systemName:
//                                                                settingsViewModel.voiceOutputenabled ? "speaker.wave.2.bubble.left.fill" : "speaker.slash.circle.fill",
//                                                             size: geometry.size)
//                                        .fontWeight(.bold)
//                                        //                                    .foregroundColor(.white)
//                                        //                                    .padding(.horizontal, 40)
//                                        //                                    .padding(.vertical, 12)
//                                        .background(settingsViewModel.buttonColor)
//                                        .cornerRadius(8)
//                                    }
//                                }
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)

                            Spacer()
                        }

//                        if settingsViewModel.currentMode == .computer {
//
//                            Text("Pick macOS server voice")
//
//                            List(cereprocVoicesNames, id: \.self) { name in
//                                Text(name)
//                                    .frame(height: 30)
//                            }
//                            .frame(height: CGFloat(cereprocVoicesNames.count * 40))
//                        }

                    }
                    .frame( maxWidth: .infinity, maxHeight: .infinity)

                    Spacer()


                    HStack {
                        Button(action: {
                            withAnimation {
                                showSettings.toggle()
                            }
                        }) {
                            Text("Close")
                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 40)
//                                .padding(.vertical, 12)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(8)
                        }
                        .padding(.bottom)
                    }
                    .frame( maxWidth: .infinity, maxHeight: .infinity)

                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
                .padding(geometry.size.width * 0.01)
                .onAppear {
                    settingsViewModel.setColorsToDisk()
                }
                .padding(.bottom, 30)
#if !os(macOS)

                .background(settingsViewModel.backgroundColor)
#endif
                
            }
            .onAppear {
#if !os(macOS)
                UIScrollView.appearance().bounces = false
#endif
            }

            .scrollIndicators(.visible)
        }
    }

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
            .tint(settingsViewModel.buttonColor)
            .background(CustomShape())
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


struct DevicePicker: View {
    @State  var isExpanded = true
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        // Your component view will be here
        ZStack {
            RoundedRectangle(cornerRadius: isExpanded ? 10 : 30)
                .fill(Color.blue)
                .frame(width: isExpanded ? 250 : 60, height: 60)

            HStack(spacing: 30) {
                Image(systemName: "iphone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .opacity(settingsViewModel.currentMode == .mobile ? 1 : 0.5)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            settingsViewModel.currentMode = .mobile

                        }
                    }
                Image(systemName: "desktopcomputer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .opacity(settingsViewModel.currentMode == .computer ? 1 : 0.5)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            settingsViewModel.currentMode = .computer
                        }
                    }
            }
            .padding(.horizontal, isExpanded ? 20 : 0)
            .opacity(isExpanded ? 1 : 0)
        }
    }
}
