//
//  GlobeControls.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/17/23.
//
#if os(visionOS)

import SwiftUI

struct GlobeControls: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var appModel: AppModel
    @ObservedObject private var eventManager = GlobalEventManager.shared

    @State private var entryText: String = "" // State variable for TextEditor content

    @FocusState var inFocus
    @State var focused: Bool = false

    var body: some View {
        VStack {
            HStack(spacing: 17) {
                Toggle(isOn:$appModel.isTranslating) {
                    Label("Translate", systemImage: "move.3d")
                }

                .onChange(of: appModel.isTranslating) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                        eventManager.frameUpdate = true
                    }
                }

                Toggle(isOn: $appModel.isRotating) {
                    Label("Rotate", systemImage: "arrow.triangle.2.circlepath")
                }
                .onChange(of: appModel.isRotating) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                        eventManager.frameUpdate = true
                    }
                }

                HStack(spacing: 17) {

                    if #available(iOS 16.0, *) {
                        NewViewerButton(settingsViewModel: settingsViewModel)
                            .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                            .hoverEffect(.automatic)
#endif
                            .padding(8)
                    }

                    // Add button to reOpen Main Window

                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .labelStyle(.iconOnly)
                .glassBackgroundEffect(in: .rect(cornerRadius: 50))
            }
            .toggleStyle(.button)
            .buttonStyle(.borderless)
            .labelStyle(.iconOnly)
            .glassBackgroundEffect(in: .rect(cornerRadius: 50))
            HStack {
                ZStack (alignment: .topLeading) {
                    TextEditor(text: $entryText)
                        .padding()
                        .frame(height: 100) // Customize the size as needed
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .focused($inFocus)
                        .onChange(of: inFocus) {
                            focused = inFocus
                        }

                    if entryText.isEmpty {
                        Text("Send a message...")
                            .padding(24)
                            .opacity(entryText.isEmpty && !inFocus ? 1.0 : 0.0 )
                    }
                }


                Button(action: {
                    guard !entryText.isEmpty else { return }

                    if SettingsViewModel.shared.projectedConvoId == "-1" {
                        screamer.sendCommand(command: entryText)
                    }
                    else {

                        SettingsViewModel.shared.sendChatText(SettingsViewModel.shared.projectedConvoId ?? "", chatText: entryText)
                    }

                    entryText = ""
                    hideKeyboard()


                }) {
                    resizableButtonImage(systemName:
                                            "paperplane.fill",
                                         size: CGSizeMake(49, 49))
                    .background(Color.clear)

                }
                .padding(.trailing, 8)
            }
            .glassBackgroundEffect(in: .rect(cornerRadius: 50))


        }
        .frame(height: 60)
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
        //.tint(settingsViewModel.appTextColor)
#if targetEnvironment(macCatalyst)

        // .background(settingsViewModel.buttonColor)
#endif
#endif
    }
}

extension HorizontalAlignment {
    /// A custom alignment to center the control panel under the globe.
    private struct ControlPanelAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }

    /// A custom alignment guide to center the control panel under the globe.
    static let controlPanelGuide = HorizontalAlignment(
        ControlPanelAlignment.self
    )
}
#endif
