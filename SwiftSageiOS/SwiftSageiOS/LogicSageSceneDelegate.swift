//
//  LogicSageSceneDelegate.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 6/24/23.
//

import Foundation
import SwiftUI

#if !os(macOS)
class LogicSageSceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneWillEnterForeground(_ scene: UIScene) {
        logD("sceneWillEnterForeground")
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        logD("sceneDidBecomeActive")
    }
    func sceneWillResignActive(_ scene: UIScene) {
        logD("sceneWillResignActive")
    }
}
#endif
