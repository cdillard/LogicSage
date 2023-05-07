//
//  SettingsVIew.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI


var windowIndex = 0
struct AddView: View {
    @Binding var showAddView: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var windowManager: WindowManager
    var body: some View {
        GeometryReader { geometry in
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Button("New File") {
                        print("open new File")
#if !os(macOS)
                        
                        if consoleManager.isVisible {
                            consoleManager.isVisible = false
                        }
#endif
                        // For all windowzzz...
                        
                        showAddView.toggle()
#if !os(macOS)
                        //let defSize = CGRect(x: 0, y: 0, width: geometry.size.width - geometry.size.width / 3, height: geometry.size.height - geometry.size.height / 3)
                        windowManager.addWindow(windowType: .file, frame: defSize, zIndex: 0)
                        #endif
                    }
                    .foregroundColor(settingsViewModel.buttonColor)

                    .font(.body)
                    .lineLimit(nil)
                    .fontWeight(.bold)
                    .padding(.bottom)

                    Button("New WebView") {
#if !os(macOS)

                        if consoleManager.isVisible {
                            consoleManager.isVisible = false
                        }
#endif

                        print("open Webview")
                        showAddView.toggle()

#if !os(macOS)
                       // let defSize = CGRect(x: 0, y: 0, width: geometry.size.width - geometry.size.width / 3, height: geometry.size.height - geometry.size.height / 3)

                        windowManager.addWindow(windowType: .webView, frame: defSize, zIndex: 0)
#endif

                    }
                    .foregroundColor(settingsViewModel.buttonColor)

                    .font(.body)
                    .lineLimit(nil)
                    .fontWeight(.bold)
                    .padding(.bottom)
                    HStack {
                        Button("|Download Repo|") {

                            print("Downloading repo...")
                            settingsViewModel.syncGithubRepo()
                        }
                        .foregroundColor(settingsViewModel.buttonColor)
                        .font(.body)
                        .lineLimit(nil)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        Button("|View DLed Repos|") {
                            showAddView.toggle()

                            print("View the DLed Repos...")
                        }
                        .foregroundColor(settingsViewModel.buttonColor)
                        .font(.body)
                        .lineLimit(nil)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    }
//                    HStack {
//                        Button("|Window List|") {
//                            showAddView.toggle()
//
//                            print("Showing window list...")
//                        }
//                        .foregroundColor(settingsViewModel.buttonColor)
//                        .font(.body)
//                        .lineLimit(nil)
//                        .fontWeight(.bold)
//                        .padding(.bottom)
//
//                    }

                    // SHOW ADD VIEW BUTTON
                    Button(action: {
                        withAnimation {
                            showAddView.toggle()
                        }
                    }) {
                        Text("Close")
                            .foregroundColor(settingsViewModel.buttonColor)

                            .font(.body)
                            .lineLimit(nil)
                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 40)
//                            .padding(.vertical, 12)
//                            .background(settingsViewModel.buttonColor)
//                            .cornerRadius(8)
                    }
                    .padding(.bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                .padding(geometry.size.width * 0.01)
#if !os(macOS)
                
                .background(settingsViewModel.backgroundColor)
#endif
                .cornerRadius(16)

                VStack {
                    NavigationView {
                        RepositoryTreeView(settingsViewModel: settingsViewModel, accessToken: "")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                            .environmentObject(windowManager)
                        
                    }
                    .navigationTitle("Repository Tree")
                    //                .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Text("Window List")
                        .font(.body)
                        .lineLimit(nil)
                        .fontWeight(.bold)

                    NavigationView {
                        
                        WindowList()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .environmentObject(windowManager)
                    }
                    .navigationTitle("Window List:")
                }



            }
            .scrollIndicators(.visible)
        }
    }
}
