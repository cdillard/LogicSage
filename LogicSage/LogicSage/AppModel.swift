//
//  AppModel.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/11/23.
//

import SwiftUI

class AppModel: ObservableObject {
#if os(xrOS)
    var screen: SphereScreenEntity.Configuration = .screenDefault
#endif


    @Published var isShowingImmersiveWindow: Bool = false
    @Published var isShowingImmersiveScene: Bool = false
    @Published var isShowingImmersiveLogo: Bool = false

    /// Resets game state information.
    func reset() {

    }
    
    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        Task { @MainActor in

        }
    }
}
