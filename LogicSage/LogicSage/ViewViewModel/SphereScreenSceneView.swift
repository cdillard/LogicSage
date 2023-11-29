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


    var body: some View {
        
        SphereScreenView(
            screenConfiguration: appModel.screen
        )
        .placementGestures(initialPosition: Point3D([appModel.savedSphereX,appModel.savedSphereY,appModel.savedSphereZ]))
        .if(appModel.isRotating) { view in
            view.dragRotation(yawLimit: .degrees(20), pitchLimit: .degrees(20))

        }
    }
}


#endif
