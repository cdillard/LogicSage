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
struct ToggleImmersion: View {
    @EnvironmentObject var appModel: AppModel

    @Binding var showImmersiveSpace: Bool

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        
        Toggle("\(showImmersiveSpace ? "Hide" : "Show") ImmersiveSpace", isOn: $showImmersiveSpace)
            .toggleStyle(.button)
            .onChange(of: showImmersiveSpace) { _, newValue in
                Task {
                    if newValue {
                        await openImmersiveSpace(id: "ImmersiveSpace")
                    } else {
                        await dismissImmersiveSpace()
                    }
                    appModel.isShowingImmersiveScene = newValue
//                    SettingsViewModel.shared.isShowingImmersiveScene = newValue

                }
            }
        
    }
}
#endif
