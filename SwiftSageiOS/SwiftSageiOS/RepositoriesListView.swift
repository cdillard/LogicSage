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
            List(directories, id: \.self) { directory in
                Text(directory.pathComponents.suffix(3).joined(separator: "/"))
                    .font(.title3)
                    .lineLimit(nil)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .onTapGesture {
                        repoTapped(directory)
                    }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

            .onChange(of: settingsViewModel.isLoading) { _ in
                directories = settingsViewModel.loadDirectories()

            }
            .onAppear {
                directories = settingsViewModel.loadDirectories()
            }

        }
    }



     private func repoTapped(_ repo: URL) {
         let pathSuffixComps = Array(repo.pathComponents.suffix(3))
         // Handle the file tap action here
         let openRepoKey = pathSuffixComps.joined(separator: "/")
         logD("select repo:  \(openRepoKey)")

         if let retrievedObject = retrieveGithubContentFromUserDefaults(forKey: openRepoKey) {
             settingsViewModel.gitUser = pathSuffixComps[0]
             settingsViewModel.gitRepo = pathSuffixComps[1]
             settingsViewModel.gitBranch = pathSuffixComps[2]
             settingsViewModel.rootFiles = retrievedObject.compactMap { $0 }
             print("Sucessfully restored open repo w/ rootFile count = \(settingsViewModel.rootFiles.count)")

         } else {
             print("Failed to retrieve saved git repo...")
         }
     }
 }
