//
//  Drawer.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI

struct DrawerContent: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var windowManager: WindowManager
    @Binding var conversations: [Conversation]
    @Binding var viewSize: CGRect
    @Binding var showSettings: Bool
    @Binding var showAddView: Bool
    
    @State var presentRenamer: Bool = false

    @State private var newName: String = ""
    @State var renamingConvo: Conversation? = nil
    @State var isDeleting: Bool = false
    @State var isDeletingIndex: Int = -1
    @Binding var tabSelection: Int

    @State private var showRenamed: Bool = false

    private func onRename() {
        withAnimation(Animation.easeInOut(duration: 0.666)) {
            showRenamed = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.666) {
            withAnimation(Animation.easeInOut(duration: 0.6666)) {
                showRenamed = false
            }
        }
    }

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
#if os(macOS) || os(tvOS) || os(visionOS)
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: max(44, size.width / 12), height: 32.666 )

#else
        Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: max(44, size.width / 12), height: 32.666 )
                .tint(settingsViewModel.appTextColor)
                .background(settingsViewModel.buttonColor)

#endif
    }
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 1) {
                VStack(alignment: .leading, spacing: 1) {
                    topButtons(size: geometry.size)
                        .padding(.top)
                        .padding(.trailing)
                        .padding(.leading)

                    ScrollView {
                        ForEach(Array(conversations.reversed().enumerated()), id: \.offset) { index, convo in

                            Divider()
                                .foregroundColor(settingsViewModel.appTextColor.opacity(0.5))

                            HStack(alignment: VerticalAlignment.lastTextBaseline, spacing: 4) {
                                Spacer()
                                Button( action : {
                                    withAnimation {
                                        tabSelection = 1
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            settingsViewModel.latestWindowManager = windowManager
                                            playSelect()
                                            settingsViewModel.openConversation(convo.id)
                                        }
                                    }
                                }) {
                                    ZStack {
                                        Text(nameForConvo(convo:convo))
                                            .multilineTextAlignment(.trailing)
                                            .lineLimit(4)
                                            .minimumScaleFactor(0.69)
                                            .padding(.leading, 2)
                                            .padding(.trailing, 20)
                                        
                                            .font(.body)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                                        
                                    }
                                    
                                    
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                                }
#if !os(macOS)
                                .hoverEffect(.automatic)
#endif

                                if isDeleting && isDeletingIndex > -1 && isDeletingIndex == index {
                                    Button( action : {
                                        withAnimation {
                                            isDeleting = false
                                            
                                            isDeletingIndex = -1
                                            settingsViewModel.latestWindowManager = windowManager
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                
                                                settingsViewModel.deleteConversation(convo.id)

                                                isDeleting = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                                                    isDeleting = false
                                                    isDeletingIndex = -1
                                                }
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
//                                        .padding(.trailing, 4)
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
//                                        .padding(.trailing, 7)
                                        .animation(.easeIn(duration: 0.25), value: isDeleting)
                                    }
                                    .buttonStyle(MyButtonStyle())
                                }
                                else {

                                    HStack(spacing: 5) {
                                        // Generate name for convo
                                        Button( action : {
                                            logD("Doing chat title generation...")

                                            settingsViewModel.genTitle(convo.id, force: true) { success in
                                                // successfull renamed with AI
                                                if success {
                                                    logD("successfully genn title")
                                                    isDeleting = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        onRename()

                                                        isDeleting = false
                                                        isDeletingIndex = -1
                                                    }

                                                }
                                                else {
                                                    logD("fail gen title")
                                                }
                                            }


                                        }) {
                                            resizableButtonImage(systemName:
                                                                    "pencil.and.outline",
                                                                 size: geometry.size)
#if !os(macOS)
                                            .hoverEffect(.lift)
#endif
                                            .lineLimit(1)
//                                            .padding(.trailing, 7)
                                            .animation(.easeIn(duration: 0.25), value: isDeleting)
                                        }
                                        .buttonStyle(MyButtonStyle())



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
//                                            .padding(.leading, 7)
//                                            .padding(.trailing, 7)
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
                            }
                
                            .padding(.horizontal)
                        }
                    }
                    .minimumScaleFactor(0.9666)
                    .foregroundColor(settingsViewModel.appTextColor)
                    .modify { view in
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
                                Text("Please enter new name for convo")
                            }
                            else {
                                Text("Please enter new name")
                            }
                        })
                    }
                }
            }
            .zIndex(9)
        }
#if !os(visionOS)

        .overlay(CheckmarkView(text: "Renamed", isVisible: $showRenamed))
#endif

    }
    func nameForConvo(convo: Conversation) -> String {
        if let assistantName = convo.assName {
            return "\(assistantName) :)"
        }
        else {
            return "\(convo.name ?? String(convo.id.prefix(4))) 💬"
        }

    }
    func topButtons(size: CGSize) -> some View {
        HStack(spacing: 0) {

            Button( action : {
                withAnimation {
                    tabSelection = 1
                }
            }) {
                resizableButtonImage(systemName:
                                        "xmark.circle.fill",
                                     size: size)
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
                VStack(spacing:0) {
                    resizableButtonImage(systemName:
                                            "text.and.command.macwindow",
                                         size: size)
                    Text("Term")
                        .font(.body)
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
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
                VStack(spacing:0) {
                    
                    resizableButtonImage(systemName:
                                            "gearshape",
                                         size: size)
                    Text("Settings")
                        .font(.body)
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
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
                VStack(spacing:0) {
                    resizableButtonImage(systemName:
                                            "plus.rectangle",
                                         size: size)
                    Text("Files/Git")
                        .font(.body)
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
                
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
                VStack(spacing:0) {
                    resizableButtonImage(systemName:
                                            "text.bubble.fill",
                                         size: size)
                    Text("New Chat")
                        .font(.body)
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
#if !os(macOS)
                .hoverEffect(.lift)
#endif
                .padding(.trailing, 4)
            }
            .buttonStyle(MyButtonStyle())
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
