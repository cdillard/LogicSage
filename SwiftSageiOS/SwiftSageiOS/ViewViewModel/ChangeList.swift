//
//  WindowList.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/7/23.
//

import Foundation
import SwiftUI

#if !os(macOS)

struct ChangeList: View {
    @EnvironmentObject var windowManager: WindowManager
    @Binding var showAddView: Bool
    @ObservedObject var sageMultiViewModel: SageMultiViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
//        if !changes.isEmpty {
            List {
                ForEach(settingsViewModel.changes) { change in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("- \(change.oldLine ?? "")")
                                .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                                .foregroundColor(.red)
                            Text("+ \(change.newLine ?? "")")
                                .font(.system(size: settingsViewModel.fontSizeSrcEditor))
                                .foregroundColor(.green)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .listRowBackground(settingsViewModel.backgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear
        {
            logD("Change list wit count = \(settingsViewModel.changes)")

        }
//        }
//        else {
//            Text("Have changes and they will appear here...")
//                .frame(height: 30.0)
//                .foregroundColor(SettingsViewModel.shared.appTextColor)
//        }
    }
}
#endif
