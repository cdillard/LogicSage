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
    var statusItem: NSStatusItem?
    private var timer: Timer?
    func applicationDidFinishLaunching(_ notification: Notification) {
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        let coloredImage = createColoredImage(color: .green, size: NSSize(width: 18, height: 18))
        statusItem?.button?.image = coloredImage

        statusItem?.button?.title = "."
        let menu = NSMenu()
        menu.addItem(withTitle: "✨SwiftSage🧠💥", action: #selector(doNothing), keyEquivalent: "")

        let switchMenuItem = NSMenuItem(title: "Toggle Switch", action: #selector(toggleSwitch(_:)), keyEquivalent: "")
        switchMenuItem.state = .off
        menu.addItem(switchMenuItem)


        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
        statusItem?.menu = menu
        // we can adjust this to convey more effort occur by the toool.
        let timerInterval = 3.2
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateTitle), userInfo: nil, repeats: true)

        DistributedNotificationCenter.default().addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name(rawValue: "com.example.yourapp.notification"), object: nil)
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
//          let currentTime = dateFormatter.string(from: Date())

        if tickCount > 2 {
            tickCount = 0
        }

        statusItem?.button?.title = "\(String(Array(repeating: ".", count: tickCount)))"

        tickCount += 1
      }

    @objc func quit() {
        NSApp.terminate(nil)
    }

    @objc func doNothing() {

    }

    

    @objc func toggleSwitch(_ sender: NSMenuItem) {
        if sender.state == .on {
            sender.state = .off
        } else {
            sender.state = .on
        }
        // Perform any additional actions based on the state of the switch
    }

    func createColoredImage(color: NSColor, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        // Set the color
        color.setStroke()

        // Create the S shape using NSBezierPath
        let sPath = NSBezierPath()
        sPath.lineWidth = 0.2 // Adjust the line width as needed

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
