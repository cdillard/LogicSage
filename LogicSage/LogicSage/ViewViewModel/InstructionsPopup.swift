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
    let email = "chrisbdillard@gmail.com"
    @State private var showCheckmark: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("Welcome to LogicSage!")
                        .opacity(0.7)
                        .font(.title2)
                        .lineLimit(nil)
                        .foregroundColor(settingsViewModel.appTextColor)
                    
                        .padding(geometry.size.width * 0.01)
                    Text("scroll down 📜⬇️4 more")
                        .font(.title2)
                        .foregroundColor(settingsViewModel.appTextColor)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Group {
                            Group {
                                Text("Welcome to LogicSage, an AI coding and chatting app! LogicSage is a 'Bring Your Own API Key' app. Before you can start chatting, you need to enter an OpenAI API Key (https://platform.openai.com/account/api-keys).")
                                    .minimumScaleFactor(0.466)
                                
                                Text("Please enter your API Key (via copy and paste) and it will be stored securely offline in your devices keychain. (Check the source code if you want)")
                                    .minimumScaleFactor(0.466)
                                
                                VStack(spacing:2) {
                                    Text("A.I. 🔑: ")
                                        .font(.title3)
                                        .foregroundColor(settingsViewModel.appTextColor)
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
#if !os(macOS)
                                    .autocorrectionDisabled(!true)
#endif
#if !os(macOS)
                                    .autocapitalization(.none)
#endif
                                }
                                Divider()
                                Text("Check out LogicSage GitHub: https://github.com/cdillard/LogicSage#readme for more help and to post Github issues.")
                                    .accentColor(settingsViewModel.buttonColor)
                                
                            }
                            
                            Text("Download repository from github and execute ./run.sh from project root to start LogicSage for Mac Server.")
                        }
                        Divider()
                        
                        Text("-CREDITS: https://github.com/cdillard/LogicSage#credits")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .accentColor(settingsViewModel.buttonColor)
                        
                        Text("Thank you!!! to the open source maintainers who created the MIT and Apache 2.0 Licensed source included in this project.")
                        Divider()
                        
                        Text("DISCLAIMER: I am not responsible for any issues (legal or otherwise) that may arise from using the code in this repository. This is an experimental project, and I cannot guarantee its contents.")
                        Divider()
                        
                        Text("This app/project is an experiment. Email me with your issues, suggestions, or just to chat @")
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
                    
                    Button(action: {
                        isPresented = false
                        setHasSeenInstructions(true)
                        if !hasSeenAnim() {
                            settingsViewModel.initalAnim = true
                        }
                    }) {
                        Text("Got it!")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .padding(geometry.size.width * 0.01)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(8)
                            .minimumScaleFactor(0.466)
                        
                    }
                    .padding(geometry.size.width * 0.01)
                    .padding(.bottom, 20)
                    
                    .padding(.vertical, 20)
                }
                .padding(.top, 30)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            }
            .overlay(CheckmarkView(text: "Copied", isVisible: $showCheckmark))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(settingsViewModel.backgroundColor)
            .onAppear {
#if !os(macOS)
                UIScrollView.appearance().bounces = false
#endif
            }
        }
#if os(xrOS)
        .padding()
        .glassBackgroundEffect()
#endif
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
