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
        self.files = files ?? settingsViewModel.rootFiles
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if !files.isEmpty {
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
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

                }
                else {
                    Text("Select a repo and it will appear here")
                        .frame(height: 30.0)

                }
            }
        }
    }
    func readFileContents(url: URL) -> String? {
        do {
            // Check if the file exists
            if FileManager.default.fileExists(atPath: url.path) {
                // Read the contents of the file
                let fileData = try Data(contentsOf: url)
                // Convert the data to a string
                let fileString = String(data: fileData, encoding: .utf8)
                return fileString
            } else {
                return "File not found"
            }
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }

    private func fileTapped(_ file: GitHubContent, _ frame: CGRect) {
        print("Tapped file: \(file.path)")

        let documentsDirectory = getDocumentsDirectory()

        let fileURL = documentsDirectory.appendingPathComponent(settingsViewModel.gitUser).appendingPathComponent(settingsViewModel.gitRepo).appendingPathComponent(settingsViewModel.gitBranch).appendingPathComponent(file.path)
        let fileContent = readFileContents(url: fileURL) ?? "Failed to read the file"

#if !os(macOS)

        windowManager.addWindow(windowType: .file, frame: frame, zIndex: 0, file: file, fileContents: fileContent)
#endif

        settingsViewModel.showAddView = false

        //        // FETCH FILE FROM NETWORK, VS FETCH FILE FROM DISK
        //        SettingsViewModel.shared.fetchFileContent(accessToken: SettingsViewModel.shared.ghaPat, filePath: file.path) { result in
        //            switch result {
        //            case .success(let fileContent):
        //                print("File content: \(fileContent)")
        //#if !os(macOS)
        //
        //                windowManager.addWindow(windowType: .file, frame: frame, zIndex: 0, file: file, fileContents: fileContent)
        //#endif
        //
        //                SettingsViewModel.shared.showAddView = false
        //            case .failure(let error):
        //                print("Error fetching file content: \(error.localizedDescription)")
        //            }
        //        }
    }
}
