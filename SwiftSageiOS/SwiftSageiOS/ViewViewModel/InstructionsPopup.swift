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
                                Text("Check out LogicSage GitHub: https://github.com/cdillard/LogicSage#readme for more help and Discussions and my contact info.")
                                    .accentColor(settingsViewModel.buttonColor)
                                Text("This app/project is an ALPHA. email me with issues/suggestions.")

                                Text("You will start in `mobile` mode. Check out Settings to set your key. Set up server to use computer mode. computer mode allows you to use Xcode from your iOS device.")
                            }

                            Text("Check out the repo for info on setting up server.")
                            Text("To Run The server: Make sure you have at minimum taken these steps:")
                            Text("0. Set your Computers API Key for A.I. in GPT-Info.plist and enabled feature flag swiftSageIOSEnabled before building and running the LogicSage ./run.sh")
                        }
                        Text("Without this step, the LogicSage server will not work.")

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

                        settingsViewModel.initalAnim = true

                    }) {
                        Text("Got it!")
                            .foregroundColor(.white)
                            .padding(geometry.size.width * 0.01)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(geometry.size.width * 0.01)
                }
                .padding(.top, 30)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .background(settingsViewModel.backgroundColor)
            .onAppear {
#if !os(macOS)
                UIScrollView.appearance().bounces = false
#endif
            }
            
        }
    }
}
