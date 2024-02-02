//
//  DragRotationModifier.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/17/23.
//
#if os(visionOS)

import SwiftUI
import RealityKit

extension View {
    /// Enables people to drag an entity to rotate it, with optional limitations
    /// on the rotation in yaw and pitch.
    func dragRotation2(
        yawLimit: Angle? = nil,
        pitchLimit: Angle? = nil,
        sensitivity: Double = 1,
        axRotateClockwise: Bool = false,
        axRotateCounterClockwise: Bool = false
    ) -> some View {
        self.modifier(
            DragRotationModifier(
                yawLimit: yawLimit,
                pitchLimit: pitchLimit,
                sensitivity: sensitivity,
                axRotateClockwise: axRotateClockwise,
                axRotateCounterClockwise: axRotateCounterClockwise
            )
        )
    }
}

/// A modifier converts drag gestures into entity rotation.
private struct DragRotationModifier: ViewModifier {
    var yawLimit: Angle?
    var pitchLimit: Angle?
    var sensitivity: Double
    var axRotateClockwise: Bool
    var axRotateCounterClockwise: Bool

    @State private var baseYaw: Double = 0
    @State private var yaw: Double = 0
    @State private var basePitch: Double = 0
    @State private var pitch: Double = 0


    @EnvironmentObject var appModel: AppModel

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.radians(yaw == 0 ? 0.01 : yaw), axis: .y)
            .rotation3DEffect(.radians(pitch == 0 ? 0.01 : pitch), axis: .x)
            .gesture(DragGesture(minimumDistance: 0.0)
                .targetedToAnyEntity()
                .onChanged { value in
                    // Find the current linear displacement.
                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let delta = (location3D - startLocation3D) / 5

                    // Use an interactive spring animation that becomes
                    // a spring animation when the gesture ends below.
                    withAnimation {
                        yaw = spin(displacement: Double(delta.x), base: baseYaw, limit: yawLimit)
                        pitch = spin(displacement: Double(delta.y), base: basePitch, limit: pitchLimit)


                    }


                }
                .onEnded { value in
//                    // Find the current and predicted final linear displacements.
////                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
////                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
////                    let predictedEndLocation3D = value.convert(value.predictedEndLocation3D, from: .local, to: .scene)
////                    let delta = location3D - startLocation3D
////                    let predictedDelta = predictedEndLocation3D - location3D
//
////                    // Set the final spin value using a spring animation.
////                    withAnimation(.spring) {
////
////                        yaw = finalSpin(
////                            displacement: Double(delta.x),
////                            predictedDisplacement: Double(predictedDelta.x),
////                            base: baseYaw,
////                            limit: yawLimit)
////
////                        pitch = finalSpin(
////                            displacement: Double(delta.y),
////                            predictedDisplacement: Double(predictedDelta.y),
////                            base: basePitch,
////                            limit: pitchLimit)
////                        Task {
////                            appModel.savedSphereYaw = yaw
////
////                            appModel.savedSpherePitch = pitch
////                        }
////                    }
//                    Task {
//                        // Store the last value for use by the next gesture.
//                        appModel.savedSphereBaseYaw = yaw
//                        appModel.savedSphereBasePitch = pitch
//                    }

                    Task {
                        await MainActor.run {
                            baseYaw = yaw
                            basePitch = pitch
                            // Store the last value for use by the next gesture.
                            appModel.savedSphereYaw = yaw
                            appModel.savedSpherePitch = pitch

                            appModel.savedSphereBaseYaw = yaw
                            appModel.savedSphereBasePitch = pitch
                        }
                    }
                }
            )
            .onAppear {
                yaw = appModel.savedSphereYaw
                pitch = appModel.savedSpherePitch
                baseYaw = appModel.savedSphereBaseYaw
                basePitch = appModel.savedSphereBasePitch
            }
    }

    /// Finds the spin for the specified linear displacement, subject to an
    /// optional limit.
    private func spin(
        displacement: Double,
        base: Double,
        limit: Angle?
    ) -> Double {
        let reversedDisplacement = -displacement // Reversing the direction
//        if let limit {
//            return atan(reversedDisplacement * sensitivity) * (limit.degrees / 90)
//        } else {
            return base + reversedDisplacement * sensitivity
  //      }
    }

    /// Finds the final spin given the current and predicted final linear
    /// displacements, or zero when the spin is restricted.
    private func finalSpin(
        displacement: Double,
        predictedDisplacement: Double,
        base: Double,
        limit: Angle?
    ) -> Double {
        // If there is a spin limit, always return to zero spin at the end.
        guard limit == nil else { return 0 }

        // Find the projected final linear displacement, capped at 1 more revolution.
       // let cap = .pi * 2.0 / sensitivity
        let delta = displacement //+ max(-cap, min(cap, predictedDisplacement))

        // Find the final spin.
        return base + delta * sensitivity
    }
}
#endif
