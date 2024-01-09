//
//  Orbit.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/13/23.
//
#if os(visionOS)

import Foundation
import SwiftUI
import RealityKit

/// The model content for the orbit module.
struct SphereScreenSceneView: View {
    @EnvironmentObject var appModel: AppModel

    @State var axRotateClockwise: Bool = false
    @State var axRotateCounterClockwise: Bool = false

    var body: some View {
        SphereScreenView(
            screenConfiguration: appModel.screen
        )
        .if(appModel.isRotating) { view in
            view.dragRotation(
                //pitchLimit: .degrees(90),
                axRotateClockwise: axRotateClockwise,
                axRotateCounterClockwise: axRotateCounterClockwise)


        }
        .placementGestures(initialPosition: Point3D([appModel.savedSphereX,appModel.savedSphereY,appModel.savedSphereZ]))
    }
}


#endif
