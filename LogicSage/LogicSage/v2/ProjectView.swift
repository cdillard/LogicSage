//
//  ProjectView.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI
import Combine

struct ProjectView: View {
    
    @ObservedObject var sageMultiViewModel: SageMultiViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    var window: WindowInfo?

    let project: Project
    let openFileNames: [String] // List of open files, can be a string or a custom model
    
    @State private var dividerWidth: CGFloat = 300

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 2) {
//                    HStack {
//                        Image(systemName: "target")
//                        Text("\(settingsViewModel.targetName) ")
//                    }
//                    .onTapGesture {
//                        logD("Target tapped")
//                    }
//                    Image(systemName: "arrow.right")
//                    HStack {
//                        Image(systemName: "iphone")
//                        Text("\(settingsViewModel.deviceName)")
//                    }
//                    .onTapGesture {
//                        logD("Device tapped")
//                    }

                    Spacer()

                    Text("\(settingsViewModel.debuggingStatus)")

                    if settingsViewModel.errorCount > 0 {
                        Image(systemName: "xmark.circle.fill")
                        Text("\(settingsViewModel.errorCount)")
                    }
                    if settingsViewModel.warningCount > 0 {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("\(settingsViewModel.warningCount)")
                    }
                }
                .foregroundColor(SettingsViewModel.shared.buttonColor)
                .font(.body)
                .background(SettingsViewModel.shared.backgroundColor)
                        .frame(maxWidth: .infinity, maxHeight: 28)


                HStack(alignment: .top, spacing: 0) {
                    // Sidebar - Project Hierarchy View
                    ProjectHierarchyView(project: project)
                        .frame(width: dividerWidth, alignment: .leading)
#if !os(tvOS)

                        .background(Color(.systemGray6))
                    #endif
                }
            }

        }
        .background(SettingsViewModel.shared.backgroundColor)

        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .clipShape(RoundedBottomCorners(cornerRadius: 16))
    }
}

import SwiftUI

struct OpenFilesTabsView: View {
    let openFileNames: [String] // List of open files, can be a string or a custom model
    var body: some View {
        TabView {
            ForEach(openFileNames, id: \.self) { fileName in
                EditorView()
                    .tabItem {
                        Text(fileName)
                    }
            }
        }
    }
}
struct EditorView: View {
    var body: some View {
        Text("Example content of the selected file")
    }
}
