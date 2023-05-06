//
//  SettingsVIew.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI

let defSize = CGRect(x: 0, y: 0, width: 200, height: 200)
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
                        
                        windowManager.addWindow(windowType: .file, frame: defSize, zIndex: 0)
                    }
                    .font(.footnote)
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


                        windowManager.addWindow(windowType: .webView, frame: defSize, zIndex: 0)

                    }
                    .font(.footnote)
                    .lineLimit(nil)
                    .fontWeight(.bold)
                    .padding(.bottom)

                    Button("Download sws repo") {

                        print("Downloading sws repo...")
                        settingsViewModel.syncGithubRepo()
                    }
                    .font(.caption)
                    .lineLimit(nil)
                    .fontWeight(.bold)
                    .padding(.bottom)

                    // SHOW ADD VIEW BUTTON
                    Button(action: {
                        withAnimation {
                            showAddView.toggle()
                        }
                    }) {
                        Text("Close")
                            .font(.footnote)
                            .lineLimit(nil)
                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 40)
//                            .padding(.vertical, 12)
                            .background(settingsViewModel.buttonColor)
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


                NavigationView {
                    RepositoryTreeView(accessToken: "")
                        .environmentObject(windowManager)

                }
                .navigationTitle("Repository Tree")

            }
            .scrollIndicators(.visible)
        }
    }
}
