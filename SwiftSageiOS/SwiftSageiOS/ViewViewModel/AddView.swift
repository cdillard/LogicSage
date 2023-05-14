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

    @AppStorage("repoSettingsShown") var repoSettingsShown: Bool = false
    @AppStorage("repoListOpen") var repoListOpen: Bool = false
    @AppStorage("fileListOpen") var fileListOpen: Bool = false
    @AppStorage("windowListOpen") var windowListOpen: Bool = false

    @FocusState private var field4IsFocused: Bool

    @FocusState private var field5IsFocused: Bool
    @FocusState private var field6IsFocused: Bool
    @FocusState private var field7IsFocused: Bool
    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
            .tint(settingsViewModel.appTextColor)
            .background(settingsViewModel.buttonColor)
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

                    VStack {
                        HStack {

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
                                        .cornerRadius(8)
                                    }

                                }

                                .padding(.bottom)
                            }
                            .padding(.leading,8)

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
                        HStack {
                            Button(action: {
                                withAnimation {
                                    logD("open Change View")
    #if !os(macOS)

                                    if consoleManager.isVisible {
                                        consoleManager.isVisible = false
                                    }
    #endif
                                    showAddView.toggle()
    #if !os(macOS)
                                    windowManager.addWindow(windowType: .changeView, frame: defSize, zIndex: 0)
    #endif
                                }
                            }) {
                                VStack {
                                    Text("View changes...")
                                        .font(.subheadline)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        .padding(.bottom)

                                    resizableButtonImage(systemName:
                                                            "plus.forwardslash.minus",
                                                         size: geometry.size)
                                    .fontWeight(.bold)
                                    .cornerRadius(8)
                                }

                            }

                            .padding(.bottom)
                        }
                        .padding(.leading,8)
                    }

                    let repoListMoji = repoSettingsShown ? "🔽" : "▶️"

                    Text("\(repoListMoji) git settings")
                        .font(.title3)
                        .lineLimit(nil)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(settingsViewModel.appTextColor)
                        .onTapGesture {
                            withAnimation {
                                repoSettingsShown.toggle()
                            }
                        }

                    if repoSettingsShown {
                        VStack {

                            HStack {
                                Text("user: ").font(.caption)
                                    .foregroundColor(settingsViewModel.appTextColor)


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
                                Text("repo: ").font(.caption)
                                    .foregroundColor(settingsViewModel.appTextColor)


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
                                Text("branch: ").font(.caption)
                                    .foregroundColor(settingsViewModel.appTextColor)


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
                        .padding(.leading,8)
                        .padding(.trailing,8)
                    }
                    Text("download: \(settingsViewModel.currentGitRepoKey().replacingOccurrences(of: SettingsViewModel.gitKeySeparator, with: "/"))")
                        .font(.subheadline)
                        .foregroundColor(settingsViewModel.appTextColor)
                    if !settingsViewModel.isLoading {
                        HStack(spacing: 4) {
                            Button(action: {
                                logD("Downloading repo...")
                                settingsViewModel.syncGithubRepo { success in
                                    repoListOpen = true
                                    
                                }
                            }) {
                                VStack {

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
                        if settingsViewModel.unzipProgress > 0.0 {
                            HStack {
                                Text("unzip...")
                                ProgressView(value: settingsViewModel.unzipProgress)
                            }
                            .padding(.trailing, 32)
                            .padding(.leading, 32)

                        }
                        if settingsViewModel.downloadProgress > 0.0 {
                            HStack {
                                Text("download...")

                                ProgressView(value: settingsViewModel.downloadProgress)
                            }
                            .padding(.trailing, 32)
                            .padding(.leading, 32)

                        }
                    }

                    // TODO: IMPL OPEN IN WINDOW for both Repo Tree and Window List.
                    // symbol: "macwindow.on.rectangle"

                    Group {
                        let filesListMoji = fileListOpen ? "🔽" : "▶️"
                        VStack {
                            HStack {
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


                                VStack {
//                                    HStack {
//                                        Text("New container: " )
//                                            .font(.subheadline)
//                                            .foregroundColor(settingsViewModel.appTextColor)
//
//                                    }
                                    resizableButtonImage(systemName:
                                                            "macwindow.on.rectangle",
                                                         size: geometry.size)
                                    .fontWeight(.bold)
                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .background(settingsViewModel.buttonColor)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        withAnimation {

                                            logD("Open container containing repo tree")

            #if !os(macOS)
                                            if consoleManager.isVisible {
                                                consoleManager.isVisible = false
                                            }
            #endif
                                            logD("open Container")
                                            showAddView.toggle()

            #if !os(macOS)
                                            // let defSize = CGRect(x: 0, y: 0, width: geometry.size.width - geometry.size.width / 3, height: geometry.size.height - geometry.size.height / 3)

                                            windowManager.addWindow(windowType: .repoTreeView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
            #endif
                                        }
                                    }
                                }

                            }
                            if (fileListOpen) {

                                NavigationView {
                                    if let root = settingsViewModel.root {
                                        let newWindow = WindowInfo(frame: defSize, zIndex: 0, windowType: .repoTreeView, fileContents: "", file: nil, url: nil)

                                        let viewModel = SageMultiViewModel(windowInfo: newWindow)
                                        RepositoryTreeView(sageMultiViewModel: viewModel, settingsViewModel: settingsViewModel, directory: root, window: nil)
                                            .environmentObject(windowManager)
                                    }
                                    else {
                                        Text("No root")
                                    }
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: 600)
#if !os(macOS)
                                .navigationViewStyle(StackNavigationViewStyle())
#endif
                            }
                        }
                    }
                    HStack {
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

//                        HStack {
//                            Text("New container: " )
//                                .font(.subheadline)
//                                .foregroundColor(settingsViewModel.appTextColor)
//
//                        }
                        resizableButtonImage(systemName:
                                                "macwindow.on.rectangle",
                                             size: geometry.size)
                        .fontWeight(.bold)
                        .foregroundColor(settingsViewModel.appTextColor)
                        .background(settingsViewModel.buttonColor)
                        .cornerRadius(8)
                        .onTapGesture {
                            withAnimation {

                                logD("Open container containing repo tree")

#if !os(macOS)
                                if consoleManager.isVisible {
                                    consoleManager.isVisible = false
                                }
#endif
                                logD("open Container")
                                showAddView.toggle()

#if !os(macOS)
                                // let defSize = CGRect(x: 0, y: 0, width: geometry.size.width - geometry.size.width / 3, height: geometry.size.height - geometry.size.height / 3)

                                windowManager.addWindow(windowType: .windowListView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
#endif
                            }
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
