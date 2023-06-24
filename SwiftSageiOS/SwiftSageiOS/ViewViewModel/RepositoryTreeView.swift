//
//  RepositoryTreeView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/4/23.
//

import SwiftUI

#if !os(macOS)
#if !os(xrOS)

struct RepositoryTreeView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    let directory: RepoFile
    @ObservedObject var windowManager: WindowManager
    var window: WindowInfo?
    @ObservedObject var sageMultiViewModel: SageMultiViewModel

    init(sageMultiViewModel: SageMultiViewModel, settingsViewModel: SettingsViewModel, directory: RepoFile, window: WindowInfo? = nil, windowManager: WindowManager) {
        self.sageMultiViewModel = sageMultiViewModel
        self.settingsViewModel = settingsViewModel
        self.directory = directory
        self.window = window
        self.windowManager = windowManager
    }

    var body: some View {
        List(directory.children ?? [RepoFile]()) { file in
            if file.isDirectory {
                NavigationLink(destination: RepositoryTreeView(sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel, directory: file, window: window, windowManager: windowManager)) {
                    Text(file.name + " >")
                        .foregroundColor(settingsViewModel.appTextColor)
                }
            } else {
                HStack {
                    Button( action: {
                        fileTapped(file, defSize)
                    })
                    {
                        Text(file.name)
                            .foregroundColor(settingsViewModel.buttonColor)
                    }
                }
            }
        }
        .listRowBackground(settingsViewModel.backgroundColor)
        .navigationBarTitle(directory.name, displayMode: .inline)

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


        if file.url.pathExtension == "heic" ||
            file.url.pathExtension == "jpg"  ||
            file.url.pathExtension == "jpeg" ||
            file.url.pathExtension == "png" {

            // Handle double duty of setting this wallpape
            do {
                let fileData = try Data(contentsOf: file.url)

                settingsViewModel.receivedImageData = fileData
            }
            catch {
                logD("fail to set wallpaper from disk w e \(error)")
            }
            return

        }


        let fileContent = readFileContents(url: file.url) ?? "Failed to read the file"

        windowManager.addWindow(windowType: .file, frame: frame, zIndex: 0, file: file, fileContents: fileContent)

//        settingsViewModel.showAddView = false

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
    func delete(at offsets: IndexSet) {
        print("Should delete folder / file at \(offsets)")
        //users.remove(atOffsets: offsets)
    }
}
#endif
#endif
