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
    private let maxDepth = 3
    var body: some View {
        GeometryReader { geometry in
                List(directories, id: \.self) { directory in
                    Text(directory.pathComponents.suffix(3).joined(separator: "/"))
                        .font(.body)
                        .lineLimit(nil)
                        .fontWeight(.bold)
                        .onTapGesture {
                            repoTapped(directory)
                        }
                }
                .onAppear(perform: loadDirectories)

        }
    }
    private func loadDirectories() {
          let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

          do {
              try listDirectories(at: documentsDirectory, depth: 1)
          } catch {
              print("Error loading directories: \(error)")
          }
      }

    private func listDirectories(at url: URL, depth: Int) throws {
        guard depth <= maxDepth else { return }

        let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)

        for content in directoryContents {
            let resourceValues = try content.resourceValues(forKeys: Set([URLResourceKey.isDirectoryKey]))
            let isDirectory = resourceValues.isDirectory ?? false
            if isDirectory {
                if depth == 3 {
                    directories.append(content)
                }
                try listDirectories(at: content, depth: depth + 1)
            }
        }
    }


     private func repoTapped(_ repo: URL) {
         let pathSuffixComps = Array(repo.pathComponents.suffix(3))
         // Handle the file tap action here
         let openRepoKey = pathSuffixComps.joined(separator: "/")
         logD("Should select repoKey = \(openRepoKey)")


         if let retrievedObject = retrieveGithubContentFromUserDefaults(forKey: openRepoKey) {
             settingsViewModel.gitUser = pathSuffixComps[0]
             settingsViewModel.gitRepo = pathSuffixComps[1]
             settingsViewModel.gitBranch = pathSuffixComps[2]
             settingsViewModel.rootFiles = retrievedObject.compactMap { $0 }

             print("Sucessfully restored open repo w/ rootFile count = \(settingsViewModel.rootFiles.count)")

         } else {
             print("Failed to retrieve saved git repo...")
         }
         // set settingsViewModel.rootFiles to the looked up repo contents from UserDefaults
     }
 }
