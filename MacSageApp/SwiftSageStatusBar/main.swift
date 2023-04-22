//
//  main.swift
//  SwiftSageStatusBar
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation
import AppKit

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        let coloredImage = createColoredImage(color: .green, size: NSSize(width: 18, height: 18))
        statusItem?.button?.image = coloredImage

        let menu = NSMenu()
        menu.addItem(withTitle: "SwiftSage", action: #selector(doNothing), keyEquivalent: "")

        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
        statusItem?.menu = menu
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }

    @objc func doNothing() {

    }

    func createColoredImage(color: NSColor, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        NSBezierPath.fill(NSRect(origin: .zero, size: size))
        image.unlockFocus()
        return image
    }
}

autoreleasepool {
    let app = NSApplication.shared
    let appDelegate = AppDelegate()
    app.delegate = appDelegate
    app.setActivationPolicy(.accessory)
    app.run()
}
