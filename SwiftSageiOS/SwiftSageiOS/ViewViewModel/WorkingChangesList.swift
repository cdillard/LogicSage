//
//  WorkingChangesList.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/14/23.
//

import Foundation
import SwiftUI

struct FileChange: Identifiable, Equatable {

    var id = UUID()
    var fileURL: URL
    var status: String
    var lineChanges: [ChangeRow]

    var newFileContents: String
}
let unstagedTitle =  "Unstaged Changes"
let stagedTitle = "Staged Changes"
struct WorkingChangesView: View {

    @EnvironmentObject var windowManager: WindowManager
    @Binding var showAddView: Bool
    @ObservedObject var sageMultiViewModel: SageMultiViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel


    var body: some View {
        NavigationView {
            VStack {
                ListSectionView(title: unstagedTitle, changes: $settingsViewModel.unstagedFileChanges, settingsViewModel: settingsViewModel)
                Divider()
                ListSectionView(title: stagedTitle, changes: $settingsViewModel.stagedFileChanges, settingsViewModel: settingsViewModel)
            }
        }
#if !os(macOS)
        .navigationViewStyle(StackNavigationViewStyle())
#endif
    }
}

struct ListSectionView: View {
    var title: String
    @Binding var changes: [FileChange]
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                .foregroundColor(settingsViewModel.appTextColor)
                .padding(.leading, 15)
                .padding(.top, 5)

            List {
                ForEach(changes) { change in
                    HStack {
                        Text(change.fileURL.pathComponents.suffix(3).joined(separator: "/"))
                            .font(.system(size: settingsViewModel.fontSizeSrcEditor))

                            .foregroundColor(settingsViewModel.appTextColor)
                            .onTapGesture {
                                // swap from palce to place if tapped
                                if title == unstagedTitle {
                                    settingsViewModel.unstagedFileChanges.removeAll {
                                        $0 == change
                                    }
                                    settingsViewModel.stagedFileChanges.append(change)
                                }
                                else if title == stagedTitle {
                                    settingsViewModel.stagedFileChanges.removeAll {
                                        $0 == change
                                    }
                                    settingsViewModel.unstagedFileChanges.append(change)
                                }
                            }

                        Spacer()
                        Text(change.status)
                            .font(.system(size: settingsViewModel.fontSizeSrcEditor))

                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}
