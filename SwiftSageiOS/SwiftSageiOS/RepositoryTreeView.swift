//
//  RepositoryTreeView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/4/23.
//

import SwiftUI

struct RepositoryTreeView: View {
    //    @ObservedObject var settingsViewModel: SettingsViewModel
    let files: [GitHubContent]

    init(accessToken: String, files: [GitHubContent]? = nil) {
        self.files = files ?? SettingsViewModel.shared.rootFiles
    }

    var body: some View {
        NavigationView {
            Group {
                if SettingsViewModel.shared.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(files) { file in
                            if file.type == "dir" {
                                NavigationLink(destination: RepositoryTreeView(accessToken: "", files: file.children)) {
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
                }
            }
            .navigationTitle("Repository Tree")
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
                SettingsViewModel.shared.sourceEditorCode = fileContent
                SettingsViewModel.shared.isEditorVisible = true
            case .failure(let error):
                print("Error fetching file content: \(error.localizedDescription)")
            }
        }
    }
}
