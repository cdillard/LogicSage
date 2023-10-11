//
//  SageMultiView+onDrag.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/2/23.
//

import Foundation
import SwiftUI
#if !os(macOS)

import UIKit
#endif
import Combine

#if !os(tvOS)

extension SageMultiView {
    // WARNING: This code isn't great.
    func dragsOnChange(value: DragGesture.Value?, _ interactive: Bool = true) {
      //  if !isDragDisabled {
            if !isMoveGestureActivated {
                if interactive {
                    self.windowManager.bringWindowToFront(window: self.window)
                    isMoveGestureActivated = true
                }
            }
            func doPostConstraint(vertical: Bool = false) {
                let now = Date()
                if now.timeIntervalSince(self.lastBumpFeedbackTime) >= 0.666 {
#if !os(xrOS)
#if !os(macOS)
                    playNot(type: .warning)
#endif
#endif
                    lastBumpFeedbackTime = Date()
                }
                if vertical {
                    bumpingVertically = true
                }
                else {
                    bumping = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + dragDelay) {
                    if vertical {
                        bumpingVertically = false
                    }
                    else {
                        bumping = false
                    }
                }
            }
            let widthTrans = value?.translation.width ?? 0
            let heightTrans = value?.translation.height ?? 0

            var newX = position.width + widthTrans
            var newY = position.height + heightTrans
// START: Handle Three LEADING edge cases....
            if resizeOffset.width == 0 {
                let globX = newX
                if  globX > 0 {
                }
                else {
                    //logD("constrain x becuz LEADING = \(globX) < \(0)!")
                    newX = 0
                    doPostConstraint()
                }
            }
            // if resizeOffset.width > 0 that means window has been icnreased in size horiz
            else if resizeOffset.width > 0 {
                let globX = newX - resizeOffset.width / 2
                if  globX > 0 {
                }
                else {
                    //logD("constrain x becuz LEADING = \(globX) < \(0)!")
                    newX = 0 +  resizeOffset.width / 2
                    doPostConstraint()
                }
            }
            // if resizeOffset.width < 0 that means window has been decreased in size horiz
            else if resizeOffset.width < 0 {
                let globX = newX + abs(resizeOffset.width / 2)
                if  globX > 0 - abs(resizeOffset.width / 2) {
                }
                else {
                   // logD("constrain x becuz LEADING = \(globX) < \(0)!")
                    newX = 0 - abs(resizeOffset.width) / 2
                    doPostConstraint()
                }
            }
// END: Three LEADING edge cases....

// START: Three TRAILING edge cases....
            if resizeOffset.width == 0 {
                let globX = newX

                let trailing = globX + frame.size.width
                let farBound = viewSize.size.width
                if trailing > farBound {
                    //logD("constrain x becuz TRAILING = \(trailing) > \(farBound)!")
                    newX = farBound - frame.size.width
                    doPostConstraint()
                }
            }
            // if resizeOffset.width > 0 that means window has been increased in size horiz.
            else if resizeOffset.width > 0 {
                let globX = newX

                let trailing = globX + frame.size.width - (resizeOffset.width / 2)

                let farBound = viewSize.width  + (resizeOffset.width / 2)

                if trailing > farBound {
                    //logD("constrain x becuz TRAILING = \(trailing) > \(farBound)!")
                    newX = farBound - frame.size.width
                    doPostConstraint()
                }
            }
            // if resizeOffset.width < 0 that means window has been decreased in size horiz.
            else if resizeOffset.width < 0 {
                let globX = newX
                let trailing = globX  + frame.size.width - (abs(resizeOffset.width) / 2)
                let farBound = viewSize.width  - (abs(resizeOffset.width))

                if trailing > farBound {
                    //logD("constrain x becuz TRAILING = \(trailing) > \(farBound)!")
                    newX = farBound - frame.size.width + abs(resizeOffset.width) / 2
                    doPostConstraint()
                }
            }
// END: Three TRAILING edge cases....

// START: Three TOP edge cases....
            if resizeOffset.height == 0 {
                let topset: CGFloat = 0

                let globY = newY
                if globY > topset {
                }
                else {
                    //logD("constrain y becuz TOP = \(globY) < \(topset)!")
                    newY = topset
                    doPostConstraint(vertical: true)
                }
            }
            // if resizeOffset.height > 0 that means window has been increased in size vert.
            else if resizeOffset.height > 0 {
                let topset: CGFloat = -(abs(resizeOffset.height) / 2)
                let globY = newY - (resizeOffset.height / 2)
                if globY > topset {
                }
                else {
                 //   logD("constrain y becuz TOP = \(globY) < \(topset)!")
                    newY = topset + (abs(resizeOffset.height) / 2)
                    doPostConstraint(vertical: true)
                }
            }
            // if resizeOffset.height < 0 that means window has been decreased in size vert.
            else if resizeOffset.height < 0 {
                let topset: CGFloat = 0

                let globY = newY + (abs(resizeOffset.height) / 2)
                if globY > topset {
                }
                else {
                 //   logD("constrain y becuz TOP = \(globY) < \(topset)!")
                    newY = topset - (abs(resizeOffset.height) / 2)
                    doPostConstraint(vertical: true)
                }
            }
// END: Three TOP edge cases....

// START: Three BOTTOM edge cases....
            if resizeOffset.height == 0 {
                let globY = newY

                // Handle BOTTOM
                let bottom = globY + frame.size.height
                let farBound = viewSize.height
                if bottom > farBound {
                    //logD("constrain y becuz BOTTOM = \(globY) < \(topset)!")
                    newY = farBound - frame.size.height
                    doPostConstraint(vertical: true)
                }
            }
            // if resizeOffset.height > 0 that means window has been increased in size vert.
            else if resizeOffset.height > 0 {
                let globY = newY

                let trailing = globY + frame.size.height - (resizeOffset.height / 2)

                let farBound = viewSize.height + (resizeOffset.height / 2)

                if trailing > farBound {
                    //logD("constrain x becuz BOTOM = \(trailing) > \(farBound)!")
                    newY = farBound - frame.size.height
                    doPostConstraint(vertical: true)
                }
            }
            // if resizeOffset.height < 0 that means window has been decreased in size vert.
            else if resizeOffset.height < 0 {
                let globY = newY
                let trailing = globY  + frame.size.height
                let farBound = viewSize.height - (abs(resizeOffset.height) / 2)

                if trailing > farBound {
                    //logD("constrain x becuz TRAILING = \(trailing) > \(farBound)!")
                    newY = farBound - frame.size.height
                    doPostConstraint(vertical: true)
                }
            }
// END: Three BOTTOM edge cases....
            var leadingXBound: CGFloat = 0
            var topYBound: CGFloat = 10

            if resizeOffset.width < 0 {
                leadingXBound = -abs(resizeOffset.width / 2)
            }
            else if resizeOffset.width > 0 {
                leadingXBound = resizeOffset.width / 2
            }

            if resizeOffset.height < 0 {
                topYBound = -abs(resizeOffset.height / 2)
            }
            else if resizeOffset.height > 0 {
                topYBound = -(resizeOffset.height / 2)
            }
            else {

            }
            let setX = max(leadingXBound, newX)
            let setY = max(topYBound, position.height + heightTrans)
           // print("setting pos to \(setX) and \(setY)")

#if os(macOS)
            let newX2 = position.width + widthTrans
            let newY2 = position.height + heightTrans
            position = CGSize(width:newX2,height:newY2)
#else
            position = CGSize(width:setX,height:setY)
#endif
        }
    //}
}
#endif
