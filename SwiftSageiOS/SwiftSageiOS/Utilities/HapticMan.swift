//
//  HapticMan.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/21/23.
//


import Foundation
#if !os(macOS)
import UIKit
#endif
//light impatct

#if !os(macOS)

func playType(impType: UIImpactFeedbackGenerator.FeedbackStyle, int: CGFloat = 1.0) {
    let hasBat = checkBattery()
    guard hasBat else { return }
    guard SettingsViewModel.shared.hapticsEnabled else { return }

    let generator = UIImpactFeedbackGenerator(style: impType)
    generator.impactOccurred(intensity: int)
}
#endif

func playLightImpact() {
#if !os(macOS)

    playType(impType: .light)
    #endif
}
func playSoftImpact() {
#if !os(macOS)

    playType(impType: .soft)
    #endif
}
func playMediunImpact() {
#if !os(macOS)

    playType(impType: .medium)
#endif
}
func checkBattery(minBatLevl: Float = 0.3) -> Bool {

#if !os(macOS)

    UIDevice.current.isBatteryMonitoringEnabled = true

    guard UIDevice.current.batteryLevel > minBatLevl  || UIDevice.current.batteryLevel < 0  else {
        logD("no haptics when no battery :think: ;)")
        return false
    }

    if UIDevice.current.batteryLevel < 0 {
        logD("battery undeter")
    }
#endif
    return true
}


#if !os(macOS)

func playNot(type: UINotificationFeedbackGenerator.FeedbackType) {

    let hasBat = checkBattery()
    guard hasBat else { return }
    guard SettingsViewModel.shared.hapticsEnabled else { return }

    let notiGen = UINotificationFeedbackGenerator()
    notiGen.notificationOccurred(type)
}
#endif


func playSelect() {
#if !os(macOS)

    let hasBat = checkBattery()
    guard hasBat else { return }
    guard SettingsViewModel.shared.hapticsEnabled else { return }

    
    let selectGen = UISelectionFeedbackGenerator()
    selectGen.selectionChanged()
#endif
}
