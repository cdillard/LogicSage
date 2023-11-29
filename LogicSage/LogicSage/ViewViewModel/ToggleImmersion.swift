//
//  ToggleImmersion.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/3/23.
//


#if os(visionOS)
import SwiftUI
import RealityKit
@available(visionOS 1.0, *)
struct ToggleImmersion: View {
    @EnvironmentObject var appModel: AppModel

    @Binding var showImmersiveSpace: Bool

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {

        Toggle( isOn: $showImmersiveSpace) {
            VStack {
                Image(systemName: "circle.dashed")
                Text("SphereScreen")
                    .font(.caption)
            }
        }
            .toggleStyle(.button)
            .onChange(of: showImmersiveSpace) { _, newValue in
                Task {
                    if newValue {
                        await openImmersiveSpace(id: "ImmersiveSpace")
                    } else {
                        await dismissImmersiveSpace()
                    }
                    appModel.isShowingImmersiveScene = newValue
                }
            }


    }
}
#endif
