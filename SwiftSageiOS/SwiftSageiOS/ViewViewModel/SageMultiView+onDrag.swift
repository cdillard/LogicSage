//
//  SageMultiView+onDrag.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 6/2/23.
//

import Foundation
import SwiftUI
#if !os(macOS)
import UIKit
import WebKit
import Combine

extension SageMultiView {
    func dragsOnChange(value: DragGesture.Value, geometrySafeAreaInsetLeading: CGFloat, geometrySafeAreaTop: CGFloat) {
        if !isDragDisabled {
            if !isMoveGestureActivated {
                self.windowManager.bringWindowToFront(window: self.window)
                isMoveGestureActivated = true
            }
            func doPostConstraint() {
                playNot(type: .warning)
                //isDragDisabled = true
                bumping = true
                DispatchQueue.main.asyncAfter(deadline: .now() + dragDelay) {
                    // isDragDisabled = false
                    bumping = false
                }
            }
            let fudge: CGFloat = 33.666

            var newX = position.width + value.translation.width
            var newY = position.height + value.translation.height
// START: Handle Three LEADING edge cases....
            if resizeOffset.width == 0 {
                let globX = newX + initialViewFrame.origin.x
                if  globX > geometrySafeAreaInsetLeading {
                }
                else {
                   // logD("constrain x becuz LEADING = \(globX) < \(geometrySafeAreaInsetLeading)!")
                    newX = geometrySafeAreaInsetLeading - initialViewFrame.origin.x
                    doPostConstraint()
                }
            }
            // if resizeOffset.width > 0 that means window has been icnreased in size horiz
            else if resizeOffset.width > 0 {
                let globX = newX + initialViewFrame.origin.x - resizeOffset.width / 2
                if  globX > geometrySafeAreaInsetLeading {
                }
                else {
                 //   logD("constrain x becuz LEADING = \(globX) < \(geometrySafeAreaInsetLeading)!")
                    newX = geometrySafeAreaInsetLeading - initialViewFrame.origin.x +  resizeOffset.width / 2
                    doPostConstraint()
                }
            }
            // if resizeOffset.width < 0 that means window has been decreased in size horiz
            else if resizeOffset.width < 0 {
                let globX = newX + initialViewFrame.origin.x + abs(resizeOffset.width / 2)

                if  globX > geometrySafeAreaInsetLeading {
                }
                else {
               //     logD("constrain x becuz LEADING = \(globX) < \(geometrySafeAreaInsetLeading)!")
                    newX = geometrySafeAreaInsetLeading - initialViewFrame.origin.x - abs(resizeOffset.width)  / 2
                    doPostConstraint()
                }
            }
// END: Three LEADING edge cases....

// START: Three TRAILING edge cases....
            if resizeOffset.width == 0 {
                let globX = newX

                let trailing = globX + frame.size.width

                let farBound = viewSize.size.width + initialViewFrame.origin.x  + geometrySafeAreaInsetLeading

                if trailing > farBound {
                //    logD("constrain x becuz TRAILING = \(trailing) > \(farBound)!")
                    newX = farBound - frame.size.width - fudge
                    doPostConstraint()
                }
            }
            // if resizeOffset.width > 0 that means window has been increased in size horiz.
            else if resizeOffset.width > 0 {
                let globX = newX + initialViewFrame.origin.x

                let trailing = globX + frame.size.width - (resizeOffset.width / 2)

                let farBound = viewSize.width + initialViewFrame.origin.x + geometrySafeAreaInsetLeading + (resizeOffset.width / 2)

                if trailing > farBound {
                 //   logD("constrain x becuz TRAILING = \(trailing) > \(farBound)!")
                    newX = farBound - frame.size.width  - fudge
                    doPostConstraint()
                }
            }
            // if resizeOffset.width < 0 that means window has been decreased in size horiz.
            else if resizeOffset.width < 0 {
                let globX = newX + initialViewFrame.origin.x
                let trailing = globX  + frame.size.width - (abs(resizeOffset.width) / 2)
                let farBound = viewSize.width + initialViewFrame.origin.x + geometrySafeAreaInsetLeading - (abs(resizeOffset.width))

                if trailing > farBound {
             //       logD("constrain x becuz TRAILING = \(trailing) > \(farBound)!")
                    newX = farBound - frame.size.width + abs(resizeOffset.width) / 2 - fudge
                    doPostConstraint()
                }
            }
// END: Three TRAILING edge cases....

// START: Three TOP edge cases....
            let topset = geometrySafeAreaTop + fudge
            if resizeOffset.height == 0 {
                let globY = newY + initialViewFrame.origin.y

                if globY > topset {
                }
                else {
//                    logD("constrain y becuz TOP = \(globY) < \(topset)!")

                    newY = topset
                    doPostConstraint()
                }
            }
            // if resizeOffset.height > 0 that means window has been increased in size vert.
            else if resizeOffset.height > 0 {
                // Handle TOP
                let globY = newY + initialViewFrame.origin.y - resizeOffset.height / 2
                if globY > topset {
                }
                else {
                    //logD("constrain y becuz TOP = \(globY) < \(topset)!")
                    newY = topset - initialViewFrame.origin.y + (resizeOffset.height ) / 2
                    doPostConstraint()
                }
            }
            // if resizeOffset.height < 0 that means window has been decreased in size vert.
            else if resizeOffset.height < 0 {
                let globY = newY + initialViewFrame.origin.y + abs(resizeOffset.height) / 2
                if globY > topset {
                }
                else {
                    //logD("constrain y becuz TOP = \(globY) < \(topset)!")
                    newY = topset - initialViewFrame.origin.y - abs(resizeOffset.height ) / 2
                    doPostConstraint()
                }
            }
// END: Three TOP edge cases....

// START: Three BOTTOM edge cases....
            if resizeOffset.height == 0 {
                let globY = newY + initialViewFrame.origin.y //- resizeOffset.height

                // Handle BOTTOM
                let bottom = globY + frame.size.height - fudge
                let farBound = viewSize.height + initialViewFrame.origin.y - fudge //+ (abs(resizeOffset.height) / 2)
                if bottom > farBound {
                    //logD("constrain y becuz BOTTOM = \(globY) < \(topset)!")
                    newY = farBound - frame.size.height - fudge
                    doPostConstraint()
                }
            }
            // if resizeOffset.height > 0 that means window has been increased in size vert.
            else if resizeOffset.height > 0 {
                let globY = newY + initialViewFrame.origin.y

                let trailing = globY + frame.size.height - (resizeOffset.height / 2)

                let farBound = viewSize.height + initialViewFrame.origin.y + (resizeOffset.height / 2)

                if trailing > farBound {
                    //logD("constrain x becuz BOTOM = \(trailing) > \(farBound)!")
                    newY = farBound - frame.size.height - fudge
                    doPostConstraint()
                }
            }
            // if resizeOffset.height < 0 that means window has been decreased in size vert.
            else if resizeOffset.height < 0 {
                let globY = newY + initialViewFrame.origin.y
                let trailing = globY  + frame.size.height
                let farBound = viewSize.height + initialViewFrame.origin.y - (abs(resizeOffset.height) / 2)

                if trailing > farBound {
                    //logD("constrain x becuz TRAILING = \(trailing) > \(farBound)!")
                    newY = farBound - frame.size.height - fudge
                    doPostConstraint()
                }
            }
// END: Three BOTTOM edge cases....

            position = CGSize(width:newX ,height: newY)
        }
    }

}
#endif
