//
//  ProjectView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import SwiftUI
import Combine

struct ProjectView: View {
#if !os(macOS)
#if !os(xrOS)

    @ObservedObject var sageMultiViewModel: SageMultiViewModel
#endif
#endif

    @ObservedObject var settingsViewModel: SettingsViewModel
    var window: WindowInfo?

    var body: some View {
        HStack(spacing: 2) {
            HStack {
                Image(systemName: "target")
                Text("\(settingsViewModel.targetName) ")
            }
            .onTapGesture {
                logD("Target tapped")
            }
            Image(systemName: "arrow.right")
            HStack {
                Image(systemName: "iphone")
                Text("\(settingsViewModel.deviceName)")
            }
            .onTapGesture {
                logD("Device tapped")
            }
            
            Spacer()

            // This view shouls say....
            // INITIAL STATE:
            // Build succeeded | Today at 8:04 AM
            // AFter running a target debug
            // Finished running
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
    }
}
