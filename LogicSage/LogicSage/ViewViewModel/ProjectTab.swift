//
//  Drawer.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI

struct ProjectTab: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var windowManager: WindowManager
    @Binding var projects: [Project]
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
#if os(macOS) || os(tvOS) || os(xrOS)
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
                    
                    ScrollView {
                        ForEach(Array(projects.reversed().enumerated()), id: \.offset) { index, project in
                            
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
                                            //                                            settingsViewModel.openConversation(project.id)
                                        }
                                    }
                                }) {
                                    ZStack {
                                        Text("\(project.name)")
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
                            }
                            
                        }
                        
                        .padding(.horizontal)
                    }
                }
                .minimumScaleFactor(0.9666)
                .foregroundColor(settingsViewModel.appTextColor)
                
            }
            .zIndex(9)
        }
        .overlay(CheckmarkView(text: "Renamed", isVisible: $showRenamed))
        
    }
}
