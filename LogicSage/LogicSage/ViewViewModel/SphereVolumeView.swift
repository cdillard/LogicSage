//
//  SphereVolumeView.swift
//  LogicSage
//
//  Created by Chris Dillard on 1/31/24.
//
#if os(visionOS)

import SwiftUI
import RealityKit

struct SphereVolumeContentView: View {

    /// The value passed to the volumetric window group's `defaultSize(_:in:)` view modifier.
    let defaultSize: Size3D

    /// A root entity added to the `RealityView`.
    ///
    /// This entity is automatically scaled to reflect changes to the user's selected
    /// Window Zoom setting.
    @State private var scaledRootEntity = Entity()

    /// A decorative entity used to highlight the corners of the volume.
    @State private var responsiveBoxCornersEntity = ResponsiveBoxCornersEntity()
    @EnvironmentObject var appModel: AppModel
    @State var screenConfiguration: SphereScreenEntity.Configuration = .init()
    @State private var attachmentsProvider = AttachmentsProvider()
    var animateUpdates: Bool = false
    @State private var screenEntity: SphereScreenEntity?

    var body: some View {

        ZStack(alignment: Alignment(horizontal: .controlPanelGuide, vertical: .bottom)) {

            GlobeControls(settingsViewModel: SettingsViewModel.shared)
                .offset(y: -70)
                .offset(z: appModel.savedSphereZ + 100.0)


            GeometryReader3D { proxy in
                RealityView { content in

                    content.add(scaledRootEntity)

                    // Scale the volume's content to reflect the initial Window Zoom setting.
                    scale(entity: scaledRootEntity, with: content, for: proxy, defaultSize: defaultSize)

                    if let existingEntity = screenEntity {
                        scaledRootEntity.removeChild(existingEntity)
                    }
                    // Create an earth entity with tilt, rotation, a moon, and so on.
                    let screenEntity = SphereScreenEntity(configuration: screenConfiguration)
                    scaledRootEntity.addChild(screenEntity)
                    self.screenEntity = screenEntity

                    // Decorate the corners of the volume so we can tell how large the volume is.
                    //                responsiveBoxCornersEntity.make(with: content, for: proxy, defaultSize: defaultSize)
                    //                content.add(responsiveBoxCornersEntity)

                } update: { content in //, attachments in

                    scale(entity: scaledRootEntity, with: content, for: proxy, defaultSize: defaultSize)

                    screenEntity?.update(
                        configuration: screenConfiguration,
                        animateUpdates: animateUpdates)


                    //             responsiveBoxCornersEntity.update(with: content, for: proxy)
                }
            }
            .alignmentGuide(.controlPanelGuide) { context in
                context[HorizontalAlignment.center]
            }
            .if(appModel.isRotating) { view in
                view.dragRotation2(
                    sensitivity: 0.75)
            }
            .placementGestures(initialPosition: Point3D([appModel.savedSphereX,appModel.savedSphereY,appModel.savedSphereZ]))
        }
    }

    func scale(entity: Entity, with content: RealityViewContent, for proxy: GeometryProxy3D, defaultSize: Size3D) {
        let scaledVolumeSize = content.convert(proxy.frame(in: .local), from: .local, to: .scene)

        let scale = (scaledVolumeSize.extents/SIMD3<Float>(defaultSize)).min()

        entity.scale = .one*scale
    }
}

#endif
