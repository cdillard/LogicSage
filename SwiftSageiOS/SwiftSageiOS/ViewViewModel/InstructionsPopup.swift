//
//  File.swift
//  SwiftSageiOS
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
                                Text("DISCLAIMER: I am not responsible for any issues (legal or otherwise) that may arise from using the code in this repository. This is an experimental project, and I cannot guarantee its contents.")
                                Text("Check out LogicSage GitHub: https://github.com/cdillard/LogicSage#readme for more help and Discussions and my contact info.")
                                    .accentColor(settingsViewModel.buttonColor)
                                Text("This app/project is an ALPHA. Email me with issues/suggestions @")
                                Button(action: {
#if !os(macOS)
                                    let pasteboard = UIPasteboard.general
                                    pasteboard.string = email
                                    onCopy()

#endif
                                }) {
                                    Text(verbatim: "\(email) (Tap to Copy)")
                                        .foregroundColor(settingsViewModel.buttonColor)
                                }
                                Text("Check out Settings to set your A.I. key. Set up LogicSage for Mac to use additional functions from the Term window. Term window with LogicSage for Mac allows you to use Xcode from your iOS device.")
                            }

                            Text("Check out the repo for info on setting up server.")
                            Text("To Run The server: Make sure you have at minimum taken these steps:")
                            Text("0. Set your Computers API Key for A.I. in GPT-Info.plist before building and running the LogicSage for Mac via ./run.sh")
                            Text("Without this step, the LogicSage server will not work.")
                        }

                        Text("-CREDITS: https://github.com/cdillard/LogicSage#credits")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .accentColor(settingsViewModel.buttonColor)

                        Text("Thank you!!! to the open source maintainers who created the MIT and Apache 2.0 Licensed source included in this project.")
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
                    }
                    .padding(geometry.size.width * 0.01)
                }
                .padding(.top, 30)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            }
            .overlay(CheckmarkView(isVisible: $showCheckmark))

            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .edgesIgnoringSafeArea(.all)
            .background(settingsViewModel.backgroundColor)
            .onAppear {
#if !os(macOS)
                UIScrollView.appearance().bounces = false
#endif
            }

        }
        
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
