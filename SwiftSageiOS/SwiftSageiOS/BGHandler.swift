//
//  BGHandler.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/1/23.
//

import Foundation
import BackgroundTasks

func scheduleWebSocketRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.example.app.websocketrefresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 1) // 1 minute from now

    do {
        try BGTaskScheduler.shared.submit(request)
    } catch {
        print("Could not schedule WebSocket refresh task: \(error)")
    }
}
