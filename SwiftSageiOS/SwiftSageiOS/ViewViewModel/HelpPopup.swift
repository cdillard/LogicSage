//
//  HelpPopup.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/3/23.
//

import Foundation
import Foundation
import SwiftUI
#if !os(xrOS)
#if !os(macOS)

struct HelpPopup: View {
    @Binding var isPresented: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State var veryGoodOpen: Bool = false
    let email = "chrisbdillard@gmail.com"
    @State private var showCheckmark: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("HELP:")
                        .opacity(0.7)
                        .font(.title2)
                        .lineLimit(nil)
                        .foregroundColor(settingsViewModel.appTextColor)

                        .padding(geometry.size.width * 0.01)
                    Text("scroll down 📜⬇️4 more")
                        .font(.title2)
                        .foregroundColor(settingsViewModel.appTextColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Group {
                            Group {
                                Group {
                                    Text("Welcome to your GPT app for iPadOS (and iOS). Access Chats, Windows, Settings, and Add menu from the tab bar at the bottom.\nCheck out LogicSage GitHub: https://github.com/cdillard/LogicSage#readme for more help and Discussions and my contact info.")
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .accentColor(settingsViewModel.buttonColor)
                                    Text("This app/project is an ALPHA. Email me with issues/suggestions @")
                                    Button(action: {
#if !os(macOS)
#if !os(xrOS)

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

                                Group {
                                    Text("Tips:\nKeyboards can be swiped away by swiping down from 'Type msg...'.\nTurn off `Button Shapes` in System Display settings.\nOn iPad, use the floating keyboard for max screen real estate and reduction of keyboard annoyance.")
                                    let verGoodMoji = veryGoodOpen ? "🔽" : "▶️"
                                    
                                    Text("Tap me! \(verGoodMoji) , I will expand/collapse a section...")
                                        .font(.title3)

                                        .onTapGesture {
                                            playSelect()
                                            
                                            withAnimation {
                                                veryGoodOpen.toggle()
                                            }
                                        }
                                    if veryGoodOpen {
                                        Text("Nice. You did good.")
                                    }
                                }
                                Group {
                                    Group {
                                        Text("Set up LogicSage for Mac:")

                                        Text("OPTIONAL: Set up LogicSage for Mac to use computer commands. This allows you to use Xcode from your iOS device in the Term window.")

                                        Text("Follow this order when running LogicSage for Mac.")
                                    }
                                    Group {
                                        Text("0. run LogicSage for Mac with ./run.sh in the Project root")
                                        Text("1. Background/Foreground (or force quit, restart app (or fresh instal)) your LogicSage clients, you should see websocket connected. ")
                                        Text("-In the Term window you can use the following command list:\n https://github.com/cdillard/LogicSage/blob/main/Swifty-GPT/Command/CommandTable.swift")
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .accentColor(settingsViewModel.buttonColor)
                                    }
                                }
                            }
                        }
                    }
                    .foregroundColor(settingsViewModel.appTextColor)
                    .background(settingsViewModel.backgroundColor)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)

                    .padding(geometry.size.width * 0.02)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Button(action: {
                        isPresented = false
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
                .padding(.bottom, 60)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            }
            .overlay(CheckmarkView(isVisible: $showCheckmark))

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
#endif
#endif
