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
        Group {

            List {
                ForEach(files) { file in
                    if file.type == "dir" {
                        NavigationLink(destination: RepositoryTreeView(settingsViewModel: settingsViewModel, accessToken: "", files: file.children)) {
                            Text(file.name)
                        }
                    } else {
                        Button(action: {
                            fileTapped(file)
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

    private func fileTapped(_ file: GitHubContent) {
        print("Tapped file: \(file.path)")
        // Perform an action when a file is tapped, e.g., navigate to a file content view
        SettingsViewModel.shared.fetchFileContent(accessToken: SettingsViewModel.shared.ghaPat, filePath: file.path) { result in
            switch result {
            case .success(let fileContent):
                print("File content: \(fileContent)")
                // Perform an action with the file content, e.g., navigate to a file content view
                // TODO : FIX PASSING CODE TO THE VIEW MODEL
                //                SettingsViewModel.shared.sourceEditorCode = fileContent

                windowManager.addWindow(windowType: .file, frame: defSize, zIndex: 0, fileContents: fileContent)

                SettingsViewModel.shared.showAddView = false
            case .failure(let error):
                print("Error fetching file content: \(error.localizedDescription)")
            }
        }
    }
}
