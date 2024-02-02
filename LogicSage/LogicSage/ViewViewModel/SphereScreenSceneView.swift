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
    let defaultSize: Size3D

    @EnvironmentObject var appModel: AppModel

    @State var axRotateClockwise: Bool = false
    @State var axRotateCounterClockwise: Bool = false
    @Binding var isImmersive: Bool

    var body: some View {
        SphereScreenView(
            defaultSize: defaultSize, screenConfiguration: appModel.screen
        )
        .if(appModel.isRotating) { view in
            view.dragRotation2(
               // pitchLimit: .degrees(90),
                sensitivity: 0.75)
//                axRotateClockwise: axRotateClockwise,
//                axRotateCounterClockwise: axRotateCounterClockwise)
        }
       // .if(isImmersive) { view in
        .placementGestures(initialPosition: Point3D([806.6176452636719,  858.8736877441406,  698.0616149902344]))
       // }
//        .if(!isImmersive) { view in
//            view.placementGestures(initialPosition: Point3D([0.0,0.0,0.0]))
//
//        }
    }
}


#endif
