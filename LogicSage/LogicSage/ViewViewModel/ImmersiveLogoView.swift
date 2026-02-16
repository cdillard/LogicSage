//
//  ImmersiveView.swift
//  RecreateCrazyCoolAnimations
//
//  Created by Chris Dillard on 7/3/23.
//
#if os(visionOS)
import SwiftUI
import RealityKit
import MetalKit

struct ImmersiveLogoView: View {
    let defaultSize: Size3D

    @EnvironmentObject var appModel: AppModel
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .controlPanelGuide, vertical: .bottom)) {

            SphereScreenView(
                defaultSize: defaultSize, screenConfiguration: appModel.screen
            )
            .if(appModel.isRotating) { view in
                view.dragRotation2(
                   // pitchLimit: .degrees(90),
                    sensitivity: 0.75)
//                    axRotateClockwise: axRotateClockwise,
//                    axRotateCounterClockwise: axRotateCounterClockwise)
            }
            .placementGestures(initialPosition: Point3D(x: Double(appModel.savedSphereX), y: Double(appModel.savedSphereY), z: Double(appModel.savedSphereZ)))
//            .position(x: position.x, y: position.y)
//            RealityView { content in
//                let currentPosition = SIMD3<Float>(x:-0.025,y:-0.333,z:0.33)
//                let textEntity = ModelEntity(mesh: .generateText("", extrusionDepth: 0.07, font: .monospacedSystemFont(ofSize: 0.02, weight: .bold)))
//                let material = SimpleMaterial(color: .green, isMetallic: true)
//                textEntity.model?.materials = [material]
//                textEntity.position = currentPosition
//                content.add(textEntity)
//                textEntity.components.set(GroundingShadowComponent(castsShadow: true))
//            }
//            .offset(y: -200)

            GlobeControls(settingsViewModel: settingsViewModel)
                .offset(y: -70)

        }
        .alignmentGuide(.controlPanelGuide) { context in
            context[HorizontalAlignment.center]
        }

    }
}

#endif

