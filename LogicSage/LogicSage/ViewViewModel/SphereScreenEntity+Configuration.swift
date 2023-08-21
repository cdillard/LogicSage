//
//  SphereScreenEntity+Configuration.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/13/23.
//
#if os(xrOS)

import SwiftUI

extension SphereScreenEntity {
    /// Configuration information for SphereScreenEntity entities.
    struct Configuration {
        var isCloudy: Bool = false

        var scale: Float = 0.6
        var rotation: simd_quatf = .init(angle: 0, axis: [0, 1, 0])
        var speed: Float = 0
        var position: SIMD3<Float> = .zero

        static var screenDefault: Configuration = .init(
            scale: 1.0
        )
    }
}
#endif
