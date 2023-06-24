//
//  Drawer.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI

struct DrawerContent: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var windowManager: WindowManager

    @Binding var conversations: [Conversation]
    @Binding var isPortrait: Bool
    @Binding var viewSize: CGRect
    @Binding var showSettings: Bool
    @Binding var showAddView: Bool

    @State var presentRenamer: Bool = false {
        didSet {
            if #available(iOS 16.0, *) {
            }
            else {
#if !os(macOS)
                if presentRenamer {
                    LogicSage.alert(subject: "convo", convoId: renamingConvo?.id)
                }
#endif
            }
        }
    }
    @State private var newName: String = ""
    @State var renamingConvo: Conversation? = nil

    @State var isDeleting: Bool = false
    @State var isDeletingIndex: Int = -1

    @Binding var tabSelection: Int

    func rowString(convo: Conversation) -> String {
        convo.name ?? String(convo.id.prefix(4))
    }
    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        if #available(iOS 16.0, *) {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: max(30, size.width / 12), height: 32.666 )
                .tint(settingsViewModel.appTextColor)
                .background(settingsViewModel.buttonColor)
        } else {
            // Fallback on earlier versions
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: max(30, size.width / 12), height: 32.666 )
                .background(settingsViewModel.buttonColor)
        }
    }
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 1) {
                VStack(alignment: .leading, spacing: 1) {
                    ScrollView {
                        HStack(spacing: 0) {

                            Button( action : {
                                withAnimation {
                                    tabSelection = 1

                                    //        settingsViewModel.latestWindowManager = windowManager
                                    //
                                    //                                    settingsViewModel.createAndOpenServerChat()
                                }
                            }) {
                                resizableButtonImage(systemName:
                                                        "xmark.circle.fill",
                                                     size: geometry.size)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                                .padding(.leading, 8)
                                .padding(.trailing, 8)
                            }

                            .buttonStyle(MyButtonStyle())

                            Button( action : {
                                withAnimation {
                                    tabSelection = 1

                                    settingsViewModel.latestWindowManager = windowManager

                                    settingsViewModel.createAndOpenServerChat()
                                }
                            }) {
                                resizableButtonImage(systemName:
                                                        "text.and.command.macwindow",
                                                     size: geometry.size)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                                .padding(.leading, 8)
                                .padding(.trailing, 8)
                            }

                            .buttonStyle(MyButtonStyle())


                            Button( action : {
                                withAnimation {
                                    tabSelection = 2
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            showSettings = true
                                        }
                                    }
                                }
                            }) {
                                resizableButtonImage(systemName:
                                                        "gearshape",
                                                     size: geometry.size)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                                .padding(.leading, 8)
                                .padding(.trailing, 8)
                            }
                            .buttonStyle(MyButtonStyle())


                            Button( action : {
                                withAnimation {
                                    tabSelection = 3
                                    if showSettings {
                                        showSettings = false
                                    }

                                    DispatchQueue.main.async {
                                        withAnimation {
                                            showAddView = true
                                        }
                                    }
                                }
                            }) {
                                resizableButtonImage(systemName:
                                                        "plus.rectangle",
                                                     size: geometry.size)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                                .padding(.leading, 8)
                                .padding(.trailing, 8)
                            }
                            .buttonStyle(MyButtonStyle())

                            Spacer()
                            Button( action : {

                                withAnimation {
                                    tabSelection = 1

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        settingsViewModel.latestWindowManager = windowManager

                                        settingsViewModel.createAndOpenNewConvo()

                                        playSelect()
                                    }
                                }
                            }) {
                                resizableButtonImage(systemName:
                                                        "text.bubble.fill",
                                                     size: geometry.size)
#if !os(macOS)
                                .hoverEffect(.lift)
#endif
                                .padding(.trailing, 4)
                            }
                            .buttonStyle(MyButtonStyle())

                        }
                        .padding(.top)
                        .padding(.trailing)
                        .padding(.leading)
                        ForEach(Array(conversations.reversed().enumerated()), id: \.offset) { index, convo in

                            Divider().foregroundColor(settingsViewModel.appTextColor.opacity(0.5))

                            HStack(spacing: 0) {
                                ZStack {
                                    Text("💬 \(rowString(convo: convo))")
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(4)
                                        .minimumScaleFactor(0.69)
                                        .padding(.leading, 2)
                                        .font(.body)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                                }

                                .onTapGesture {
                                    withAnimation {
                                        tabSelection = 1

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            settingsViewModel.latestWindowManager = windowManager
                                            playSelect()
                                            settingsViewModel.openConversation(convo.id)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)

#if !os(macOS)
                                .hoverEffect(.lift)
#endif

                                Spacer()

                                if isDeleting && isDeletingIndex > -1 && isDeletingIndex == index {
                                    Button( action : {
                                        withAnimation {
                                            isDeleting = false

                                            isDeletingIndex = -1
                                            settingsViewModel.latestWindowManager = windowManager

                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                                                settingsViewModel.deleteConversation(convo.id)
                                            }
                                        }
                                    }) {
                                        resizableButtonImage(systemName:
                                                                "checkmark.circle.fill",
                                                             size: geometry.size)
#if !os(macOS)
                                        .hoverEffect(.lift)
#endif
                                        .lineLimit(1)
                                        .padding(.trailing, 4)
                                        .animation(.easeIn(duration: 0.25), value: isDeleting)
                                    }
                                    .buttonStyle(MyButtonStyle())

                                    Button( action : {
                                        isDeleting = false
                                        isDeletingIndex = -1
                                    }) {
                                        resizableButtonImage(systemName:
                                                                "x.circle.fill",
                                                             size: geometry.size)
#if !os(macOS)
                                        .hoverEffect(.lift)
#endif
                                        .lineLimit(1)
                                        .padding(.trailing, 7)
                                        .animation(.easeIn(duration: 0.25), value: isDeleting)
                                    }
                                    .buttonStyle(MyButtonStyle())

                                }
                                else {
                                    Button( action : {
                                        renamingConvo = convo

                                        presentRenamer = true

                                    }) {
                                        resizableButtonImage(systemName:
                                                                "rectangle.and.pencil.and.ellipsis",
                                                             size: geometry.size)
#if !os(macOS)
                                        .hoverEffect(.lift)
#endif
                                        .lineLimit(1)
                                        .padding(.trailing, 7)
                                        .animation(.easeIn(duration: 0.25), value: isDeleting)
                                    }
                                    .buttonStyle(MyButtonStyle())

                                    Button( action : {
                                        isDeleting = true
                                        isDeletingIndex = index
                                    }) {
                                        resizableButtonImage(systemName:
                                                                "trash.circle.fill",
                                                             size: geometry.size)
#if !os(macOS)
                                        .hoverEffect(.lift)
#endif
                                        .lineLimit(1)
                                        .animation(.easeIn(duration: 0.25), value: isDeleting)
                                    }
                                    .buttonStyle(MyButtonStyle())

                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .minimumScaleFactor(0.9666)
                    .foregroundColor(settingsViewModel.appTextColor)
                    .modify { view in
                        if #available(iOS 15.0, *) {

                            view.alert("Rename convo", isPresented: $presentRenamer, actions: {
                                TextField("New name", text: $newName)

                                Button("Rename", action: {
                                    settingsViewModel.latestWindowManager = windowManager

                                    presentRenamer = false
                                    if let convoID = renamingConvo?.id {
                                        settingsViewModel.renameConvo(convoID, newName: newName)
                                        renamingConvo = nil

                                    }
                                    else {
                                        logD("no rn")
                                    }

                                    renamingConvo = nil
                                    newName = ""

                                })
                                Button("Cancel", role: .cancel, action: {
                                    renamingConvo = nil
                                    presentRenamer = false
                                    newName = ""
                                })
                            }, message: {
                                if let renamingConvo {
                                    Text("Please enter new name for convo \(rowString(convo:renamingConvo))")
                                }
                                else {
                                    Text("Please enter new name")
                                }
                            })
                        }
                    }
                }
            }
            .zIndex(9)
        }
    }
}
struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
