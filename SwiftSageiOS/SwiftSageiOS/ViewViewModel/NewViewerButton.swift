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
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        Button("New App Window") {
            openWindow(id: "LogicSage-main")
        }
    }
}
