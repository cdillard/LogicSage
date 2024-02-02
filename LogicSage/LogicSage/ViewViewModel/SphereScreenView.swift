//
//  SphereScreenView.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/13/23.
//
#if os(visionOS)

import SwiftUI
import RealityKit

/// The model of the Sphere Screen.
struct SphereScreenView: View {

    let defaultSize: Size3D


    @State var screenConfiguration: SphereScreenEntity.Configuration = .init()
    var animateUpdates: Bool = false

    /// The Earth entity that the view creates and stores for later updates.
    @State private var screenEntity: SphereScreenEntity?
    @EnvironmentObject var appModel: AppModel

    /// A decorative entity used to highlight the corners of the volume.
    @State private var responsiveBoxCornersEntity = ResponsiveBoxCornersEntity()
    
    var body: some View {
        GeometryReader3D { geomtry in
            RealityView { content in
                let bounds = content.convert(geomtry.frame(in: .local), from: .local, to: content)

                // Create an earth entity with tilt, rotation, a moon, and so on.
                let screenEntity = await SphereScreenEntity(

                    configuration: screenConfiguration
                )
                content.add(screenEntity)

                // Decorate the corners of the volume so we can tell how large the volume is.
                responsiveBoxCornersEntity.make(with: content, for: geomtry, defaultSize: defaultSize)
                content.add(responsiveBoxCornersEntity)

                // Store for later updates.
                self.screenEntity = screenEntity

            } update: { content in
                // Reconfigure everything when any configuration changes.
                screenEntity?.update(
                    configuration: screenConfiguration,
                    animateUpdates: animateUpdates)

                responsiveBoxCornersEntity.update(with: content, for: geomtry)

            }
            .onAppear {
                screenConfiguration.isHoverEffectEnabled = appModel.isRotating || appModel.isTranslating
            }
        }
    }
}
#endif
