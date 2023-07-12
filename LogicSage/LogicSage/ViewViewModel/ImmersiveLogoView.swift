//
//  ImmersiveView.swift
//  RecreateCrazyCoolAnimations
//
//  Created by Chris Dillard on 7/3/23.
//
#if os(xrOS)
import SwiftUI
import RealityKit
import MetalKit


struct ImmersiveLogoView: View {

    var body: some View {
        RealityView { content in

            // 3D LogicSage Logo
            let currentPosition = SIMD3<Float>(x:-0.5,y:-0.666,z:0)
            let textEntity = ModelEntity(mesh: .generateText(logoAscii6, extrusionDepth: 0.07, font: .monospacedSystemFont(ofSize: 0.06, weight: .bold)))
            let material = SimpleMaterial(color: .green, isMetallic: true)
            textEntity.model?.materials = [material]
            textEntity.position = currentPosition
            content.add(textEntity)


        }
    }
}

#endif
