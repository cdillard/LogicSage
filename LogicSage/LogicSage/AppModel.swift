//
//  AppModel.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/11/23.
//

import SwiftUI

class AppModel: ObservableObject {
#if os(visionOS)
    var screen: SphereScreenEntity.Configuration = .screenDefault
#endif
    @Published var isTranslating: Bool = true {
        didSet {
            if isTranslating {
                isRotating = false
            }
        }
    }
    @Published var isRotating: Bool = false {
        didSet {
            if isRotating  {
                isTranslating = false
            }
        }
    }

    @Published var isShowingImmersiveWindow: Bool = false
    @Published var isShowingImmersiveScene: Bool = false
    @Published var isShowingImmersiveLogo: Bool = false

    @AppStorage("savedSphereX") var savedSphereX: Double = -1000.0
    @AppStorage("savedSphereY") var savedSphereY: Double = -2000.0
    @AppStorage("savedSphereZ") var savedSphereZ: Double = -2000.0
    @AppStorage("savedSphereScale") var savedSphereScale: Double = 1.0

    /// Resets game state information.
    func reset() {

    }
    
    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        Task { @MainActor in

        }
    }
}
