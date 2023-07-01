//
//  NewViewerButton.swift
//  SwiftSageiOS
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

    var body: some View {
        Button("New App Window") {
#if !os(tvOS)

            openWindow(id: "LogicSage-main")
            #endif
        }
    }
}
