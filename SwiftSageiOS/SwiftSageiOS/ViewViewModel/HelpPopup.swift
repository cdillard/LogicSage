//
//  HelpPopup.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/3/23.
//

import Foundation
import Foundation
import SwiftUI
import UIKit

struct HelpPopup: View {
    @Binding var isPresented: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State var veryGoodOpen: Bool = false
    let email = "chrisbdillard@gmail.com"

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("HELP:")
                        .background(.green)
                        .opacity(0.7)
                        .font(.body)
                        .lineLimit(nil)
                        .bold()
                        .padding(geometry.size.width * 0.01)

                    VStack(alignment: .leading, spacing: 2) {
                        Group {
                            Group {
                                Group {
                                    Text("Welcome to your AI workspace. Access chats, terminal, settings and add menu from the hamburger menu at the top left.\nCheck out LogicSage GitHub: https://github.com/cdillard/LogicSage#readme for more help and Discussions and my contact info.")
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .accentColor(settingsViewModel.buttonColor)
                                    Text("This app/project is an ALPHA. Email me with issues/suggestions @")
                                    Button(action: {
                                        let pasteboard = UIPasteboard.general
                                        pasteboard.string = email
                                    }) {
                                        Text(verbatim: "\(email) (Tap to Copy.)")
                                            .foregroundColor(settingsViewModel.buttonColor)
                                    }
                                }

                                Group {
                                    
                                    Text("Tips:\nYou can dock terminals to side of screen to get them out of way.\nKeyboards can be swiped away or dismissed with Done button.\nTurn off `Button Shapes` in System Display settings.\nOn iPad, use the floating keyboard for max screen real estate and reduction of keyboard annoyance.")
                                    let verGoodMoji = veryGoodOpen ? "🔽" : "▶️"
                                    
                                    Text("Tap me! \(verGoodMoji) , I will expand/collapse a section...")
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

                                        Text("OPTIONAL: Set up server to use computer commands. This allows you to use Xcode from your iOS device in the Term window.")

                                        Text("Follow this order when running LogicSage for Mac.")
                                    }
                                    Group {
                                        Text("0. run SwiftSageServer and Swifty-GPT with ./run.sh in the Project root")
                                        Text("1. Background/Foreground your LogicSage clients, you should see websocket connected. ")

                                        Text("-COMMANDS\nCheck the following link for the Swifty-GPT server command list:\n https://github.com/cdillard/LogicSage/blob/main/Swifty-GPT/Command/CommandTable.swift\nmobile command list:\n https://github.com/cdillard/LogicSage/blob/main/SwiftSageiOS/SwiftSageiOS/Command/CommandTable.swift")
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
