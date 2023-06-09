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
    func openText() {
        isInputViewShown.toggle()
    }
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0)  {
                HStack {
#if os(xrOS)
                    if windowManager.windows.count == 1 {
                        ToggleImmersiveButton(idOfView: "ImmersiveSpaceVolume", name: "3D WindowSphere", showImmersiveLogo: $appModel.isShowingImmersiveWindow)
                    }
                    ToggleImmersiveButton(idOfView: "LogoVolume", name: "3D Logo", showImmersiveLogo: $appModel.isShowingImmersiveLogo)
                    //                    ToggleImmersion(showImmersiveSpace: $appModel.isShowingImmersiveScene)
#endif
                }
                Spacer()
                HStack(spacing: 4) {
                    Spacer()

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

#if !os(tvOS)
                    Button(action: {
                        withAnimation {
                            logD("open Webview")

                            windowManager.addWindow(windowType: .webView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
                        }
                    }) {
                        VStack(spacing: 0)  {
                            resizableButtonImage(systemName:
                                                    "network",
                                                 size: geometry.size)
                            .cornerRadius(8)
                            .foregroundColor(settingsViewModel.appTextColor)

                            Text("Webview" )
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)

                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(xrOS)
                        .background(settingsViewModel.buttonColor)
#endif

                    }
#endif

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
#else
        if #available(iOS 16.0, *) {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: max(30, size.width / 12), height: 32.666 )
                .tint(settingsViewModel.appTextColor)
            // .background(settingsViewModel.buttonColor)
        } else {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: max(30, size.width / 12), height: 32.666 )
            //.background(settingsViewModel.buttonColor)
        }
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
