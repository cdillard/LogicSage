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

let texUpdateInteral: TimeInterval = 0.57
let matAlphaComponent = 0.9999

var lastTextureImageData: Data?

public extension MeshResource {
    // call this to create a 2-sided mesh that will then be displayed
    func addingInvertedNormals() throws -> MeshResource {
        return try MeshResource.generate(from: contents.addingInvertedNormals())
    }

    // call this on a mesh that is already displayed to make it 2 sided
    func addInvertedNormals() throws {
        try replace(with: contents.addingInvertedNormals())
    }
    static func generateTwoSidedSphere(radius: Float = 0) -> MeshResource {
        let sphere = generateSphere(radius: radius)
        let twoSided = try? sphere.addingInvertedNormals()
        return twoSided ?? sphere
    }
}

public extension MeshResource.Contents {
    func addingInvertedNormals() -> MeshResource.Contents {
        var newContents = self

        newContents.models = .init(models.map { $0.addingInvertedNormals() })

        return newContents
    }
}

public extension MeshResource.Model {
    func partsWithNormalsInverted() -> [MeshResource.Part] {
        return parts.map { $0.normalsInverted() }.compactMap { $0 }
    }

    func addingParts(additionalParts: [MeshResource.Part]) -> MeshResource.Model {
        // CULL FRONT FACES BY NOT INCLUIND ORIIGNAL PARTS?
        let newParts = //parts.map { $0 } +
        additionalParts

        var newModel = self
        newModel.parts = .init(newParts)

        return newModel
    }

    func addingInvertedNormals() -> MeshResource.Model {
        return addingParts(additionalParts: partsWithNormalsInverted())
    }
}

public extension MeshResource.Part {
    func normalsInverted() -> MeshResource.Part? {
        if let normals, let triangleIndices {
            let newNormals = normals.map { $0 * -1.0 }
            var newPart = self


            newPart.normals = .init(newNormals)

            // ordering of points in the triangles must be reversed,
            // or the inversion of the normal has no effect
            newPart.triangleIndices = .init(triangleIndices.reversed())

            var newTxt = [SIMD2<Float>]()
            if let textCoords = textureCoordinates {
                for coord in textCoords {
                    newTxt += [SIMD2(x: 1 - coord.x, y:  coord.y)]
                }
            }

            newPart.textureCoordinates = .init(newTxt)

            // id must be unique, or others with that id will be discarded
            newPart.id = id + " with inverted normals"
            return newPart
        } else {
            print("No normals to invert, returning nil")
            return nil
        }
    }
}

extension ModelEntity {
    func addCollision(shape: ShapeResource) {
        self.collision = CollisionComponent(shapes: [shape])
    }
}
#endif
