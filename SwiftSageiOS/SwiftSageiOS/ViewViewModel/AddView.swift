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


    @State var repoListOpen: Bool = false
    @State var fileListOpen: Bool = false
    @State var windowListOpen: Bool = false

    @FocusState private var field4IsFocused: Bool

    @FocusState private var field5IsFocused: Bool
    @FocusState private var field6IsFocused: Bool
    @FocusState private var field7IsFocused: Bool
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
                VStack {
                    HStack {
                        // SHOW ADD VIEW BUTTON
                        Button(action: {
                            withAnimation {
                                showAddView.toggle()

                                field4IsFocused = false
                                field5IsFocused = false
                                field6IsFocused = false
                                field7IsFocused = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .fontWeight(.bold)
                                .font(.body)
                                .padding(.horizontal, 8)
                                     .padding(.vertical, 8)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(8)
                        }

                        Text("open menu:")
                            .font(.headline)
                            .foregroundColor(settingsViewModel.appTextColor)

                        Text("scroll down 📜⬇️4 more")
                            .font(.caption)
                            .foregroundColor(settingsViewModel.appTextColor)

                    }
                    .padding(.top, 30)
                    .padding(.leading,8)
                    .padding(.trailing,8)
                    HStack {
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
                                    .foregroundColor(settingsViewModel.appTextColor)
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
                    .padding(.leading,8)
                    .padding(.trailing,8)
                    HStack {
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
                                HStack {
                                    Text("New webview: " )
                                        .font(.subheadline)
                                        .foregroundColor(settingsViewModel.appTextColor)

                                }
                                resizableButtonImage(systemName:
                                                        "rectangle.center.inset.filled.badge.plus",
                                                     size: geometry.size)
                                .fontWeight(.bold)
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(8)
                            }

                        }
                        HStack {

                            TextField(
                                "",
                                text: $settingsViewModel.defaultURL
                            )
                            .border(.secondary)
                            .submitLabel(.done)

                            .focused($field7IsFocused)
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            .scrollDismissesKeyboard(.interactively)
                            .font(.caption)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .autocorrectionDisabled(true)
#if !os(macOS)
                            .autocapitalization(.none)
#endif
                        }
                        .frame(height: geometry.size.height / 17)
                        Spacer()
                    }
                    .padding(.leading,8)
                    .padding(.trailing,8)

                    VStack {

                        HStack {
                            Text("user: ").font(.caption)                                    .foregroundColor(settingsViewModel.appTextColor)


                            TextField(
                                "",
                                text: $settingsViewModel.gitUser
                            )
                            .border(.secondary)
                            .submitLabel(.done)
                            .focused($field4IsFocused)
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            .scrollDismissesKeyboard(.interactively)
                            .font(.caption)
                            .foregroundColor(settingsViewModel.appTextColor)

                            .autocorrectionDisabled(true)
#if !os(macOS)
                            .autocapitalization(.none)
#endif
                        }
                        .frame(height: geometry.size.height / 17)

                        HStack {
                            Text("repo: ").font(.caption)                                    .foregroundColor(settingsViewModel.appTextColor)


                            TextField(
                                "",
                                text: $settingsViewModel.gitRepo
                            )
                            .border(.secondary)
                            .submitLabel(.done)
                            .focused($field5IsFocused)
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            .scrollDismissesKeyboard(.interactively)
                            .font(.caption)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .autocorrectionDisabled(true)
#if !os(macOS)

                            .autocapitalization(.none)
#endif
                        }
                        .frame(height: geometry.size.height / 17)
                        HStack {
                            Text("branch: ").font(.caption)                                    .foregroundColor(settingsViewModel.appTextColor)


                            TextField(
                                "",
                                text: $settingsViewModel.gitBranch
                            )
                            .border(.secondary)
                            .submitLabel(.done)
                            .focused($field6IsFocused)
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                            .scrollDismissesKeyboard(.interactively)
                            .font(.caption)
                            .foregroundColor(settingsViewModel.appTextColor)

                            .autocorrectionDisabled(true)
#if !os(macOS)

                            .autocapitalization(.none)
#endif
                        }
                        .frame(height: geometry.size.height / 17)
                    }

                    if !settingsViewModel.isLoading {
                        HStack(spacing: 4) {
                            Button(action: {
                                logD("Downloading repo...")
                                settingsViewModel.syncGithubRepo()
                            }) {
                                VStack {
                                    Text("download: \(settingsViewModel.currentGitRepoKey().replacingOccurrences(of: SettingsViewModel.gitKeySeparator, with: "/"))")
                                        .font(.subheadline)
                                        .foregroundColor(settingsViewModel.appTextColor)
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

                    Group {
                        let repoListMoji = repoListOpen ? "🔽" : "▶️"

                        let val = max(3, min(15,settingsViewModel.loadDirectories().count))
                        Text("\(repoListMoji) Downloaded Repositories")
                            .font(.title3)
                            .lineLimit(nil)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(settingsViewModel.appTextColor)

                            .onTapGesture {
                                withAnimation {
                                    repoListOpen.toggle()
                                }
                            }
                        if repoListOpen {
                            NavigationView {

                                RepositoriesListView(settingsViewModel: settingsViewModel)
                                    .environmentObject(windowManager)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: geometry.size.height/listHeightFactor * Double(val), maxHeight: geometry.size.height/listHeightFactor * Double(val))
#if !os(macOS)
                            .navigationViewStyle(StackNavigationViewStyle())
#endif
                        }
                    }

                    // OPEN IN WINDOW
                    // symbol: "macwindow.on.rectangle"

                    Group {
                        let filesListMoji = fileListOpen ? "🔽" : "▶️"

                        Text("\(filesListMoji) Repo File Tree")
                            .font(.title3)
                            .lineLimit(nil)
                            .fontWeight(.bold)
                            .padding()
                            .foregroundColor(settingsViewModel.appTextColor)

                            .onTapGesture {
                                withAnimation {

                                    fileListOpen.toggle()
                                }
                            }
                        if (fileListOpen) {


                            let rootFileCount = max(3, min(15,settingsViewModel.rootFiles.count))

                            NavigationView {
                                RepositoryTreeView(settingsViewModel: settingsViewModel, accessToken: "")
                                    .environmentObject(windowManager)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: geometry.size.height/listHeightFactor * Double(rootFileCount), maxHeight: geometry.size.height/listHeightFactor * Double(rootFileCount))
#if !os(macOS)
                            .navigationViewStyle(StackNavigationViewStyle())
#endif
                        }
                    }
                    let windowListMoji = windowListOpen ? "🔽" : "▶️"
                    Text("\(windowListMoji) Window List")
                        .font(.title3)
                        .lineLimit(nil)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(settingsViewModel.appTextColor)
                        .onTapGesture {
                            withAnimation {

                                windowListOpen.toggle()
                            }
                        }
                    if windowListOpen {
                        let windowCount = max(3, min(15,windowManager.windows.count))
                        NavigationView {
                            WindowList(showAddView: $showAddView)
                                .environmentObject(windowManager)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: geometry.size.height/listHeightFactor * Double(windowCount), maxHeight: geometry.size.height/listHeightFactor * Double(windowCount))
#if !os(macOS)
                        .navigationViewStyle(StackNavigationViewStyle())
#endif
                    }
                    Button(action: {
                        withAnimation {
                            showAddView.toggle()

                            field4IsFocused = false
                            field5IsFocused = false
                            field6IsFocused = false
                            field7IsFocused = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .fontWeight(.bold)
                            .font(.body)
                            .padding(.horizontal, 8)
                                 .padding(.vertical, 8)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(8)
                    }

                }
                .padding(.bottom, geometry.size.height / 8)
                .cornerRadius(16)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
#if !os(macOS)
        .background(settingsViewModel.backgroundColor)
#endif
    }
}
