//
//  MacSageAppApp.swift
//  MacSageApp
//
//  Created by Chris Dillard on 4/22/23.
//

import SwiftUI

@main
struct MacSageAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    executeStatusBar()
                }
        }
    }
}

func executeStatusBar() {
    do {
        let task = Process()
        let extPath = commandLineToolExecutablePath
        let url = URL(fileURLWithPath: extPath)
        task.executableURL = url
        try task.run()
        task.waitUntilExit()
    }
    catch {
        print("error status bar e=\(error)")
    }


}
