//
//  PlacementGestureModifier.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/11/23.
//
#if os(visionOS)

import SwiftUI
import RealityKit

let minScale = 0.1

let maxScale = 10.0

extension View {
    /// Listens for gestures and places an item based on those inputs.
    func placementGestures(
        initialPosition: Point3D = .zero

    ) -> some View {
        self.modifier(
            PlacementGesturesModifier(
                initialPosition: initialPosition
            )
        )
    }
}

/// A modifier that adds gestures and positioning to a view.
private struct PlacementGesturesModifier: ViewModifier {
    var initialPosition: Point3D

   // @State private var scale: Double = 1
    @State private var startScale: Double? = nil
    @State private var position: Point3D = .zero
    @State private var startPosition: Point3D? = nil
    @EnvironmentObject var appModel: AppModel

    func body(content: Content) -> some View {
        content
            .onAppear {
                position = initialPosition
            }
            .rotation3DEffect(.radians(appModel.savedSphereBaseYaw == 0 ? 0.01 : appModel.savedSphereBaseYaw), axis: .y)
            .rotation3DEffect(.radians(appModel.savedSphereBasePitch == 0 ? 0.01 : appModel.savedSphereBasePitch), axis: .x)
            .scaleEffect(appModel.savedSphereScale)
            .position(x: position.x, y: position.y)
            .offset(z: position.z)
            .if(appModel.isTranslating) { view in
                    view.simultaneousGesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .global)
                        .targetedToAnyEntity()
                        .onChanged { value in
                            if let startPosition {
                                let delta = value.location3D - value.startLocation3D
                                position = startPosition + delta
                                Task {
                                    appModel.savedSphereX = position.x
                                    appModel.savedSphereY = position.y
                                    appModel.savedSphereZ = position.z
                                }
                                //                        print("new pos = \(position)")
                            } else {
                                startPosition = position
                            }
                        }
                        .onEnded { _ in
                            startPosition = nil
                        }
                                             
                    )
            }
            .if(appModel.isTranslating) { view in
                    view.simultaneousGesture(MagnifyGesture()
                        .targetedToAnyEntity()
                        .onChanged { value in
                            if let startScale {
                                Task {
                                    appModel.savedSphereScale = max(minScale, min(maxScale, value.magnification * startScale))
                                }

                            } else {
                                startScale = appModel.savedSphereScale
                            }
                        }
                        .onEnded { value in
                            startScale = appModel.savedSphereScale
                        }
                    )
            }
    }
}
#endif
