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
        menu.addItem(withTitle: "✨SwiftSage🧠💥", action: #selector(doNothing), keyEquivalent: "")

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

        // Set the color
        color.setStroke()

        // Create the S shape using NSBezierPath
        let sPath = NSBezierPath()
        sPath.lineWidth = 2.0 // Adjust the line width as needed

        // Define points for the S shape
        let p1 = NSPoint(x: size.width * 0.2, y: size.height * 0.8)
        let p2 = NSPoint(x: size.width * 0.8, y: size.height * 0.8)
        let p3 = NSPoint(x: size.width * 0.2, y: size.height * 0.5)
        let p4 = NSPoint(x: size.width * 0.8, y: size.height * 0.5)
        let p5 = NSPoint(x: size.width * 0.2, y: size.height * 0.2)
        let p6 = NSPoint(x: size.width * 0.8, y: size.height * 0.2)

        // Draw the S shape
        sPath.move(to: p1)
        sPath.curve(to: p3, controlPoint1: p2, controlPoint2: p2)
        sPath.curve(to: p5, controlPoint1: p4, controlPoint2: p4)
        sPath.line(to: p6)

        // Stroke the path
        sPath.stroke()

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
