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

let texUpdateInteral: TimeInterval = 0.7
let matAlphaComponent = 0.9999

var lastTextureImageData: Data?

enum ImmersionMode {
    case immersive
    case volumetric

}

struct ImmersiveView: View {
    var immersionMode: ImmersionMode

    var body: some View {
        RealityView { content in

            content.add(spaceOrigin)
            content.add(cameraAnchor)

            // Spherical 3D Screen
            let mesh = MeshResource.generateTwoSidedSphere(radius: 1.0)

            do {
                var material2 = SimpleMaterial()


                if let color =  try? PhysicallyBasedMaterial.BaseColor
                    .init(tint: .white.withAlphaComponent(matAlphaComponent)) {
                    material2.color = color
                }

                let modelEntity = ModelEntity(mesh: mesh, materials: [material2])

                // In immersive
                if immersionMode == .immersive {
                     modelEntity.position = SIMD3(0,1.65,0.5)
                }
                // In volumerictric window mode
///                modelEntity.position = SIMD3(0,0,0)
                else if immersionMode == .volumetric {
                    modelEntity.position = SIMD3(0,-0.30666,0.2)

                }


                // DO OR DO NOT RORATE DEPENDING ON VOLUMETRIC
                let rotationRadians = Float(-90.0) * .pi / 180 // 45 degrees converted to radians.
                modelEntity.transform.rotation = simd_quatf(angle: rotationRadians, axis: SIMD3(x:0,y:1,z:0))//.degrees(43)

                spaceOrigin.addChild(modelEntity)

                // Handle curved texture update
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
                // End handling curved texture update
            }
            catch {
                print("Failed to create texture from image: \(error)")

            }
        }
    }
}

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
//    static func generateTwoSidedBox(width: Float, height: Float, depth: Float, cornerRadius: Float = 0, splitFaces: Bool = false) -> MeshResource {
//        let box = generateBox(width: width, height: height, depth: depth, cornerRadius: cornerRadius, splitFaces: splitFaces)
//        //  let plane = generatePlane(width: width, depth: depth, cornerRadius: cornerRadius)
//        let twoSided = try? box.addingInvertedNormals()
//        return twoSided ?? box
//    }
    //    static func generateTwoSidedPlane(width: Float, depth: Float, cornerRadius: Float = 0) -> MeshResource {
    //        let plane = generatePlane(width: width, depth: depth, cornerRadius: cornerRadius)
    //        let twoSided = try? plane.addingInvertedNormals()
    //        return twoSided ?? plane
    //    }
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
#endif
