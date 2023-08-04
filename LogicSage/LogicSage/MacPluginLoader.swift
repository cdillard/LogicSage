//
//  MacPluginLoader.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/31/23.
//

import Foundation

class PluginLoader {
    static func loadPlugin(path: String) {
        let bundleFileName = "LogicSageMacPlugin.bundle"
        guard let bundleURL = Bundle.main.builtInPlugInsURL?
            .appendingPathComponent(bundleFileName) else { return }
        guard let bundle = Bundle(url: bundleURL) else { return }
        guard let catalystBundle = bundle.principalClass as? NSObject.Type else { return }

        guard let delegate = catalystBundle.init() as? Plugin else { return }
        DispatchQueue.global(qos: .default).async {
            let scriptPath = "\(path)run.sh"
            delegate.runLogicSage(scriptPath)

        }
    }
}
