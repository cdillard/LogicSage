//
//  CommandButton.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/24/23.
//

import Foundation
import SwiftUI

struct CommandButtonView: View {
    @StateObject var settingsViewModel: SettingsViewModel
   // @FocusState var isTextFieldFocused: Bool
    @State var textEditorHeight : CGFloat = 20
    @ObservedObject var windowManager: WindowManager
    @Binding var isInputViewShown: Bool
    func openText() {
       isInputViewShown.toggle()
    }
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        DispatchQueue.main.async {
                            // Execute your action here
                            screamer.sendCommand(command: "st")
                            isInputViewShown = false
                        }
                    }) {
                        Text("🛑")
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                    }

                    Button(action: {
                        DispatchQueue.main.async {
                            settingsViewModel.latestWindowManager = windowManager

                            settingsViewModel.createAndOpenNewConvo()

                            playSelect()
                            isInputViewShown = false
                        }
                    }) {
                        Text("💬")
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(Color.white)
                            .background(settingsViewModel.buttonColor)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                    }
                }


                .padding()
            }
        }
    }
    struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value + nextValue()
        }
    }
}
struct CustomFontSize: ViewModifier {
    @Binding var size: Double

    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(size)))
    }
}
