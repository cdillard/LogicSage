//
//  SettingsVIew.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI
#if !os(macOS)
import UIKit
#endif

struct SettingsView: View {

    let fontSizeSrcEditorRange: ClosedRange<Double> = 2...64
    let fontSizeSrceditorSteps: Double = 0.5

    let buttonScaleRange: ClosedRange<Double> = 0.2...0.45
    let buttonScaleSteps: Double = 0.05

    let commandButtonRange: ClosedRange<Double> = 10...64
    let commandButtonSteps: Double = 1

    let cornerHandleRange: ClosedRange<Double> = 28...80
    let cornerHandleSteps: Double = 1

    @Binding var showSettings: Bool
    @Binding var showHelp: Bool
    @Binding var showInstructions: Bool

    @ObservedObject var settingsViewModel: SettingsViewModel

    @State var scrollViewID = UUID()

    @State var presentRenamer: Bool = false
    @State var newName: String = ""
    @State var renamingConvo: Conversation? = nil

    @State var apiSettingsTitleLabelString: String = "▶️ API settings"
    @State var sizesSettingsTitleLabelString: String = "▶️ Size settings"
    @State var colorSettingsTitleLabelString: String = "▶️ Color settings"
    @State var moreColorSettingsTitleLabelString: String = "▶️ Code/Chat color settings"
    @State var audioSettingsTitleLabelString: String = "▶️ Audio settings"

    @State var apiSettingsExpanded = false
    @State var sizeSettingsExpanded = false
    @State var colorSettingsExpanded = false
    @State var moreColorSettingsExpanded = false

    @State var presentUserAvatarRenamer: Bool = false
    @State var presentGptAvatarRenamer: Bool = false

    @State var newUsersName: String = SettingsViewModel.shared.savedUserAvatar
    @State var newGPTName: String = SettingsViewModel.shared.savedBotAvatar
    @Binding var tabSelection: Int

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Group {
                        Group {
                            HStack(spacing: 4) {
                                HStack {
                                    Button(action: {
                                        withAnimation {
                                            scrollViewID = UUID()
                                            tabSelection = 1
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.body)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
#if !os(macOS)
                                            .hoverEffect(.lift)
#endif
                                    }
                                }
                                
                                Text("Settings:")
                                    .font(.title)
                                    .foregroundColor(settingsViewModel.appTextColor)
                            }
                            .padding(.top, 30)
                            .padding(.leading,8)
                            .padding(.trailing,8)
                        }
                        
                        VStack {
                            HStack {
                                infoAndHelpButtons(size: geometry.size)
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            
                            Spacer()
                        }
                        miscButtons(size: geometry.size)

                        colorDisc(size: geometry.size)
                            .font(.title3)
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                            .accentColor(settingsViewModel.buttonColor)
                            .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                                            .hoverEffect(.lift)
#endif
                        nameChangeStack()
                        
                        apiDisc()
                            .font(.title3)
#if !os(macOS)
                                            .hoverEffect(.lift)
#endif

                            sizeSlidersDisc()
                                .font(.title3)
#if !os(macOS)
                                            .hoverEffect(.lift)
#endif
                    }

                    Button(action: {
                        withAnimation {
                            scrollViewID = UUID()
                            showSettings.toggle()
                            tabSelection = 1
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(8)
#if !os(macOS)
                                            .hoverEffect(.lift)
#endif
                    }
                    .padding(.bottom)
                    
                    .alert("Rename self", isPresented: $presentUserAvatarRenamer, actions: {
                        TextField("New name", text: $newUsersName)
                        
                        Button("Rename", action: {
                            settingsViewModel.savedUserAvatar = newUsersName
                            
                        })
                        Button("Cancel", role: .cancel, action: {
                            presentGptAvatarRenamer = false
                        })
                    }, message: {
                        Text("Please enter new name for yourself")
                    })
                    
                    .alert("Rename gpt", isPresented: $presentGptAvatarRenamer, actions: {
                        TextField("New name", text: $newGPTName)
                        
                        Button("Rename", action: {
                            settingsViewModel.savedBotAvatar = newGPTName
                            
                        })
                        Button("Cancel", role: .cancel, action: {
                            presentGptAvatarRenamer = false
                        })
                    }, message: {
                        Text("Please enter new name for gpt")
                    })

                    Spacer()
                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
                .padding(geometry.size.width * 0.01)
                .padding(.bottom, 30)
#if !os(macOS)
                .background(settingsViewModel.backgroundColor)
#endif
            }
            .background(settingsViewModel.backgroundColor
                .edgesIgnoringSafeArea(.all))

            .onAppear {
#if !os(macOS)
                UIScrollView.appearance().bounces = false
#endif
            }
            .scrollIndicators(.visible)

            .id(self.scrollViewID)
        }
    }

    func modelOptions() -> some View {
        Group {
            ForEach(aiModelOptions, id: \.self) { line in
                Button(action: {
                    logD("CHOOSE model from settings: \(line)")
                    settingsViewModel.openAIModel = line
                }) {
                    Text(line)
                        .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                        .lineLimit(1)
                        .foregroundColor(Color.white)
                        .background(settingsViewModel.buttonColor)
                }
            }
        }
    }

    func hostOptions() -> some View {
        Group {
            let hosts = ["api.openai.com"] // , "localhost:4891"]
            ForEach(hosts, id: \.self) { line in
                Button(action: {
                    logD("CHOOSE HOST from settings: \(line)")
                    settingsViewModel.openAIHost = line
                }) {
                    Text(line)
                        .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                        .lineLimit(1)
                        .foregroundColor(Color.white)
                        .background(settingsViewModel.buttonColor)
                }
            }
        }
    }

    struct DemoStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .center) {
                configuration.icon
                configuration.title
            }
        }
    }


    func nameChangeStack() -> some View {
        HStack {
            Group {
                Button(action: {
                    withAnimation {
                        logD("change your name")
                        presentUserAvatarRenamer = true
                    }
                }) {
                    VStack {
                        Text("Avatar")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .font(.body)

                        Text("\(settingsViewModel.savedUserAvatar)")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(8)
                    }
                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom)

                Button(action: {
                    withAnimation {
                        logD("change gpt name")
                        presentGptAvatarRenamer = true
                    }
                }) {
                    VStack {
                        Text("Gpt")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .font(.body)

                        Text("\(settingsViewModel.savedBotAvatar)")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(8)
                    }
                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom)
            }
        }
    }
    func infoAndHelpButtons(size: CGSize) -> some View {
        Group {
            VStack {
                Button(action: {
                    withAnimation {
                        showSettings.toggle()
                        showInstructions.toggle()
                        logD("info tapped")
                    }
                }) {
                    resizableButtonImage(systemName:
                                            "info",
                                         size: size)
                    .background(settingsViewModel.buttonColor)
                    .cornerRadius(8)
#if !os(macOS)
                    .hoverEffect(.lift)
#endif
                }
                // BUTTON FOR (i) info
                Text("info")
                    .foregroundColor(settingsViewModel.appTextColor)
            }
        }
    }
    func apiDisc() -> some View {
#if os(tvOS)
        VStack { }
#else

        // START OF API SETTINGS DISCLOSURE GROUP
        DisclosureGroup( isExpanded: $apiSettingsExpanded) {
            Group {
                VStack {
                    Text("A.I. 🔑: ")
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
                    TextField(
                        "",
                        text: $settingsViewModel.openAIKey
                    )
                    .minimumScaleFactor(0.866)
                    .border(.secondary)
                    .lineLimit(3)

                    .submitLabel(.done)
                    .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(visionOS)
                    .scrollDismissesKeyboard(.interactively)
#endif
                    .font(.title3)
                    .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                    .autocorrectionDisabled(!true)
#endif
#if !os(macOS)
                    .autocapitalization(.none)
#endif

                    Group {
                        Text("A.I. model: ")
                            .font(.title3)
                            .foregroundColor(settingsViewModel.appTextColor)

                        HStack {
                            TextField(
                                "",
                                text: $settingsViewModel.openAIModel
                            )
                            .border(.secondary)
                            .submitLabel(.done)
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
    #if !os(visionOS)
                            .scrollDismissesKeyboard(.interactively)
    #endif
                            .font(.title3)
                            .foregroundColor(settingsViewModel.appTextColor)
    #if !os(macOS)

                            .autocorrectionDisabled(!true)
    #endif
    #if !os(macOS)
                            .autocapitalization(.none)
    #endif
                            Menu {
                                modelOptions()
                            }
                        label: {
                            ZStack {

                                Label("...", systemImage: "arrow.down")
                                    .font(.title3)
                                    .minimumScaleFactor(0.5)
                                    .labelStyle(DemoStyle())
                                    .background(Color.clear)
                                    .tint(settingsViewModel.appTextColor)

                            }
                            .padding(4)
                        }
                        .frame(width: 30)

                        }


                        Text("Github PAT: ")
                            .font(.title3)
                            .foregroundColor(settingsViewModel.appTextColor)

                        TextField(
                            "",
                            text: $settingsViewModel.ghaPat
                        )
                        .border(.secondary)
                        .submitLabel(.done)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                        .autocorrectionDisabled(!true)
#endif
#if !os(macOS)
                        .autocapitalization(.none)
#endif

                        Text("Google Search API Key: ")
                            .font(.title3)
                            .foregroundColor(settingsViewModel.appTextColor)

                        TextField(
                            "",
                            text: $settingsViewModel.googleKey
                        )
                        .border(.secondary)
                        .submitLabel(.done)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                        .autocorrectionDisabled(!true)
#endif
#if !os(macOS)
                        .autocapitalization(.none)
#endif

                        Text("Google Search ID: ")
                            .font(.title3)
                            .foregroundColor(settingsViewModel.appTextColor)

                        TextField(
                            "",
                            text: $settingsViewModel.googleSearchId
                        )
                        .border(.secondary)
                        .submitLabel(.done)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                        .autocorrectionDisabled(!true)
#endif
#if !os(macOS)
                        .autocapitalization(.none)
#endif
                    }
                    //                    Group {
                    //                        Spacer()
                    //                            .padding(.leading, 8)
                    //                            .padding(.trailing, 8)
                    //
                    //                        Text("AI Host:")
                    //                            .font(.title3)
                    //                            .foregroundColor(settingsViewModel.appTextColor)
                    //
                    //                        HStack {
                    //                                TextField(
                    //                                    "",
                    //                                    text: $settingsViewModel.openAIHost
                    //                                )
                    //                                .border(.secondary)
                    //                                .submitLabel(.done)
                    //                                .frame( maxWidth: .infinity, maxHeight: .infinity)
                    //                                .font(.title3)
                    //                                .foregroundColor(settingsViewModel.appTextColor)
                    //#if !os(macOS)
                    //                                .autocorrectionDisabled(!true)
                    //#endif
                    //#if !os(macOS)
                    //                                .autocapitalization(.none)
                    //#endif
                    //
                    //                            Menu {
                    //                                hostOptions()
                    //                            }
                    //                        label: {
                    //                            ZStack {
                    //
                    //                                    Label("", systemImage: "arrow.down")
                    //                                        .font(.title3)
                    //                                        .minimumScaleFactor(0.5)
                    //                                        .labelStyle(DemoStyle())
                    //                                        .background(Color.clear)
                    //                                        .tint(settingsViewModel.appTextColor)
                    //
                    //
                    //
                    //                            }
                    //                            .padding(4)
                    //                        }
                    //                        }
                    //                    }

                }
                .padding(.top,30)
                .padding(.leading, 8)
                .padding(.trailing, 8)
            }
        } label: {
            Text(apiSettingsTitleLabelString)
                .onTapGesture {
                    withAnimation {
                        apiSettingsExpanded.toggle()
                    }
                }
        }
        .onChange(of: apiSettingsExpanded) { isExpanded in
            apiSettingsTitleLabelString  = "\(isExpanded ? "🔽" : "▶️") API settings"

            playSelect()
        }
        .padding(.leading, 8)
        .padding(.trailing, 8)
        .accentColor(settingsViewModel.buttonColor)
        .foregroundColor(settingsViewModel.appTextColor)

        // END OF API SETTINGS DISCLOSURE GROUP
#endif
    }




    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
#if os(macOS) || os(tvOS) || os(visionOS)
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
#else
        if #available(iOS 16.0, *) {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
                .tint(settingsViewModel.buttonColor)
#if !os(macOS)
                .background(settingsViewModel.backgroundColor)
#endif

        } else {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
#if !os(macOS)
                .background(settingsViewModel.backgroundColor)
#endif
        }
#endif
    }

    func miscButtons(size: CGSize) -> some View {
        Group {
#if !os(macOS)
            if UIDevice.current.userInterfaceIdiom == .phone {

                Group {
                    VStack {

                        Toggle(isOn: $settingsViewModel.hapticsEnabled) {
                            Text("Haptic Feedback📳:")
                                .font(.caption)
                                .foregroundColor(settingsViewModel.appTextColor)
                        }
                        .frame( maxWidth: size.width / 3)

                        Text("feedback won't play when low battery (< 0.30)")
                            .font(.caption)
                            .foregroundColor(settingsViewModel.appTextColor)
                    }
                }
            }
#endif
        }
    }
}


public extension View {
    @ViewBuilder
    func modify<Content: View>(@ViewBuilder _ transform: (Self) -> Content?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }

}
