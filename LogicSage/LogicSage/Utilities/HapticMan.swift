//
//  HapticMan.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/21/23.
//


import Foundation
#if !os(macOS)
import UIKit
#endif
//light impatct

#if !os(macOS)
#if !os(xrOS)
#if !os(tvOS)

func playType(impType: UIImpactFeedbackGenerator.FeedbackStyle, int: CGFloat = 1.0) {
    let hasBat = checkBattery()
    guard hasBat else { return }
    guard SettingsViewModel.shared.hapticsEnabled else { return }
    
    let generator = UIImpactFeedbackGenerator(style: impType)
    generator.impactOccurred(intensity: int)
}
#endif
#endif
#endif

func playLightImpact() {
#if !os(macOS)
#if !os(xrOS)
#if !os(tvOS)

    playType(impType: .light)
#endif
#endif
#endif

}
func playSoftImpact() {
#if !os(macOS)
#if !os(xrOS)
#if !os(tvOS)

    playType(impType: .soft)
#endif
#endif
#endif

}
func playMediunImpact() {
#if !os(macOS)
#if !os(xrOS)
#if !os(tvOS)

    playType(impType: .medium)
#endif
#endif
#endif

}
func checkBattery(minBatLevl: Float = 0.3) -> Bool {
    
#if !os(macOS)
#if !os(xrOS)
#if !os(tvOS)

    UIDevice.current.isBatteryMonitoringEnabled = true
    
    guard UIDevice.current.batteryLevel > minBatLevl  || UIDevice.current.batteryLevel < 0  else {
        return false
    }
    
#endif
#endif
#endif

    return true
}
func playMessagForString(message: String) {
    if message.contains( "." ) || message.contains(","){
        playLightImpact()
    }
    else {
        playSoftImpact()
    }
}
#if !os(macOS)
#if !os(xrOS)
#if !os(tvOS)

func playNot(type: UINotificationFeedbackGenerator.FeedbackType) {
    
    let hasBat = checkBattery()
    guard hasBat else { return }
    guard SettingsViewModel.shared.hapticsEnabled else { return }
    
    let notiGen = UINotificationFeedbackGenerator()
    notiGen.notificationOccurred(type)
}
#endif
#endif
#endif


func playSelect() {
#if !os(macOS)
#if !os(xrOS)
#if !os(tvOS)

    let hasBat = checkBattery()
    guard hasBat else { return }
    guard SettingsViewModel.shared.hapticsEnabled else { return }
    
    
    let selectGen = UISelectionFeedbackGenerator()
    selectGen.selectionChanged()
#endif
#endif
#endif

}
