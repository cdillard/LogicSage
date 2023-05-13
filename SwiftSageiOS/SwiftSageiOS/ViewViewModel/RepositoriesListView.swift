//
//  RepositoriesListView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/7/23.
//

import Foundation
import SwiftUI

struct RepositoriesListView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State private var directories: [URL] = []


    var body: some View {
        GeometryReader { geometry in
  //          if !directories.isEmpty {

                List(directories, id: \.self) { directory in
                    HStack {
                        Text(directory.pathComponents.suffix(3).joined(separator: "/"))
                            .font(.title3)
                            .lineLimit(nil)
                            .fontWeight(.bold)
                            .foregroundColor(settingsViewModel.appTextColor)
                            .onTapGesture {
                                repoTapped(directory)
                            }
                        if settingsViewModel.isLoading {
                            ProgressView()
                        }
                    }
                }

                .onChange(of: settingsViewModel.isLoading) { _ in
                    directories = settingsViewModel.loadDirectories()

                }
                .onAppear {
                    directories = settingsViewModel.loadDirectories()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

//            }
//            else {
//                Text("Download a repo and it will appear here")
//                    .frame(height: 30.0)
//            }
        }
    }

    private func repoTapped(_ repo: URL) {
        let pathSuffixComps = Array(repo.pathComponents.suffix(3))
        // Handle the file tap action here
        let openRepoKey = pathSuffixComps.joined(separator: SettingsViewModel.gitKeySeparator)
        logD("select repo:  \(openRepoKey)")


        // TODO FIX FOR REPOFILE
//        if let retrievedObject = retrieveGithubContentFromDisk(forKey: openRepoKey) {
            settingsViewModel.gitUser = pathSuffixComps[0]
            settingsViewModel.gitRepo = pathSuffixComps[1]
            settingsViewModel.gitBranch = pathSuffixComps[2]
        let fileURL = getDocumentsDirectory().appendingPathComponent(settingsViewModel.gitUser).appendingPathComponent(settingsViewModel.gitRepo).appendingPathComponent(settingsViewModel.gitBranch)
        settingsViewModel.root = RepoFile(name: "Root", url: fileURL, isDirectory: true, children: getFiles(in: fileURL))

            logD("Sucessfully restored open repo")
//
//        } else {
//            logD("Failed to retrieve saved git repo...")
//        }
    }
}
