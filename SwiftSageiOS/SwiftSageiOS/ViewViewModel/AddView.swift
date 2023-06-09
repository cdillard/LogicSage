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
    @ObservedObject var windowManager: WindowManager


    // TODO: Reuse this to handle open / not open and restore repo / filw and window list
    @AppStorage("repoListOpen") var repoListOpen: Bool = false
    @AppStorage("fileListOpen") var fileListOpen: Bool = false
    @AppStorage("windowListOpen") var windowListOpen: Bool = false

    @FocusState private var field4IsFocused: Bool

    @FocusState private var field5IsFocused: Bool
    @FocusState private var field6IsFocused: Bool
    @FocusState private var field7IsFocused: Bool
    @FocusState private var field8IsFocused: Bool
    @Binding var isInputViewShown: Bool

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
                                field8IsFocused = false
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
                            VStack {
                                // start top row
                                    HStack {
                                        // PROJECT/DEBUGGER WINDOW
                                        Button(action: {
                                            withAnimation {
                                                logD("Upload Workspace")

                                                DispatchQueue.main.async {

                                                    // Execute your action here
                                                    screamer.sendCommand(command: "upload")

                                                   isInputViewShown = false

                                                }
                                            }
                                        }) {
                                            VStack {
                                                resizableButtonImage(systemName:
                                                                        "arrow.up.circle.fill",
                                                                     size: geometry.size)
                                                .fontWeight(.bold)
                                                .cornerRadius(8)

                                                Text("Upload")
                                                    .font(.caption)
                                                    .foregroundColor(settingsViewModel.appTextColor)
                                            }
                                        }

                                        // NEW FILE WINDOW
                                        Button(action: {
                                            withAnimation {
                                                logD("Download Workspace")

                                                // TODO: Hide or show terminal chat?


                                                showAddView.toggle()


                                                logD("DO WORKSPACE DOWNLOAD!")

                                                DispatchQueue.main.async {

                                                    // Execute your action here
                                                    screamer.sendCommand(command:  "download")

                                                    isInputViewShown = false

                                                }
                                            }
                                        }) {
                                            VStack {


                                                resizableButtonImage(systemName:
                                                                        "arrow.down.circle.fill",
                                                                     size: geometry.size)
                                                .fontWeight(.bold)
                                                .cornerRadius(8)

                                                Text("Download")
                                                    .font(.caption)
                                                    .foregroundColor(settingsViewModel.appTextColor)
                                            }
                                        }

                                    }
//                                }
                                //.padding(.leading,8)
                                // end top row

                                // BOTTOM ROW
                                HStack {
                                    // PROJECT/DEBUGGER WINDOW
                                    Button(action: {
                                        withAnimation {
                                            logD("open new project window")
                                            logD("open new debugger window")


                                            // TODO: Hide or show terminal chat?


                                            showAddView.toggle()
#if !os(macOS)
                                            windowManager.addWindow(windowType: .project, frame: defSize, zIndex: 0)
#endif
                                        }
                                    }) {
                                        VStack {


                                            resizableButtonImage(systemName:
                                                                    "iphone.badge.play",
                                                                 size: geometry.size)
                                            .fontWeight(.bold)
                                            .cornerRadius(8)

                                            Text("Project")
                                                .font(.caption)
                                                .foregroundColor(settingsViewModel.appTextColor)
                                        }
                                    }


                                    // NEW FILE WINDOW
                                    Button(action: {
                                        withAnimation {
                                            logD("open new File")
                                            // TODO: Hide or show terminal chat?

                                            showAddView.toggle()
#if !os(macOS)
                                            windowManager.addWindow(windowType: .file, frame: defSize, zIndex: 0)
#endif
                                        }
                                    }) {
                                        VStack {


                                            resizableButtonImage(systemName:
                                                                    "doc.fill.badge.plus",
                                                                 size: geometry.size)
                                            .fontWeight(.bold)
                                            .cornerRadius(8)

                                            Text("File")
                                                .font(.caption)
                                                .foregroundColor(settingsViewModel.appTextColor)
                                        }
                                    }
                                    Button(action: {
                                        withAnimation {

                                            logD("open Webview")
                                            showAddView.toggle()
                                            // TODO: Hide or show terminal chat?

#if !os(macOS)
                                            windowManager.addWindow(windowType: .webView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
#endif
                                        }
                                    }) {
                                        VStack {

                                            resizableButtonImage(systemName:
                                                                    "rectangle.center.inset.filled.badge.plus",
                                                                 size: geometry.size)
                                            .fontWeight(.bold)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)

                                            Text("Webview" )
                                                .font(.caption)
                                                .foregroundColor(settingsViewModel.appTextColor)

                                        }
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
                                    .padding(.leading,8)

                                    .padding(.trailing,8)

                                    .foregroundColor(settingsViewModel.appTextColor)
                                    .autocorrectionDisabled(true)
#if !os(macOS)
                                    .autocapitalization(.none)
#endif
                                }
                                .frame(height: geometry.size.height / 17)
                                Spacer()
                            }
                            // end bottom row
                        }

                        // Open Change View , Open Working Changes View Stack

                        HStack {

                            Button(action: {
                                withAnimation {
                                    logD("open Working Changes View")
                                    // TODO: Hide or show terminal chat?

                                    showAddView.toggle()
#if !os(macOS)
                                    windowManager.addWindow(windowType: .workingChangesView, frame: defSize, zIndex: 0)
#endif
                                }
                            }) {
                                VStack {


                                    resizableButtonImage(systemName:
                                                            "lasso.and.sparkles",
                                                         size: geometry.size)
                                    .fontWeight(.bold)
                                    .cornerRadius(8)

                                    Text("Changes")
                                        .font(.caption)
                                        .foregroundColor(settingsViewModel.appTextColor)
                                        //.padding(.bottom)
                                }
                            }

                            Group {
                                VStack {
                                    HStack(spacing: 0) {

                                        VStack {
                                            resizableButtonImage(systemName:
                                                                    "macwindow.on.rectangle",
                                                                 size: geometry.size)
                                            .foregroundColor(settingsViewModel.appTextColor)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                withAnimation {

                                                    logD("Open container containing repo tree")

                                                    showAddView.toggle()
#if !os(macOS)
                                                    windowManager.addWindow(windowType: .repoTreeView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
#endif
                                                }
                                            }
                                            Text("Files")
                                                .font(.caption)
                                                .lineLimit(nil)
                                                //.fontWeight(.bold)
                                              //  .padding()
                                                .foregroundColor(settingsViewModel.appTextColor)

                                        }
                                    }
                                }
                            }
                            VStack {



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

                                        showAddView.toggle()
#if !os(macOS)
                                        windowManager.addWindow(windowType: .windowListView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
#endif
                                    }
                                }
                                Text("Windows")
                                    .font(.caption)
                                    .lineLimit(nil)
                                    .foregroundColor(settingsViewModel.appTextColor)
                            }
                        }
//                        .padding(.leading,8)
                    }

                    // GIT SETTINGS

                    let repoListMoji = settingsViewModel.repoSettingsShown ? "🔽" : "▶️"

                    Text("\(repoListMoji) git settings")
                        .font(.title3)
                        .lineLimit(nil)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .foregroundColor(settingsViewModel.appTextColor)
                        .onTapGesture {
                            playSelect()

                            withAnimation {
                                settingsViewModel.repoSettingsShown.toggle()
                            }
                        }

                    if settingsViewModel.repoSettingsShown {
                        VStack {
                            HStack {

                                if !settingsViewModel.isLoading {

                                    HStack(spacing: 4) {
                                        VStack {
                                            Button(action: {
                                                logD("FORKING repo...")
                                                settingsViewModel.forkGithubRepo { success in
                                                    repoListOpen = true
                                                    logD("fork repo success = \(success)")

                                                }
                                            }) {
                                                VStack {
                                                    resizableButtonImage(systemName:
                                                                            "tuningfork",
                                                                         size: geometry.size)
                                                    .fontWeight(.bold)
                                                    .background(settingsViewModel.buttonColor)
                                                    .cornerRadius(8)
                                                }
                                            }
                                            .frame( maxWidth: .infinity, maxHeight: .infinity)
                                            .padding(.bottom)

                                            Text("\(settingsViewModel.yourGitUser):\(settingsViewModel.gitRepo):\(settingsViewModel.gitBranch)")
                                                .font(.caption)
                                                .scaledToFill()
                                                .minimumScaleFactor(0.01)
                                                .foregroundColor(settingsViewModel.appTextColor)
                                        }

                                        VStack {
                                            HStack(spacing: 4) {
                                                Button(action: {
                                                    logD("Downloading repo...")
                                                    settingsViewModel.syncGithubRepo { success in
                                                        repoListOpen = true
                                                        logD("download repo success = \(success)")
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

                                            Text("dl/replace: \(settingsViewModel.currentGitRepoKey().replacingOccurrences(of: SettingsViewModel.gitKeySeparator, with: "/"))")
                                                .font(.caption)
                                                .scaledToFill()
                                                .minimumScaleFactor(0.01)
                                                .foregroundColor(settingsViewModel.appTextColor)
                                        }
                                    }
                                    .padding(.leading, 8)
                                    .padding(.trailing, 8)
                                }
                                else {
                                    ZStack {
                                        if settingsViewModel.unzipProgress > 0.0 {
                                            HStack {
                                                Text("unzip...")
                                                    .font(.body)
                                                    .lineLimit(nil)
                                                    .foregroundColor(settingsViewModel.appTextColor)

                                                ProgressView(value: settingsViewModel.unzipProgress)
                                            }
                                            .padding(.trailing, 32)
                                            .padding(.leading, 32)

                                        }
                                        else if settingsViewModel.downloadProgress > 0.0 {
                                            HStack {
                                                Text("download...")
                                                    .font(.body)
                                                    .lineLimit(nil)
                                                    .foregroundColor(settingsViewModel.appTextColor)


                                                ProgressView(value: settingsViewModel.downloadProgress)
                                            }
                                            .padding(.trailing, 32)
                                            .padding(.leading, 32)
                                        }
                                        else if settingsViewModel.forkProgress > 0.0 {
                                            HStack {
                                                Text("forking...")
                                                    .font(.body)
                                                    .lineLimit(nil)
                                                    .foregroundColor(settingsViewModel.appTextColor)


                                                ProgressView(value: settingsViewModel.forkProgress)
                                            }
                                            .padding(.trailing, 32)
                                            .padding(.leading, 32)
                                        }
                                        else if settingsViewModel.isLoading {
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                            .frame(height: geometry.size.height / 17)

                            HStack {

                                Text("your github username:")
                                    .font(.body)
                                    .lineLimit(nil)
                                    .fontWeight(.bold)
                                    .padding()
                                    .foregroundColor(settingsViewModel.appTextColor)

                                TextField(
                                    "",
                                    text: $settingsViewModel.yourGitUser
                                )
                                .border(.secondary)
                                .submitLabel(.done)
                                .focused($field8IsFocused)
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
                            Text("Remote repo settings:")
                                .font(.body)
                                .lineLimit(nil)
                                .fontWeight(.bold)
                                .padding()
                                .foregroundColor(settingsViewModel.appTextColor)
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
                                Text("repo:").font(.caption)
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
                                Text("branch:").font(.caption)
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




                    Button(action: {
                        withAnimation {
                            showAddView.toggle()

                            field4IsFocused = false
                            field5IsFocused = false
                            field6IsFocused = false
                            field7IsFocused = false
                            field8IsFocused = false
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
