//
//  Orbit.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/13/23.
//
#if os(xrOS)

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

        .placementGestures(initialPosition: Point3D([0,1.9,1.2]))
//        .dragRotation(yawLimit: .degrees(20), pitchLimit: .degrees(20))
    }
}


#endif
