//
//  NewViewerButton.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/24/23.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct NewViewerButton: View {
#if !os(tvOS)

    @Environment(\.openWindow) private var openWindow
#endif
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {

        Button(action: {
#if !os(tvOS)
            openWindow(id: "LogicSage-main")
#endif
        }) {
            VStack(spacing: 0)  {

               Image(systemName: "plus.rectangle.fill")
                .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                .lineLimit(1)
                
                Text("Add Window")
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.01)
            }
#if !os(xrOS)

            .background(settingsViewModel.buttonColor)
#endif
        }
        .buttonStyle(MyButtonStyle())
    }
}

