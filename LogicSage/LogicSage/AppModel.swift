//
//  AppModel.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/11/23.
//

import SwiftUI

class AppModel: ObservableObject {

    @Published var isShowingImmersiveWindow: Bool = false
    @Published var isShowingImmersiveScene: Bool = false
    @Published var isShowingImmersiveLogo: Bool = false

    @Published var isPlaying = false
    @Published var isPaused = false {
        didSet {
            if isPaused == true {

            } else {

            }
        }
    }
    
    @Published var readyToStart = false
    

    @Published var isSharePlaying = false
    @Published var isSpatial = false
    
    @Published var isFinished = false {
        didSet {
            if isFinished == true {

            }
        }
    }
    
    @Published var isSoloReady = false {
        didSet {
            if isPlaying == true {

            }
        }
    }

    @Published var isMuted = false {
        didSet {
            if isMuted == true {
            } else {
            }
        }
    }
    @Published var isInputSelected = false
    @Published var inputKind: InputKind = .hands

    @Published var isUsingControllerInput = false
    @Published var controllerX: Float = 0
    @Published var controllerY: Float = 90.0
    @Published var controllerInputX: Float = 0
    @Published var controllerInputY: Float = 0
    @Published var controllerLastInput = Date.timeIntervalSinceReferenceDate

    /// Resets game state information.
    func reset() {
        isPlaying = false
        isPaused = false
        isSharePlaying = false
        isFinished = false
        isSoloReady = false

        isInputSelected = false
        inputKind = .hands

        isUsingControllerInput = false
        controllerX = 0
        controllerY = 90.0

    }
    
    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        Task { @MainActor in

            self.readyToStart = true
        }
    }
}

/// The kinds of input selections offered to players.
enum InputKind {
    /// An input method that uses ARKit to detect a heart gesture.
    case hands
    
    /// An input method that spawns a stationary heart projector.
    case alternative
}
