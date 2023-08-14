//
//  SphereScreenView.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/13/23.
//
#if os(xrOS)

import SwiftUI
import RealityKit

/// The model of the Earth.
struct SphereScreenView: View {
    var screenConfiguration: SphereScreenEntity.Configuration = .init()
    var animateUpdates: Bool = false

    /// The Earth entity that the view creates and stores for later updates.
    @State private var screenEntity: SphereScreenEntity?

    var body: some View {
        RealityView { content in
            // Create an earth entity with tilt, rotation, a moon, and so on.
            let screenEntity = await SphereScreenEntity(
                configuration: screenConfiguration
            )
            content.add(screenEntity)

            // Store for later updates.
            self.screenEntity = screenEntity

        } update: { content in
            // Reconfigure everything when any configuration changes.
            screenEntity?.update(
                configuration: screenConfiguration,
//                satelliteConfiguration: satelliteConfiguration,
//                moonConfiguration: moonConfiguration,
                animateUpdates: animateUpdates)
        }
    }
}
#endif
