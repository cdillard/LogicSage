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

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("Welcome to LogicSage!")
                        .background(.green)
                        .opacity(0.7)
                        .font(.body)
                        .lineLimit(nil)
                        .bold()
                        .padding(geometry.size.width * 0.01)

                    VStack(alignment: .leading, spacing: 8) {
                        Group {
                            Group {
                                Text("DISCLAIMER: I am not responsible for any issues (legal or otherwise) that may arise from using the code in this repository. This is an experimental project, and I cannot guarantee its contents.")
                                Text("Check out LogicSage GitHub: https://github.com/cdillard/SwiftSage#readme for more help and Discussions and my contact info.")

                                Text("This app/project is an ALPHA. email me with issues/suggestions.")

                                Text("You will start in `mobile` mode. Check out Settings to set your key. Set up server to use computer mode. computer mode allows you to use Xcode from your iOS device.")
                            }
                            Text("PLEASE READ ****")
                            Text("Due to this being an alpha please do this on launch:\n1. Force quit / restart app.\nrTap gear, set terminal bg, terminal font color, button color, set font size. Then  Force quit / restart app one last time. Restart the app and you should have your custom colors :)")

                            Text("Check out the repo for info on setting up server.")

                            Text("To Run The server: Make sure you have at minimum taken these steps:")
                            Text("0. Set your Computers API Key for A.I. in GPT-Info.plist and enabled feature flag swiftSageIOSEnabled before building and running the LogicSage Xcode project.")
                            Text("1. Running SwiftSage Swifty-GPT cmd line target on your command line Mac.")
                            Text("2. Running the vapor server.")
                        }
                        Text("Without these 3 steps, the LogicSage server will not work.")

                        Text("Tips: - You can dock terminals to side of screen to get them out of way.")
                    }
                    .background(.green)
                    .opacity(0.7)
                    .padding(geometry.size.width * 0.01)

                    Button(action: {

//                        if !hasSeenInstructions() {
//                            settingsViewModel.textSize = defaultTerminalFontSize
//                        }

                        isPresented = false
                        setHasSeenInstructions(true)
#if !os(macOS)

                        // consoleManager.isVisible = true
                        //consoleManager.fontSize = settingsViewModel.textSize

                        consoleManager.print(logoAscii5)
#endif
                    }) {
                        Text("Got it!")
                            .foregroundColor(.white)
                            .padding(geometry.size.width * 0.01)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(geometry.size.width * 0.01)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.black.opacity(0.8))
                .edgesIgnoringSafeArea(.all)
            }
            .onAppear {
                UIScrollView.appearance().bounces = false
            }
            
        }
    }
}
