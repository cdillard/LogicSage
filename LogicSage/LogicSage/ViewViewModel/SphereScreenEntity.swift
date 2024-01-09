//
//  SphereScreenEntity.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/11/23.
//
#if os(visionOS)

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

            let angleIncrement = -0.422 * Float.pi * 2
            let phiStart: Float = 0.422 * Float.pi * 2
            let phiEnd = phiStart + angleIncrement


            let wedgeMeshPair = Self.generateWedge(radius: 1.0, phiStart: phiStart, phiEnd: phiEnd, innerRadius: 0.95)

            // Usage:
            let angle = -Float.pi / 4  // Rotate by 45 degrees
            let rotatedVertices = Self.rotateVerticesAroundZAxis(vertices: wedgeMeshPair.0, angle: angle)
            let rotatedIndices = Self.rotateIndices(indices: wedgeMeshPair.1)  // Indices remain the same

            let angle2 = -Float.pi / 2  // Rotate by 45 degrees
            let rotatedVertices2 = Self.rotateVerticesAroundXAxis(vertices: rotatedVertices, angle: angle2)
            let rotatedIndices2 = Self.rotateIndices(indices: rotatedIndices)  // Indices remain the same

            let shape = try await ShapeResource.generateStaticMesh(positions: rotatedVertices2, faceIndices: rotatedIndices2)

            modelEntity.addCollision(shape: shape)
            modelEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
            modelEntity.collision?.mode = .trigger
//            modelEntity.transform.rotation = simd_quatf(angle: -rotationRadiansCol, axis: SIMD3(x:0,y:1,z:0))

            let rotationRadians = Float(-90.0) * .pi / 180 // 45 degrees converted to radians.
            modelEntity.transform.rotation = simd_quatf(angle: rotationRadians, axis: SIMD3(x:0,y:1,z:0))//.degrees(43)

            screen = modelEntity
            modelEntity.components.set(GroundingShadowComponent(castsShadow: true))
            modelEntity.components.set(HoverEffectComponent())

            super.init()

            Timer.scheduledTimer(withTimeInterval: texUpdateInteral, repeats: true) { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    Task { [weak self] in
                        var material2 = SimpleMaterial()
                        if let image = UIImage(data: lastTextureImageData ?? Data())?.cgImage {
                            // tip: MTLTextureDescriptor has width greater than the maximum allowed size of 8192 will fail.
                            if image.height < 8192 && image.width < 8192 {

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
                            else {
                                logD("image size exceeds 3D texture (MTLTextureDescriptor) limit")
                            }

                        }
                    }
                }
            }

            self.addChild(screen)

            // Configure everything for the first time.
            update(
                configuration: configuration,
                animateUpdates: false)
        }
        catch {
            screen = Entity()

            super.init()

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

    
    static func generateWedge(radius: Float, phiStart: Float, phiEnd: Float, innerRadius: Float) -> ([SIMD3<Float>], [UInt16]) {
        var vertices: [SIMD3<Float>] = []
        var indices: [UInt16] = []

        let thetaIncrement: Float = Float.pi / 20  // Adjust to change resolution
        let phiIncrement: Float = (phiEnd - phiStart) / 15// Adjust to change resolution
        let thetaStart: Float = thetaIncrement * 5  // Start from an offset to remove the "top"
        let thetaEnd: Float = Float.pi - thetaIncrement * 5 // End before reaching the "bottom"

        // Generate vertices for outer surface
        for theta in stride(from: thetaStart, to: thetaEnd, by: thetaIncrement) {
            for phi in stride(from: phiStart, to: phiEnd, by: phiIncrement) {
                let xOuter = -radius * sin(theta) * cos(phi)
                let yOuter = radius * sin(theta) * sin(phi)
                let zOuter = -radius * cos(theta)
                vertices.append(SIMD3<Float>(xOuter, yOuter, zOuter))
            }
        }

        // Generate vertices for inner surface
        for theta in stride(from: thetaStart, to: thetaEnd, by: thetaIncrement) {
            for phi in stride(from: phiStart, to: phiEnd, by: phiIncrement) {
                let xInner = -innerRadius * sin(theta) * cos(phi)
                let yInner = innerRadius * sin(theta) * sin(phi)
                let zInner = -innerRadius * cos(theta)
                vertices.append(SIMD3<Float>(xInner, yInner, zInner))
            }
        }

        // Update the logic to compute indices based on the new vertex arrangement
        let m = Int((phiEnd - phiStart) / phiIncrement) + 1  // Number of vertices per row
        let n = vertices.count / (2 * m)  // Outer and inner surfaces

        func indexForRowAndColumn(row: Int, col: Int, offset: Int) -> UInt16 {
            return UInt16(offset + row * m + col)
        }

        // Compute indices for outer surface
        let outerOffset = 0
        for row in 0..<(n - 2) {  // Skip the last row of vertices
            for col in 0..<(m - 2) {  // Skip the last column of vertices
                let bottomLeft = indexForRowAndColumn(row: row, col: col, offset: outerOffset)
                let bottomRight = bottomLeft + 1
                let topLeft = bottomLeft + UInt16(m)
                let topRight = topLeft + 1

                indices.append(contentsOf: [bottomLeft, topLeft, topRight])
                indices.append(contentsOf: [bottomLeft, topRight, bottomRight])
            }
        }

        // Compute indices for inner surface
        let innerOffset = n * m
        for row in 0..<(n - 2) {  // Skip the last row of vertices
            for col in 0..<(m - 2) {  // Skip the last column of vertices
                let bottomLeft = indexForRowAndColumn(row: row, col: col, offset: innerOffset)
                let bottomRight = bottomLeft + 1
                let topLeft = bottomLeft + UInt16(m)
                let topRight = topLeft + 1

                indices.append(contentsOf: [bottomLeft, topLeft, topRight])
                indices.append(contentsOf: [bottomLeft, topRight, bottomRight])
            }
        }


        return (vertices, indices)
    }

    static func rotateVerticesAroundZAxis(vertices: [SIMD3<Float>], angle: Float) -> [SIMD3<Float>] {
        var rotatedVertices: [SIMD3<Float>] = []

        let rotationMatrix = float3x3([
            [cos(angle), -sin(angle), 0],
            [sin(angle), cos(angle), 0],
            [0, 0, 1]
        ])

        for vertex in vertices {
            let rotatedVertex = rotationMatrix * vertex
            rotatedVertices.append(rotatedVertex)
        }

        return rotatedVertices
    }

    static func rotateVerticesAroundXAxis(vertices: [SIMD3<Float>], angle: Float) -> [SIMD3<Float>] {
        var rotatedVertices: [SIMD3<Float>] = []

        let rotationMatrix = float3x3([
            [1, 0, 0],
            [0, cos(angle), -sin(angle)],
            [0, sin(angle), cos(angle)]
        ])

        for vertex in vertices {
            let rotatedVertex = rotationMatrix * vertex
            rotatedVertices.append(rotatedVertex)
        }

        return rotatedVertices
    }

    static func rotateIndices(indices: [UInt16]) -> [UInt16] {
        // The indices don't change when vertices are rotated
        return indices
    }
}

#endif
