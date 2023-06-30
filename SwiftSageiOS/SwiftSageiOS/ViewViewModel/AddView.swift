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

    @Binding var isInputViewShown: Bool
    @Binding var tabSelection: Int
    @State var gitSettingsTitleLabelString: String = "▶️ Git settings"
    @State private var gitSettingsExpanded = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    HStack {
                        topBar()
                    }
                    .padding(.top, 30)
                    .padding(.leading,8)
                    .padding(.trailing,8)

                    VStack {
                        HStack {
                            VStack {
                                topRow(size: geometry.size)

                                bottomRow(size: geometry.size)

                                urlEntry()
                                    .frame(height: geometry.size.height / 17)
                                Spacer()
                            }
                        }
                        // Open Change View , Open Working Changes View Stack, Repo Tree, Windows Buttons
                        miscButtons(size: geometry.size)
                    }

                    gitSettingsDisc(size: geometry.size)

                    Button(action: {
                        withAnimation {
                            tabSelection = 1
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(8)
#if !os(macOS)
                            .hoverEffect(.lift)
#endif
                    }
                }
                .padding(.bottom, geometry.size.height / 8)
                .cornerRadius(16)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .accentColor(settingsViewModel.buttonColor)
            .foregroundColor(settingsViewModel.appTextColor)
        }
#if !os(macOS)
        .background(settingsViewModel.backgroundColor)
#endif
    }

    func topBar() -> some View {
        Group {
            // SHOW ADD VIEW BUTTON
            Button(action: {
                withAnimation {
                    tabSelection = 1
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.body)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .foregroundColor(settingsViewModel.appTextColor)
                    .background(settingsViewModel.buttonColor)
                    .cornerRadius(8)
#if !os(macOS)
                    .hoverEffect(.lift)
#endif
            }
            
            Text("open menu:")
                .font(.title3)
                .foregroundColor(settingsViewModel.appTextColor)
            
            Text("scroll down 📜⬇️4 more")
                .font(.title3)
                .foregroundColor(settingsViewModel.appTextColor)
        }
    }
    func miscButtons(size: CGSize) -> some View {
        HStack {

            Button(action: {
                withAnimation {
                    logD("open Working Changes View")
                    tabSelection = 1
                    windowManager.addWindow(windowType: .workingChangesView, frame: defSize, zIndex: 0)
                }
            }) {
                VStack {
                    resizableButtonImage(systemName:
                                            "lasso",
                                         size: size)
                    .cornerRadius(8)
                    Text("Changes")
                        .font(.caption)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
#if !os(macOS)
                .hoverEffect(.lift)
#endif
            }

            Group {
                VStack {
                    HStack(spacing: 0) {

                        VStack {
                            resizableButtonImage(systemName:
                                                    "folder.fill.badge.plus",
                                                 size: size)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(8)
                            .onTapGesture {
                                withAnimation {

                                    logD("Open container containing repo tree")

                                    tabSelection = 1
                                    windowManager.addWindow(windowType: .repoTreeView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
                                }
                            }
                            Text("Files")
                                .font(.caption)
                                .lineLimit(nil)
                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(macOS)
                        .hoverEffect(.lift)
#endif
                    }
                }
            }
            VStack {
                resizableButtonImage(systemName:
                                        "macwindow",
                                     size: size)
                .foregroundColor(settingsViewModel.appTextColor)
                .background(settingsViewModel.buttonColor)
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation {
                        logD("Open container containing repo tree")

                        tabSelection = 1
                        windowManager.addWindow(windowType: .windowListView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
                    }
                }
                Text("Windows")
                    .font(.caption)
                    .lineLimit(nil)
                    .foregroundColor(settingsViewModel.appTextColor)
            }
#if !os(macOS)
            .hoverEffect(.lift)
#endif
        }
    }
    func urlEntry() -> some View {
        HStack {
            if #available(iOS 16.0, *) {
                TextField(
                    "",
                    text: $settingsViewModel.defaultURL
                )
                .border(.secondary)
                .submitLabel(.done)
                .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(xrOS)
                .scrollDismissesKeyboard(.interactively)
#endif
                .font(.title3)
                .padding(.leading,8)
                .padding(.trailing,8)
                .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                .autocorrectionDisabled(true)
#endif

#if !os(macOS)
                .autocapitalization(.none)
#endif
            }
            else {
                TextField(
                    "",
                    text: $settingsViewModel.defaultURL
                )
                .frame( maxWidth: .infinity, maxHeight: .infinity)
                .font(.title3)
                .padding(.leading,8)
                .padding(.trailing,8)
                .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)

                .autocorrectionDisabled(true)
#endif
#if !os(macOS)
                .autocapitalization(.none)
#endif
            }
        }
    }
    func bottomRow(size: CGSize) -> some View {
        // BOTTOM ROW
        HStack {
            // PROJECT/DEBUGGER WINDOW
            Button(action: {
                withAnimation {
                    logD("open new project window")

                    showAddView.toggle()
                    tabSelection = 1

                    windowManager.addWindow(windowType: .project, frame: defSize, zIndex: 0)
                }
            }) {
                VStack {
                    resizableButtonImage(systemName:
                                            "target",
                                         size: size)
                    Text("Project")
                        .font(.caption)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
#if !os(macOS)
                .hoverEffect(.lift)
#endif
            }
            // NEW FILE WINDOW
            Button(action: {
                withAnimation {
                    logD("open new File")
                    showAddView.toggle()
                    tabSelection = 1

                    windowManager.addWindow(windowType: .file, frame: defSize, zIndex: 0)
                }
            }) {
                VStack {
                    resizableButtonImage(systemName:
                                            "doc.badge.plus",
                                         size: size)
                    .cornerRadius(8)

                    Text("File")
                        .font(.caption)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
#if !os(macOS)
                .hoverEffect(.lift)
#endif
            }
            Button(action: {
                withAnimation {
                    logD("open Webview")
                    showAddView.toggle()
                    tabSelection = 1
                    windowManager.addWindow(windowType: .webView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
                }
            }) {
                VStack {
                    resizableButtonImage(systemName:
                                            "network",
                                         size: size)
                    .background(settingsViewModel.buttonColor)
                    .cornerRadius(8)

                    Text("Webview" )
                        .font(.caption)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
#if !os(macOS)
                .hoverEffect(.lift)
#endif
            }
        }

        // end bottom row
    }
    func topRow(size: CGSize) -> some View {
        HStack {
            // PROJECT/DEBUGGER WINDOW
            Button(action: {
                withAnimation {
                    logD("Upload Workspace")

                    DispatchQueue.main.async {

                        // Execute your action here
                        screamer.sendCommand(command: "arrow.up.circle")

                        isInputViewShown = false

                    }
                }
            }) {
                VStack {
                    resizableButtonImage(systemName:
                                            "arrow.up.circle",
                                         size: size)
                    .cornerRadius(8)

                    Text("Upload")
                        .font(.caption)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
#if !os(macOS)
                .hoverEffect(.lift)
#endif
            }

            // NEW FILE WINDOW
            Button(action: {
                withAnimation {
                    logD("Download Workspace")
                    showAddView.toggle()
                    tabSelection = 1

                    logD("DO WORKSPACE DOWNLOAD!")

                    DispatchQueue.main.async {
                        screamer.sendCommand(command:  "download")
                        isInputViewShown = false
                    }
                }
            }) {
                VStack {
                    resizableButtonImage(systemName:
                                            "arrow.down.circle",
                                         size: size)
                    .cornerRadius(8)
                    Text("Download")
                        .font(.caption)
                        .foregroundColor(settingsViewModel.appTextColor)
                }
#if !os(macOS)
                .hoverEffect(.lift)
#endif
            }
        }
    }

    func gitSettingsDisc(size: CGSize) -> some View {
        DisclosureGroup(isExpanded: $gitSettingsExpanded)  {
            VStack {
                HStack {

                    if !settingsViewModel.isLoading {

                        HStack(spacing: 4) {
                            VStack {
                                Button(action: {
                                    logD("FORKING repo...")
                                    settingsViewModel.forkGithubRepo { success in
                                        logD("fork repo success = \(success)")
                                    }
                                }) {
                                    VStack {
                                        resizableButtonImage(systemName:
                                                                "tuningfork",
                                                             size: size)
                                        .background(settingsViewModel.buttonColor)
                                        .cornerRadius(8)
                                    }
#if !os(macOS)
                                    .hoverEffect(.lift)
#endif
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
                                            logD("download repo success = \(success)")
                                        }
                                    }) {
                                        VStack {
                                            resizableButtonImage(systemName:
                                                                    "arrow.down.doc",
                                                                 size: size)
                                            .background(settingsViewModel.buttonColor)
                                            .cornerRadius(8)
                                        }
#if !os(macOS)
                                        .hoverEffect(.lift)
#endif
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
                .frame(height: size.height / 17)

                HStack {

                    Text("your github username:")
                        .font(.body)
                        .lineLimit(nil)
                        .padding()
                        .foregroundColor(settingsViewModel.appTextColor)
                    if #available(iOS 16.0, *) {

                        TextField(
                            "",
                            text: $settingsViewModel.yourGitUser
                        )
                        .border(.secondary)
                        .submitLabel(.done)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(xrOS)
                        .scrollDismissesKeyboard(.interactively)
#endif

                        .font(.caption)
                        .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)

                        .autocorrectionDisabled(true)
#endif

#if !os(macOS)
                        .autocapitalization(.none)
#endif
                    }
                    else {
                        TextField(
                            "",
                            text: $settingsViewModel.yourGitUser
                        )
                        {
#if !os(macOS)
                            hideKeyboard()
#endif
                        }

                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .font(.caption)
                        .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)
                        .autocorrectionDisabled(true)
#endif

#if !os(macOS)
                        .autocapitalization(.none)
#endif
                    }
                }
                Text("Remote repo settings:")
                    .font(.title3)
                    .lineLimit(nil)
                    .padding()
                    .foregroundColor(settingsViewModel.appTextColor)
                HStack {
                    Text("user: ")
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)

                    if #available(iOS 16.0, *) {

                        TextField(
                            "",
                            text: $settingsViewModel.gitUser
                        )
                        .border(.secondary)
                        .submitLabel(.done)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(xrOS)
                        .scrollDismissesKeyboard(.interactively)
#endif
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)

                        .autocorrectionDisabled(true)
#endif
#if !os(macOS)
                        .autocapitalization(.none)
#endif
                    }
                    else {
                        TextField(
                            "",
                            text: $settingsViewModel.gitUser
                        )
                        {
#if !os(macOS)
                            hideKeyboard()
#endif
                        }

                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
                        .autocorrectionDisabled(true)
#if !os(macOS)
                        .autocapitalization(.none)
#endif
                    }
                }
                .frame(height: size.height / 17)

                HStack {
                    Text("repo:")
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
                    if #available(iOS 16.0, *) {

                        TextField(
                            "",
                            text: $settingsViewModel.gitRepo
                        )
                        .border(.secondary)
                        .submitLabel(.done)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(xrOS)
                        .scrollDismissesKeyboard(.interactively)
#endif
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)

#if !os(macOS)

                        .autocorrectionDisabled(true)
#endif
#if !os(macOS)
                        .autocapitalization(.none)
#endif
                    }
                    else {
                        TextField(
                            "",
                            text: $settingsViewModel.gitRepo
                        ) {
#if !os(macOS)
                            hideKeyboard()
#endif

                        }
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)

                        .autocorrectionDisabled(true)
#endif
#if !os(macOS)
                        .autocapitalization(.none)
#endif
                    }
                }
                .frame(height: size.height / 17)
                HStack {
                    Text("branch:")
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)

                    if #available(iOS 16.0, *) {

                        TextField(
                            "",
                            text: $settingsViewModel.gitBranch
                        )
                        {
#if !os(macOS)
                            hideKeyboard()
#endif
                        }
                        .border(.secondary)
                        .submitLabel(.done)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
#if !os(xrOS)
                        .scrollDismissesKeyboard(.interactively)
#endif
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)

                        .autocorrectionDisabled(true)
#endif
#if !os(macOS)
                        .autocapitalization(.none)
#endif
                    }
                    else {
                        TextField(
                            "",
                            text: $settingsViewModel.gitBranch
                        )
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .frame( maxWidth: .infinity, maxHeight: .infinity)
                        .font(.title3)
                        .foregroundColor(settingsViewModel.appTextColor)
#if !os(macOS)

                        .autocorrectionDisabled(true)
#endif
#if !os(macOS)
                        .autocapitalization(.none)
#endif
                    }
                }
                .frame(height: size.height / 17)
            }
            .padding(.leading,8)
            .padding(.trailing,8)
        }
    label: { Text(gitSettingsTitleLabelString)
            .onTapGesture {
                withAnimation {
                    gitSettingsExpanded.toggle()
                }
            }}
            .onChange(of: gitSettingsExpanded) { isExpanded in
                gitSettingsTitleLabelString  = "\(isExpanded ? "🔽" : "▶️") Git settings"
                playSelect()
            }
            .padding(.leading, 8)
            .padding(.trailing, 8)
            .accentColor(settingsViewModel.buttonColor)
            .foregroundColor(settingsViewModel.appTextColor)
        // END GIT SETTINGS DISCLOSURE GROUP
    }

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
#if os(macOS)
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
#else
        if #available(iOS 16.0, *) {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
                .tint(settingsViewModel.appTextColor)
                .foregroundColor(settingsViewModel.appTextColor)
                .background(settingsViewModel.buttonColor)
        } else {
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
                .foregroundColor(settingsViewModel.appTextColor)
                .background(settingsViewModel.buttonColor)
        }
#endif
    }
}
