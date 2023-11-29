//
//  File.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/26/23.
//
//████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
// █░░░░░░█████████░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█
// █░░▄▀░░█████████░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█
// █░░▄▀░░█████████░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█░░░░▄▀░░░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░░░█
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░███████████░░▄▀░░███░░▄▀░░█████████░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░█████████░░▄▀░░█████████
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░███████████░░▄▀░░███░░▄▀░░█████████░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░█████████░░▄▀░░░░░░░░░░█
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░██░░░░░░███░░▄▀░░███░░▄▀░░█████████░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░░░░░█░░▄▀▄▀▄▀▄▀▄▀░░█
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░█████████░░░░░░░░░░▄▀░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░░░░░█
// █░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░█████████████████░░▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀░░█████████
// █░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░▄▀░░█░░░░▄▀░░░░█░░▄▀░░░░░░░░░░█░░░░░░░░░░▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█
// █░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█
//
//
//
import Foundation
import SwiftUI

struct InstructionsPopup: View {
    @Binding var isPresented: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var showCheckmark: Bool = false
    @State private var showAPIKey: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("Welcome to LogicSage!")
                        .font(.title)
                        .lineLimit(nil)
                        .foregroundColor(settingsViewModel.appTextColor)
                    
                        .padding(geometry.size.width * 0.01)
#if !os(visionOS)

//                    Text("scroll down 📜⬇️4 more")
//                        .font(.title2)
//                        .foregroundColor(settingsViewModel.appTextColor)
                    #endif

                    gotItButton(size: geometry.size)

                    VStack(alignment: .leading, spacing: 8) {
                        Group {

                            Group {
                                Text("Welcome to LogicSage, an AI coding and chatting app! LogicSage is a 'Bring Your Own API Key' app. Before you can start chatting, you need to enter an AI Key.")
                                    .minimumScaleFactor(0.366)

                                Text("Please enter your API Key (via copy and paste) and it will be stored securely in your devices keychain. It will only be used when sending request to Open AI server (Source code availalbe on github). Visit settings tab to set your Google Search API Key and Secret.")
                                    .minimumScaleFactor(0.366)

                                VStack(spacing:2) {
                                    HStack {Text("A.I. 🔑: ")
                                            .font(.title3)
                                            .foregroundColor(settingsViewModel.appTextColor)

                                        Button(action: {
                                            
                                            showAPIKey.toggle()
                                        }) {
                                            Image(systemName: showAPIKey ? "eye" : "eye.slash.fill")
                                        }
                                    }
                                    if showAPIKey {
                                        TextField(
                                            "",
                                            text: $settingsViewModel.openAIKey
                                        )
                                        .minimumScaleFactor(0.666)
                                        .lineLimit(3)
                                        .border(.secondary)
                                        .submitLabel(.done)
                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(visionOS)
                                    .scrollDismissesKeyboard(.interactively)
#endif
                                    .font(.title3)
                                    .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                                    .autocorrectionDisabled(!true)
#endif
#if !os(macOS)
                                    .autocapitalization(.none)
#endif
                                    }
                                    else {
                                        SecureField(
                                            "",
                                            text: $settingsViewModel.openAIKey
                                        )
                                        .minimumScaleFactor(0.866)
                                        .lineLimit(3)

                                        .border(.secondary)
                                        .submitLabel(.done)
                                        
                                        .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(visionOS)
                                    .scrollDismissesKeyboard(.interactively)
#endif
                                    .font(.title3)
                                    .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                                    .autocorrectionDisabled(!true)
#endif
#if !os(macOS)
                                    .autocapitalization(.none)
#endif
                                    }


                                }
                                Divider()
                                Text("Check out LogicSage GitHub: https://github.com/cdillard/LogicSage#readme for more help and to post Github issues.")
                                    .minimumScaleFactor(0.366)

                                    .accentColor(settingsViewModel.buttonColor)
                                
                            }
                            
                            Text("Download repository from github and execute ./run.sh from project root to start LogicSage for Mac Server.")
                                .minimumScaleFactor(0.366)

                        }
                        Divider()
                        
                        Text("-CREDITS: https://github.com/cdillard/LogicSage#credits")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .accentColor(settingsViewModel.buttonColor)
                        
                        Text("Thank you!!! to the open source maintainers who created the MIT and Apache 2.0 Licensed source included in this project.")
                            .minimumScaleFactor(0.366)

                        Divider()
                        
                        Text("DISCLAIMER: LogicSage is not responsible for any issues (legal or otherwise) that may arise from using this app or using the code in this repository. This is an experimental project.")
                            .minimumScaleFactor(0.366)

                        Button(action: {
#if !os(macOS)
#if !os(tvOS)
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = email
                            onCopy()
#endif
#endif
                            
                        }) {
                            Text(verbatim: "\(email) (Tap to Copy)")
                                .foregroundColor(settingsViewModel.buttonColor)
                        }
                        
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .foregroundColor(settingsViewModel.appTextColor)
                    .background(settingsViewModel.backgroundColor)
                    .padding(geometry.size.width * 0.01)
                    
                    gotItButton(size: geometry.size)
                        .padding(.bottom, 20)

                        .padding(.vertical, 20)
                }
                .padding(.top, 30)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            }
            .scrollIndicators(.visible)
            .overlay(CheckmarkView(text: "Copied", isVisible: $showCheckmark))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(settingsViewModel.backgroundColor)
            .onAppear {
#if !os(macOS)
                UIScrollView.appearance().bounces = false
#endif
            }
        }
#if os(visionOS)
        .padding()
        .glassBackgroundEffect()
#endif
    }

    func gotItButton(size: CGSize) -> some View {
        Button(action: {
            isPresented = false
            setHasSeenInstructions(true)
            if !hasSeenAnim() {
                settingsViewModel.initalAnim = true
            }
        }) {
            Text("Got it!")
                .foregroundColor(settingsViewModel.appTextColor)
                .padding(size.width * 0.01)
                .background(settingsViewModel.buttonColor)
                .cornerRadius(8)
                .minimumScaleFactor(0.466)

        }
        .padding(size.width * 0.01)

    }

    private func onCopy() {
        withAnimation(Animation.easeInOut(duration: 0.666)) {
            showCheckmark = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.666) {
            withAnimation(Animation.easeInOut(duration: 0.6666)) {
                showCheckmark = false
            }
        }
    }
}
