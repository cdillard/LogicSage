//
//  TopBar.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/6/23.
//

import Foundation
import SwiftUI

struct TopBar: View {
    @Binding var isEditing: Bool
    var onClose: () -> Void
    @State var windowInfo: WindowInfo

    var body: some View {
        HStack {

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.body)
            }
            .foregroundColor(SettingsViewModel.shared.buttonColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)


            Spacer()
            if windowInfo.windowType == .file {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .font(.body)
                }
                .foregroundColor(SettingsViewModel.shared.buttonColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

        }

        .background(SettingsViewModel.shared.backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: 30)
    }
}
