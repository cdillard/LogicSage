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
    @ObservedObject private var eventManager = GlobalEventManager.shared

    @Published var isTranslating: Bool = false {
        didSet {
            if isTranslating {
                isRotating = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in

                self?.eventManager.frameUpdate = true
                self?.eventManager.eventOccurred = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in

                    self?.eventManager.frameUpdate = true
                    self?.eventManager.eventOccurred = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in

                        self?.eventManager.frameUpdate = true
                        self?.eventManager.eventOccurred = true

                    }
                }
            }
        }
    }
    @Published var isRotating: Bool = false {
        didSet {
            if isRotating  {
                isTranslating = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in

                self?.eventManager.frameUpdate = true
                self?.eventManager.eventOccurred = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in

                    self?.eventManager.frameUpdate = true
                    self?.eventManager.eventOccurred = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in

                        self?.eventManager.frameUpdate = true
                        self?.eventManager.eventOccurred = true

                    }
                }
            }
        }
    }

    @Published var isShowingImmersiveWindow: Bool = false
    @Published var isShowingImmersiveScene: Bool = false
    @Published var isShowingImmersiveLogo: Bool = false {
        didSet {
            if isShowingImmersiveLogo {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    
                    self?.eventManager.frameUpdate = true
                    self?.eventManager.eventOccurred = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                        
                        self?.eventManager.frameUpdate = true
                        self?.eventManager.eventOccurred = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                            
                            self?.eventManager.frameUpdate = true
                            self?.eventManager.eventOccurred = true
                            
                        }
                    }
                }
            }
        }
    }

    @AppStorage("savedSphereX") var savedSphereX: Double = 1446.4983825683594
    @AppStorage("savedSphereY") var savedSphereY: Double = 1904.7749328613281
    @AppStorage("savedSphereZ") var savedSphereZ: Double = 695.5230407714844
    @AppStorage("savedSphereScale") var savedSphereScale: Double = 0.77

    @AppStorage("savedSphereYaw") var savedSphereYaw: Double = 0.0
    @AppStorage("savedSphereBaseYaw") var savedSphereBaseYaw: Double = 0.0

    @AppStorage("savedSpherePitch") var savedSpherePitch: Double = 0.0
    @AppStorage("savedSphereBasePitch") var savedSphereBasePitch: Double = 0.0


    /// Resets game state information.
    func reset() {

    }
    
    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        Task {  @MainActor [weak self] in
#if os(visionOS)

            await SphereScreenEntity.preloadResources()
            #endif
        }
    }
}
