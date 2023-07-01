//
//  BGHandler.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/1/23.
//

import Foundation
import BackgroundTasks

func scheduleWebSocketRefresh() {
    
#if !os(macOS)
    
    let request = BGAppRefreshTaskRequest(identifier: "\(bundleID)bger")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 2)
    
    do {
        try BGTaskScheduler.shared.submit(request)
    } catch {
        logD("Could not schedule WebSocket refresh task: \(error)")
    }
    
#endif
    
}
