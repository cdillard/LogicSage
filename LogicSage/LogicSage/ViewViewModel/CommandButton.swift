//
//  CommandButton.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/24/23.
//

import Foundation
import SwiftUI

struct CommandButtonView: View {
    @EnvironmentObject var appModel: AppModel

    @StateObject var settingsViewModel: SettingsViewModel
    @State var textEditorHeight : CGFloat = 20
    @ObservedObject var windowManager: WindowManager
    @Binding var isInputViewShown: Bool

    // ASSISSTANT ATTRIB
    @Binding  var showDialog: Bool
    @Binding  var name: String
    @Binding  var description: String
    @Binding  var instructions: String

    //    @State private var isFilePickerShown = false
    //    @State private var picker = DocumentPicker()

    func openText() {
        isInputViewShown.toggle()
    }
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0)  {
                Spacer()
                HStack(spacing: 4) {
                    Spacer()


#if targetEnvironment(macCatalyst)

                    Button(action: {
                            DispatchQueue.main.async {
                                // Execute your action here

                                Backend.doBackend(path: "~/LogicSage/")
                                //appModel.isServerActive = true
                            }

                    }) {
                        VStack(spacing: 0)  {

                            resizableButtonImage(systemName:
                                                    "server.rack",
                                                 size: geometry.size)
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(settingsViewModel.appTextColor)

                            Text( "Start server" )
                            //  Text("\(appModel.isServerActive ? "Stop" : "Start") server" )
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)

                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(xrOS)

                        .background(settingsViewModel.buttonColor)
#endif
                    }
                    .buttonStyle(MyButtonStyle())

#endif

                    // Add new App window

#if os(macOS)
                    NewViewerButton()

                        .foregroundColor(settingsViewModel.appTextColor)
#else

                    if UIDevice.current.userInterfaceIdiom != .phone {
                        if #available(iOS 16.0, *) {
                            NewViewerButton(settingsViewModel: settingsViewModel)
                            //                        .buttonStyle(MyButtonStyle())
                            //                        .font(.body)
                            //                        .lineLimit(0)
                            //                        .minimumScaleFactor(0.1)
                            //                        .border(.secondary)
                                                    .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                                .hoverEffect(.automatic)
#endif
                                .cornerRadius(8)
                        }
                    }
#endif

                    Button(action: {
                        DispatchQueue.main.async {
                            // Execute your action here
                            screamer.sendCommand(command: "st")
                            isInputViewShown = false
                        }
                    }) {
                        VStack(spacing: 0)  {

                            resizableButtonImage(systemName:
                                                    "stop.circle.fill",
                                                 size: geometry.size)
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(settingsViewModel.appTextColor)

                            Text("Stop voice" )
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)

                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(xrOS)

                        .background(settingsViewModel.buttonColor)
#endif
                    }
                    .buttonStyle(MyButtonStyle())
#if !os(macOS)
                                .hoverEffect(.automatic)
#endif
                                .cornerRadius(8)

// NEW ASSISTANT BUTTON
                    Button(action: {
                        DispatchQueue.main.async {
                            settingsViewModel.latestWindowManager = windowManager

                            showDialog = true

                            playSelect()
                            isInputViewShown = false
                        }
                    }) {
                        VStack(spacing: 0)  {
                            resizableButtonImage(systemName:
                                                    "face.dashed.fill",
                                                 size: geometry.size)
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .font(.caption)

                            .foregroundColor(settingsViewModel.appTextColor)

                            Text("New Assistant" )
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.caption)
                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(xrOS)

                        .background(settingsViewModel.buttonColor)
#endif

                    }
                    .buttonStyle(MyButtonStyle())
#if !os(macOS)
                                .hoverEffect(.automatic)
#endif
                                .cornerRadius(8)


// NEW CHAT BUTTON

                    Button(action: {
                        DispatchQueue.main.async {
                            settingsViewModel.latestWindowManager = windowManager

                            settingsViewModel.createAndOpenNewConvo()

                            playSelect()
                            isInputViewShown = false
                        }
                    }) {
                        VStack(spacing: 0)  {
                            resizableButtonImage(systemName:
                                                    "text.bubble.fill",
                                                 size: geometry.size)
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .font(.caption)

                            .foregroundColor(settingsViewModel.appTextColor)

                            Text("New chat" )
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.caption)
                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(xrOS)

                        .background(settingsViewModel.buttonColor)
#endif

                    }
                    .buttonStyle(MyButtonStyle())
#if !os(macOS)
                                .hoverEffect(.automatic)
#endif
                                .cornerRadius(8)

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
    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
#if os(macOS) || os(tvOS)
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
        // .background(settingsViewModel.buttonColor)

#else
        return Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: max(30, size.width / 12), height: 32.666 )
            .tint(settingsViewModel.appTextColor)
#if targetEnvironment(macCatalyst)

            .background(settingsViewModel.buttonColor)
#endif
#endif
    }
}
struct CustomFontSize: ViewModifier {
    @Binding var size: Double

    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(size)))
    }
}
