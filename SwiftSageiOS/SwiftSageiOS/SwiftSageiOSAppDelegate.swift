//
//  SwiftSageiOSAppDelegate.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/1/23.
//
#if !os(macOS)
import Foundation
import UIKit
import SwiftUI
import BackgroundTasks

class SwiftSageiOSAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    static func applicationDidFinishLaunching() {
       // logD("applicationDidFinishLaunching starts")
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "\(bundleID)bger", using: nil) { task in
//            self.handleWebSocketRefresh(task: task as! BGAppRefreshTask)
//        }
//
//        logD("applicationDidFinishLaunching ends")

    }
//    static func applicationDidEnterBackground() {
//        logD("applicationDidEnterBG starts")
//
//        screamer.sendPing()
//
//  //      scheduleWebSocketRefresh()
//
//        logD("applicationDidEnterBG ends")
//
//    }

//    static func handleWebSocketRefresh(task: BGAppRefreshTask) {
//        task.expirationHandler = {
//            task.setTaskCompleted(success: false)
//        }
//
//        serviceDiscovery?.startDiscovering()
//        screamer.connect()
//        screamer.sendPing()
//
//        // After the task is complete
//        task.setTaskCompleted(success: true)
//        scheduleWebSocketRefresh() // Schedule the next background task
//    }

//    static func scheduleWebSocketRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: "\(bundleID)bger")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 2) // 1 minutes from now
//
//        do {
//            logD("scheduleWebSocketRefresh attempt")
//
//            try BGTaskScheduler.shared.submit(request)
//            logD("scheduleWebSocketRefresh success")
//
//        } catch {
//            logD("Could not schedule WebSocket refresh task: \(error)")
//        }
//    }
}
#endif
