//
//  LogicSageiOSApp+UserDefaults.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/1/23.
//

import Foundation

func setHasSeenInstructions(_ hasSeen: Bool) {
    UserDefaults.standard.set(hasSeen, forKey: "hasSeenInstructions")
}
func hasSeenInstructions() -> Bool {
#if os(tvOS)
    return true
#else
    return UserDefaults.standard.bool(forKey: "hasSeenInstructions")
#endif
}
func setHasSeenLogo(_ hasSeen: Bool) {
    UserDefaults.standard.set(hasSeen, forKey: "hasSeenLogo")
}
func hasSeenLogo() -> Bool {
    return UserDefaults.standard.bool(forKey: "hasSeenLogo")
}
func hasSeenAnim() -> Bool {
    return UserDefaults.standard.bool(forKey: "hasSeenAnim")
}
func setHasSeenAnim(_ hasSeen: Bool) {
    UserDefaults.standard.set(hasSeen, forKey: "hasSeenAnim")
}
