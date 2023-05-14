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
    @State var webViewURL: URL?
    @EnvironmentObject var windowManager: WindowManager

    var body: some View {
        HStack {

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.body)
            }
            .foregroundColor(SettingsViewModel.shared.buttonColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.leading, SettingsViewModel.shared.cornerHandleSize)


            Spacer()

            if windowInfo.windowType == .file ||
               windowInfo.windowType == .webView {

                Text(getName())
                    .font(.body)
                    .lineLimit(1)

                    .foregroundColor(SettingsViewModel.shared.buttonColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
                .padding(.trailing, 8)
            }

        }
        .onTapGesture {
            self.windowManager.bringWindowToFront(window: self.windowInfo)
        }
        .background(SettingsViewModel.shared.backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: 30)
    }
    func getName() -> String {
        if windowInfo.windowType == .file {
            return "\(windowInfo.file?.name ?? "Filename")"
        }
        else {
            return  "\(webViewURL?.absoluteString ?? "WebView")"

        }
    }
}
