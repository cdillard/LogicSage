//
//  WorkingChangesList.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/14/23.
//

import Foundation
import SwiftUI
#if !os(macOS)

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
    @Binding var showAddView: Bool
    @ObservedObject var sageMultiViewModel: SageMultiViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State private var isPresentingAlert: Bool = false
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    NavigationView {
                        VStack {
                            ListSectionView(showAddView: $showAddView, sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel, title: unstagedTitle, changes: $settingsViewModel.unstagedFileChanges)
                            Divider()
                            ListSectionView(showAddView: $showAddView, sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel, title: stagedTitle, changes: $settingsViewModel.stagedFileChanges)
                        }
                    }
#if !os(macOS)
                    .navigationViewStyle(StackNavigationViewStyle())
#endif
                    Divider()

                    NavigationView {
                        ChangeList(showAddView: $showAddView, sageMultiViewModel: sageMultiViewModel, settingsViewModel: settingsViewModel)
                    }
#if !os(macOS)
                    .navigationViewStyle(StackNavigationViewStyle())
#endif
                }
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            logD("Confirm ?? Create PR on \(settingsViewModel.currentGitRepoKey().replacingOccurrences(of: SettingsViewModel.gitKeySeparator, with: "/"))")
                            isPresentingAlert = true
                        }
                    }) {
                        HStack {
                            Text("Push Draft PR...")
                                .font(.subheadline)
                                .foregroundColor(settingsViewModel.appTextColor)
                                .padding(.bottom)

                            resizableButtonImage(systemName:
                                                    "square.and.pencil",
                                                 size: geometry.size)
                            .fontWeight(.bold)
                            .cornerRadius(8)
                        }

                    }
                    .disabled(settingsViewModel.stagedFileChanges.isEmpty)
                    .padding(.trailing, 16)
                }
                .confirmationDialog("Are you sure you want to create a PR on \(settingsViewModel.gitRepo)?", isPresented: $isPresentingAlert) {
                      Button("Yes") {
                          settingsViewModel.actualCreateDraftPR { success in
                              logD("success when creating pr = \(success)")

                          }
                      }

                      Button("Cancel", role: .cancel) { }
                  } message: {
                      Text("Are you sure you want to create a PR on \(settingsViewModel.gitRepo)?")
                  }

            }
        }
    }
    func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
            .tint(settingsViewModel.appTextColor)
            .background(settingsViewModel.buttonColor)
    }
}

struct ListSectionView: View {

    @EnvironmentObject var windowManager: WindowManager
    @Binding var showAddView: Bool

    @ObservedObject var sageMultiViewModel: SageMultiViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel

    var title: String
    @Binding var changes: [FileChange]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                    .foregroundColor(settingsViewModel.appTextColor)
                    .padding(.leading, 15)
                    .padding(.top, 5)
            }
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
#endif
