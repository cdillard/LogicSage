//
//  Backend.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/12/23.
//

import SwiftUI

class Backend {
    static func doBackend(path: String) {
#if targetEnvironment(macCatalyst)
        // The LogicSage for Mac app handles starting the server and MacOS Binary.
        Task {
                PluginLoader.loadPlugin(path: path)
        }
#endif
    }
}
