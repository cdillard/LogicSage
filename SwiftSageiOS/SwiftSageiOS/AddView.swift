//
//  SettingsVIew.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI

var windowIndex = 0
let listHeightFactor = 13.666

struct AddView: View {
    @Binding var showAddView: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var windowManager: WindowManager
    @State var currentRoot: GitHubContent?

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
            .tint(settingsViewModel.buttonColor)
            .background(CustomShape())
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("open menu:")
                            .font(.subheadline)
                            .foregroundColor(settingsViewModel.buttonColor)

                            .padding(.bottom)

                        Text("for more scroll down 📜⬇️")
                            .font(.subheadline)
                            .foregroundColor(settingsViewModel.buttonColor)

                            .padding(.bottom)
                    }
                    HStack(spacing: 4) {
                        Button(action: {
                            withAnimation {
                                logD("open new File")
#if !os(macOS)

                                if consoleManager.isVisible {
                                    consoleManager.isVisible = false
                                }
#endif
                                showAddView.toggle()
#if !os(macOS)
                                //let defSize = CGRect(x: 0, y: 0, width: geometry.size.width - geometry.size.width / 3, height: geometry.size.height - geometry.size.height / 3)
                                windowManager.addWindow(windowType: .file, frame: defSize, zIndex: 0)
#endif
                            }
                        }) {
                            VStack {
                                Text("New File...")
                                    .font(.subheadline)
                                    .foregroundColor(settingsViewModel.buttonColor)
                                    .padding(.bottom)

                                resizableButtonImage(systemName:
                                                        "doc.fill.badge.plus",
                                                     size: geometry.size)
                                .fontWeight(.bold)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(8)
                            }

                        }
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom)
                    }
                    .frame(width: geometry.size.width  - (geometry.size.width * 0.3))

                    HStack(spacing: 4) {
                        Button(action: {
                            withAnimation {

#if !os(macOS)
                                if consoleManager.isVisible {
                                    consoleManager.isVisible = false
                                }
#endif
                                logD("open Webview")
                                showAddView.toggle()

#if !os(macOS)
                                // let defSize = CGRect(x: 0, y: 0, width: geometry.size.width - geometry.size.width / 3, height: geometry.size.height - geometry.size.height / 3)

                                windowManager.addWindow(windowType: .webView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
#endif
                            }
                        }) {
                            VStack {
                                Text("New webview: " + settingsViewModel.defaultURL)
                                    .font(.subheadline)
                                    .foregroundColor(settingsViewModel.buttonColor)
                                    .padding(.bottom)
                                resizableButtonImage(systemName:
                                                        "rectangle.center.inset.filled.badge.plus",
                                                     size: geometry.size)
                                .fontWeight(.bold)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(8)
                            }

                        }
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom)
                    }
                    .frame(width: geometry.size.width  - (geometry.size.width * 0.3))

                    if !settingsViewModel.isLoading {
                        HStack(spacing: 4) {
                            Button(action: {
                                logD("Downloading repo...")
                                settingsViewModel.syncGithubRepo()
                            }) {
                                VStack {
                                    Text("download: \(settingsViewModel.currentGitRepoKey().replacingOccurrences(of: SettingsViewModel.gitKeySeparator, with: "/"))")
                                        .font(.subheadline)
                                        .foregroundColor(settingsViewModel.buttonColor)
                                    resizableButtonImage(systemName:
                                                            "arrow.down.doc",
                                                         size: geometry.size)
                                    .fontWeight(.bold)
                                    .background(settingsViewModel.buttonColor)
                                    .cornerRadius(8)
                                }
                            }
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.bottom)
                        }
                        .frame(width: geometry.size.width  - (geometry.size.width * 0.3))
                    }
                    else {
                        ProgressView()
                    }
                    // SHOW ADD VIEW BUTTON
                    Button(action: {
                        withAnimation {
                            showAddView.toggle()
                        }
                    }) {
                        Text("close")
                            .foregroundColor(settingsViewModel.buttonColor)
                            .font(.title2)
                            .lineLimit(nil)
                            .fontWeight(.bold)
                            .border(settingsViewModel.buttonColor, width: 2)
                    }

                    if !settingsViewModel.isLoading {
                        let val = max(3, min(15,settingsViewModel.loadDirectories().count))
                        Text("Downloaded Repositories")
                            .font(.title3)
                            .lineLimit(nil)
                            .fontWeight(.bold)
                        
                        NavigationView {
                            RepositoriesListView(settingsViewModel: settingsViewModel)
                                .environmentObject(windowManager)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: geometry.size.height/listHeightFactor * Double(val), maxHeight: geometry.size.height/listHeightFactor * Double(val))
#if !os(macOS)

                        .navigationViewStyle(StackNavigationViewStyle())
#endif
                    }
                    if !settingsViewModel.isLoading {

                        Text("Open Repo Tree")
                            .font(.title3)
                            .lineLimit(nil)
                            .fontWeight(.bold)
                        let rootFileCount = max(3, min(15,settingsViewModel.rootFiles.count))
                        NavigationView {
                            RepositoryTreeView(settingsViewModel: settingsViewModel, accessToken: "")
                                .environmentObject(windowManager)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: geometry.size.height/listHeightFactor * Double(rootFileCount), maxHeight: geometry.size.height/listHeightFactor * Double(rootFileCount))
#if !os(macOS)

                        .navigationViewStyle(StackNavigationViewStyle())
#endif
                        .navigationTitle("Repository Tree")
                    }
                    Text("Window List")
                        .font(.title3)
                        .lineLimit(nil)
                        .fontWeight(.bold)
                    let windowCount = max(3, min(15,windowManager.windows.count))
                    NavigationView {
                        WindowList(showAddView: $showAddView)
                            .environmentObject(windowManager)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: geometry.size.height/listHeightFactor * Double(windowCount), maxHeight: geometry.size.height/listHeightFactor * Double(windowCount))
#if !os(macOS)
                    .navigationViewStyle(StackNavigationViewStyle())
#endif
                    .navigationTitle("Window List:")
                }
                .padding(.bottom, geometry.size.height / 8)
#if !os(macOS)

                .background(settingsViewModel.backgroundColor)
#endif
                .cornerRadius(16)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
    }
}
