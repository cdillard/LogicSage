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
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .controlPanelGuide, vertical: .bottom)) {

            RealityView { content in

                // 3D LogicSage Logo
                let currentPosition = SIMD3<Float>(x:-0.025,y:-0.666,z:0.65)
                let textEntity = ModelEntity(mesh: .generateText("___", extrusionDepth: 0.07, font: .monospacedSystemFont(ofSize: 0.02, weight: .bold)))
                let material = SimpleMaterial(color: .green, isMetallic: true)
                textEntity.model?.materials = [material]
                textEntity.position = currentPosition
                content.add(textEntity)
                textEntity.components.set(GroundingShadowComponent(castsShadow: true))


            }
            
            GlobeControls()
                .offset(y: -70)
        }
    }
}

#endif
