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
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 4) {
                    
                    HStack(spacing: 4) {
                        Text("open menu:")
                            .font(.body)
                            .foregroundColor(settingsViewModel.buttonColor)

                            .padding(.bottom)

                        Text("for more scroll down 📜⬇️")
                            .font(.body)
                            .foregroundColor(settingsViewModel.buttonColor)

                            .padding(.bottom)
                    }
                    Button("new file") {
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
                    .border(settingsViewModel.buttonColor, width: 2)

                    .font(.title2)
                    .lineLimit(nil)
                    .fontWeight(.bold)

                    Button("new webview: \(settingsViewModel.defaultURL)") {
#if !os(macOS)

                        if consoleManager.isVisible {
                            consoleManager.isVisible = false
                        }
#endif

                        print("open Webview")
                        showAddView.toggle()

#if !os(macOS)
                        // let defSize = CGRect(x: 0, y: 0, width: geometry.size.width - geometry.size.width / 3, height: geometry.size.height - geometry.size.height / 3)

                        windowManager.addWindow(windowType: .webView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
#endif

                    }
                    .foregroundColor(settingsViewModel.buttonColor)

                    .font(.title2)
                    .lineLimit(nil)
                    .fontWeight(.bold)
                    .border(settingsViewModel.buttonColor, width: 2)

                    Text("Current repo = \("\(settingsViewModel.gitUser)/\(settingsViewModel.gitRepo)/\(settingsViewModel.gitBranch)")")
                    if !settingsViewModel.isLoading {
                        Button("dl repo") {

                            print("Downloading repo...")
                            settingsViewModel.syncGithubRepo()
                        }
                        .foregroundColor(settingsViewModel.buttonColor)
                        .font(.largeTitle)
                        .lineLimit(nil)
                        .fontWeight(.bold)
                        .border(settingsViewModel.buttonColor, width: 2)



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

                        //                            .foregroundColor(.white)
                        //                            .padding(.horizontal, 40)
                        //                            .padding(.vertical, 12)
                        //                            .background(settingsViewModel.buttonColor)
                        //                            .cornerRadius(8)
                    }

                    if !settingsViewModel.isLoading {
                        let val = settingsViewModel.loadDirectories().count
                        Text("Downloaded Repositories")
                            .font(.title3)
                            .lineLimit(nil)
                            .fontWeight(.bold)
                        
                        NavigationView {
                            RepositoriesListView(settingsViewModel: settingsViewModel)

                                .environmentObject(windowManager)
                            
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: geometry.size.height/listHeightFactor * Double(val), maxHeight: geometry.size.height/listHeightFactor * Double(val))
                        .navigationViewStyle(StackNavigationViewStyle())
                    }
                    if !settingsViewModel.isLoading {

                        Text("Open Repo Tree")
                            .font(.title3)
                            .lineLimit(nil)
                            .fontWeight(.bold)
                        NavigationView {
                            RepositoryTreeView(settingsViewModel: settingsViewModel, accessToken: "")

                                .environmentObject(windowManager)

                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: geometry.size.height/listHeightFactor * Double(settingsViewModel.rootFiles.count), maxHeight: geometry.size.height/listHeightFactor * Double(settingsViewModel.rootFiles.count))

                        .navigationViewStyle(StackNavigationViewStyle())
                        .navigationTitle("Repository Tree")
                    }
                    //                .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Text("Window List")
                        .font(.title3)
                        .lineLimit(nil)
                        .fontWeight(.bold)

                    NavigationView {
                        
                        WindowList(showAddView: $showAddView)

                            .environmentObject(windowManager)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: geometry.size.height/listHeightFactor * Double(windowManager.windows.count), maxHeight: geometry.size.height/listHeightFactor * Double(settingsViewModel.rootFiles.count))

                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationTitle("Window List:")
                }
                .padding(.bottom, geometry.size.height / 8)

#if !os(macOS)

                .background(settingsViewModel.backgroundColor)
#endif
                .cornerRadius(16)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)


                //            }
                //            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                //            .padding(geometry.size.width * 0.01)
                //            .padding(.bottom, 30)
                //#if !os(macOS)
                //
                //            .background(settingsViewModel.backgroundColor)
                //#endif
            }
        }
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}
