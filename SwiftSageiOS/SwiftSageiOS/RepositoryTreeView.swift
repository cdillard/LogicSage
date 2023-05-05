//
//  RepositoryTreeView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/4/23.
//

import SwiftUI
struct RepositoryFile: Identifiable {
    let id: String
    let name: String
    let path: String
    var isDirectory: Bool = false
    var children: [RepositoryFile] = []
}
struct RepositoryTreeView: View {
//    @ObservedObject var settingsViewModel: SettingsViewModel

    private let accessToken: String
    private let files: [RepositoryFile]

    init(accessToken: String, files: [RepositoryFile]? = nil) {
        self.accessToken = accessToken
        self.files = files ?? []
    }

    var body: some View {
        NavigationView {
            Group {
                if SettingsViewModel.shared.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(files.isEmpty ? SettingsViewModel.shared.rootFiles : files) { file in
                            if file.isDirectory {
                                NavigationLink(destination: RepositoryTreeView(accessToken: accessToken, files: file.children)) {
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
            .onAppear {
                if files.isEmpty {
                    SettingsViewModel.shared.fetchRepositoryTreeStructure(accessToken: accessToken)
                }
            }
        }
    }

    private func fileTapped(_ file: RepositoryFile) {
        print("Tapped file: \(file.path)")
        // Perform an action when a file is tapped, e.g., navigate to a file content view
        SettingsViewModel.shared.fetchFileContent(accessToken: accessToken, filePath: file.path) { result in
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
