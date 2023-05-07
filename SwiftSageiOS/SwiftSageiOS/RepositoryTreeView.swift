//
//  RepositoryTreeView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/4/23.
//

import SwiftUI

struct RepositoryTreeView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    let files: [GitHubContent]
    @EnvironmentObject var windowManager: WindowManager

    init(settingsViewModel: SettingsViewModel, accessToken: String, files: [GitHubContent]? = nil) {
        self.files = files ?? SettingsViewModel.shared.rootFiles
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        GeometryReader { geometry in
            Group {

                List {
                    ForEach(files) { file in
                        if file.type == "dir" {
                            NavigationLink(destination: RepositoryTreeView(settingsViewModel: settingsViewModel, accessToken: "", files: file.children)) {
                                Text(file.name)
                            }
                        } else {
                            Button(action: {
                               // let defSize = CGRect(x: 0, y: 0, width: geometry.size.width - geometry.size.width / 3, height: geometry.size.height - geometry.size.height / 3)
#if !os(macOS)

                                fileTapped(file, defSize)
#endif
                            }) {
                                Text(file.name)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                .background {
                    if settingsViewModel.isLoading {
                        ProgressView()
                    }
                }
            }
        }
    }

    private func fileTapped(_ file: GitHubContent, _ frame: CGRect) {
        print("Tapped file: \(file.path)")
        // Perform an action when a file is tapped, e.g., navigate to a file content view
        SettingsViewModel.shared.fetchFileContent(accessToken: SettingsViewModel.shared.ghaPat, filePath: file.path) { result in
            switch result {
            case .success(let fileContent):
                print("File content: \(fileContent)")
                // Perform an action with the file content, e.g., navigate to a file content view
                // TODO : FIX PASSING CODE TO THE VIEW MODEL
                //                SettingsViewModel.shared.sourceEditorCode = fileContent

#if !os(macOS)

                windowManager.addWindow(windowType: .file, frame: frame, zIndex: 0, fileContents: fileContent)
#endif

                SettingsViewModel.shared.showAddView = false
            case .failure(let error):
                print("Error fetching file content: \(error.localizedDescription)")
            }
        }
    }
}
