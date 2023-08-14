//
//  SphereScreenEntity.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/11/23.
//
#if os(xrOS)

import Foundation
import RealityKit
import SwiftUI
import SwiftUI
import MetalKit

class SphereScreenEntity: Entity {

    private let screen: Entity

    @MainActor required init() {
        screen = Entity()
        super.init()
    }

    init(
        configuration: Configuration
    ) async {
        do { // Load assets.


            let mesh = MeshResource.generateTwoSidedSphere(radius: 1.0)

            var material2 = SimpleMaterial()


            if let color =  try? PhysicallyBasedMaterial.BaseColor
                .init(tint: .white.withAlphaComponent(matAlphaComponent)) {
                material2.color = color
            }

            let modelEntity = ModelEntity(mesh: mesh, materials: [material2])
            //                                let shape = ShapeResource.generateSphere(radius: 1)
            //                                modelEntity.addCollision(shape: shape)
            //                modelEntity.generateCollisionShapes(recursive: true)
            modelEntity.generateCollisionShapes(recursive: true)
            modelEntity.components.set(InputTargetComponent())
            modelEntity.collision?.mode = .trigger


            // DO OR DO NOT RORATE DEPENDING ON VOLUMETRIC
            let rotationRadians = Float(-90.0) * .pi / 180 // 45 degrees converted to radians.
            modelEntity.transform.rotation = simd_quatf(angle: rotationRadians, axis: SIMD3(x:0,y:1,z:0))//.degrees(43)

            screen = modelEntity

            Timer.scheduledTimer(withTimeInterval: texUpdateInteral, repeats: true) { _ in
                DispatchQueue.main.async {
                    Task {
                        var material2 = SimpleMaterial()
                        if let image = UIImage(data: lastTextureImageData ?? Data())?.cgImage {
                            // FIX HUGE WINDOW WIDTH ISSUE L
                            // -[MTLTextureDescriptorInternal validateWithDevice:]:1354: failed assertion `Texture Descriptor Validation
                            // MTLTextureDescriptor has width (8357) greater than the maximum allowed size of 8192.
                            let txtContent =  try await TextureResource.generate(from: image, options: .init(semantic: .normal))

                            if let color =  try? PhysicallyBasedMaterial.BaseColor
                                .init(tint: .white.withAlphaComponent(matAlphaComponent),
                                      texture: .init(txtContent)) {
                                material2.color = color
                            }

                            for i in await 0..<(modelEntity.model?.materials.count ?? 0) {
                                modelEntity.model?.materials[i] = material2
                            }
                        }
                    }
                }
            }

            super.init()

            self.addChild(screen)

            // Configure everything for the first time.
            update(
                configuration: configuration,
                animateUpdates: false)
        }
    }
    func update(
        configuration: Configuration,
        animateUpdates: Bool
    ) {
        self.updateTransform(
            scale: SIMD3(repeating: configuration.scale),
            translation: configuration.position,
            withAnimation: animateUpdates)
    }
}

#endif
