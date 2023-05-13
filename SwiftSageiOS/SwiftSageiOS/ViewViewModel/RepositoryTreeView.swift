//
//  RepositoryTreeView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/4/23.
//

import SwiftUI

struct RepositoryTreeView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    let directory: RepoFile
    @EnvironmentObject var windowManager: WindowManager

    init(settingsViewModel: SettingsViewModel, directory: RepoFile) {
        self.settingsViewModel = settingsViewModel

        self.directory = directory
    }

    var body: some View {
//                if !directory.isEmpty {
        GeometryReader { geometry in
            Group {
                
                List(directory.children ?? [RepoFile]()) { file in
                    if file.isDirectory {
                        NavigationLink(destination: RepositoryTreeView(settingsViewModel: settingsViewModel, directory: file)) {
                            Text(file.name)
                        }
                    } else {
                        HStack {
                            Button( action: {
                                fileTapped(file, defSize)
                            })
                            {
                                Text(file.name)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .navigationBarTitle(directory.name)
            }
        }
    
//        List {
//                             ForEach(files) { file in
//        List(directory.children ?? [RepoFile](), id: \.name) { file in
//            if file.isDirectory {
//
//                NavigationLink(destination: RepositoryTreeView(settingsViewModel: settingsViewModel, directory: file)) {
//                    Text(file.name)
//                }
//
//            } else {
//                Button(action: {
//                    // let defSize = CGRect(x: 0, y: 0, width: geometry.size.width - geometry.size.width / 3, height: geometry.size.height - geometry.size.height / 3)
//#if !os(macOS)
//
//                    fileTapped(file, defSize)
//#endif
//                }) {
//                    Text(file.name)
//                        .foregroundColor(.blue)
//                }
//            }
//        }

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

    private func fileTapped(_ file: RepoFile, _ frame: CGRect) {
        print("Tapped file: \(file)")

        let documentsDirectory = getDocumentsDirectory()

        let fileContent = readFileContents(url: file.url) ?? "Failed to read the file"
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
