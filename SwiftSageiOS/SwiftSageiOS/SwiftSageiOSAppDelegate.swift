//
//  SwiftSageiOSAppDelegate.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/1/23.
//

import Foundation
import UIKit
import SwiftUI
import BackgroundTasks

class SwiftSageiOSAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    static func applicationDidFinishLaunching() {
        // TODO BEFORE RELEASE: PROD BUNDLE ID
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.chrisswiftytgpt.SwiftSageiOS", using: nil) { task in
            self.handleWebSocketRefresh(task: task as! BGAppRefreshTask)
        }
    }
    static func applicationDidEnterBackground() {
        screamer.sendPing()

        scheduleWebSocketRefresh()
    }

//    func application(
//        _ application: UIApplication,
//        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
//    ) {
//
//    }

    static func handleWebSocketRefresh(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // Refresh your WebSocket connection or perform necessary actions here
        // ...
        serviceDiscovery?.startDiscovering()
        screamer.sendPing()

        // After the task is complete
        task.setTaskCompleted(success: true)
        scheduleWebSocketRefresh() // Schedule the next background task
    }

    static func scheduleWebSocketRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.chrisswiftytgpt.SwiftSageiOS")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 1) // 1 minutes from now

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule WebSocket refresh task: \(error)")
        }
    }
}
