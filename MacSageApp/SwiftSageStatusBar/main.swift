//
//  main.swift
//  SwiftSageStatusBar
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation
import AppKit

import Cocoa
var tickCount = 0
class AppDelegate: NSObject, NSApplicationDelegate {

    // Define green colors
    let lightGreen = NSColor(calibratedRed: 0.5, green: 0.9, blue: 0.5, alpha: 1.0)
    let darkGreen = NSColor(calibratedRed: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)

    var statusItem: NSStatusItem?
    private var timer: Timer?
    func applicationDidFinishLaunching(_ notification: Notification) {
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        let coloredImage = createColoredImage(size: NSSize(width: 18, height: 18))
        statusItem?.button?.image = coloredImage

        statusItem?.button?.title = "."
        let menu = NSMenu()
        menu.addItem(withTitle: "LogicSage for Mac", action: nil, keyEquivalent: "")

        menu.addItem(withTitle: "Swifty-GPT Running (restart)", action: #selector(swiftyGptRunning), keyEquivalent: "")
        menu.addItem(withTitle: "SwiftSageServer Running (restart)", action: #selector(serverRunning), keyEquivalent: "")

        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "")
        statusItem?.menu = menu
        // we can adjust this to convey more effort occur by the toool.
        let timerInterval = 3.2
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateTitle), userInfo: nil, repeats: true)

        DistributedNotificationCenter.default().addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name(rawValue: "com.chrisswiftygpt.SwiftSage.notification"), object: nil)
    }

    @objc func handleNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let buttonTapped = userInfo["buttonTapped"] as? Bool {
            print("Button tapped: \(buttonTapped)")
        }

        if let switchChanged = userInfo["switchChanged"] as? Bool {
            print("Switch changed: \(switchChanged)")
        }
    }


    @objc func updateTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        if tickCount > 2 {
            tickCount = 0
        }

        statusItem?.button?.title = "\(String(Array(repeating: ".", count: tickCount)))"

        tickCount += 1
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }

    @objc func swiftyGptRunning() {
        print("Is Swifty GPT Running?")

    }

    @objc func serverRunning() {
        print("Is the Vapor Server Running?")

    }

    func createColoredImage(size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        // Create the bird body shape
        let bodyPath = NSBezierPath()
        bodyPath.lineWidth = 2.0
        let bodyRect = NSRect(x: size.width * 0.2, y: size.height * 0.2, width: size.width * 0.6, height: size.height * 0.6)
        bodyPath.appendOval(in: bodyRect)
        let bodyGradient = NSGradient(starting: lightGreen, ending: darkGreen)
        bodyGradient?.draw(in: bodyPath, angle: -45.0)

        // Create the bird head shape
        let headPath = NSBezierPath()
        headPath.lineWidth = 2.0
        let headRect = NSRect(x: size.width * 0.6, y: size.height * 0.57, width: size.width * 0.23, height: size.height * 0.3)
        headPath.appendOval(in: headRect)
        let headGradient = NSGradient(starting: lightGreen, ending: darkGreen)
        headGradient?.draw(in: headPath, angle: -45.0)

        // Create the bird beak shape
        let beakPath = NSBezierPath()
        beakPath.lineWidth = 1.0
        let beakTriangle = [
            NSPoint(x: size.width * 0.9, y: size.height * 0.65),
            NSPoint(x: size.width * 0.95, y: size.height * 0.6),
            NSPoint(x: size.width * 0.9, y: size.height * 0.55)
        ]
        beakPath.move(to: beakTriangle[0])
        beakPath.line(to: beakTriangle[1])
        beakPath.line(to: beakTriangle[2])
        darkGreen.setFill()
        beakPath.fill()

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
