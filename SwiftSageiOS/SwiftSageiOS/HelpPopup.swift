//
//  HelpPopup.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/3/23.
//

import Foundation
import Foundation
import SwiftUI

struct HelpPopup: View {
    @Binding var isPresented: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("HELP:")
                        .background(.green)
                        .opacity(0.7)
                        .font(.caption)
                        .lineLimit(nil)
                        .bold()
                        .padding(geometry.size.width * 0.01)

                    VStack(alignment: .leading, spacing: 2) {
                        Group {
                            Group {
                                Text("Welcome to your AI workspace. See your toolbar at the bottom left, see your command bar at the bottom right.")

                                Text("Check out LogicSage GitHub: https://github.com/cdillard/SwiftSage#readme for more help and Discussions and my contact info.")

                                Text("This app/project is an ALPHA. email me with issues/suggestions.")

                                Text("Tips:\nYou can dock terminals to side of screen to get them out of way.\nTry making button/toolbar smaller than larger to get your desired size.\nKeyboards can be swiped away or dismissed with Done button.\nTurn off `Button Shapes` in System Display settings.\nOn iPad, use the floating keyboard for max screen real estate and reduction of keyboard annoyance.")
                                Group {
                                    Text("You will start in `mobile` mode. Check out Settings to set your key. Set up server to use computer mode. computer mode allows you to use Xcode from your iOS device.")
                                    
                                    Text("OPTIONAL: Set up server to use computer mode. computer mode allows you to use Xcode from your iOS device.")
                                    
                                    Text("Follow this order when running LogicSage in computer mode.")
                                    
                                    Text("0. Start Swift Vapor Server with `vapor run`")
                                    Text("1. Start Swifty-GPT swift binary in Xcode with the play button")
                                    Text("2. Force Quit / Restart your LogicSage clients, you should see websocket connected. ")
                                    
                                    
                                    Text("## COMMANDS\nCheck the following link for the Swifty-GPT server command list:\n https://github.com/cdillard/SwiftSage/blob/main/Swifty-GPT/Command/CommandTable.swift\nmobile command list:\n https://github.com/cdillard/SwiftSage/blob/main/SwiftSageiOS/SwiftSageiOS/Command/CommandTable.swift")
                                }
                            }

                        }
                    }
                    .background(.green)
                    .opacity(0.7)
                    .padding(geometry.size.width * 0.01)

                    Button(action: {

                        isPresented = false
#if !os(macOS)

                        // consoleManager.isVisible = true
                        consoleManager.fontSize = settingsViewModel.textSize

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
                .background(Color.black.opacity(0.8))
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
