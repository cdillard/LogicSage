//
//  ToggleImmersion.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/3/23.
//

#if os(xrOS)

import SwiftUI
import RealityKit
@available(xrOS 1.0, *)
struct ToggleImmersiveButton: View {
    @EnvironmentObject var appModel: AppModel

    let idOfView: String
    let name: String
    
    @Binding var showImmersiveLogo: Bool

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
#if os(xrOS)

    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
#endif

    var body: some View {
        
        Toggle("\(showImmersiveLogo ? "Hide" : "Show") \(name)", isOn: $showImmersiveLogo)
            .toggleStyle(.button)
            .onChange(of: showImmersiveLogo) { _, newValue in
                Task {
                    if newValue {
                        openWindow(id: idOfView)
                    } else {
                        dismissWindow(id: idOfView)
                    }
                    if idOfView == "ImmersiveSpaceVolume" {
                        appModel.isShowingImmersiveWindow = newValue

                    }
                    else if idOfView == "LogoVolume" {
                        appModel.isShowingImmersiveLogo = newValue

                    }
                }
            }
    }
}
#endif
