//
//  ViewController+PointerInteraction.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 6/22/23.
//

import Foundation
#if !os(macOS)
#if !os(xrOS)
#if !os(tvOS)

import UIKit

extension InnerTextView: UIPointerInteractionDelegate {

    /** Called as the pointer moves within the interaction's view.
        Return a UIPointerRegion in which to apply a pointer style.
        Return nil to indicate that this interaction should not customize the pointer for the current location.
     */
    func pointerInteraction(_ interaction: UIPointerInteraction,
                            regionFor request: UIPointerRegionRequest,
                            defaultRegion: UIPointerRegion) -> UIPointerRegion? {
        var pointerRegion: UIPointerRegion? = nil

        if let view = interaction.view as? ShapeView {
            // Pointer has entered one of the shape views.

            // Check for modifiers keys pressed while inside the view path.
            if request.modifiers.contains(.command) && request.modifiers.contains(.alternate) {
                // Command + Option was both pressed, dim the view.
                view.alpha = 0.50
            } else {
                if view.alpha != 1.0 { view.alpha = 1.0 }
            }

            // The user interacted with the inner path region.
            pointerRegion =
                UIPointerRegion(rect: view.innerPath.bounds,
                                identifier: ShapeView.regionIdentifier)
        }

        return pointerRegion
    }

    /** Called after the interaction receives a new UIPointerRegion from pointerInteraction:regionForRequest:defaultRegion:.
        Return a UIPointerStyle describing the desired hover effect or pointer appearance for the given UIPointerRegion and UIKeyModifierFlags.
     */
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle? = nil

        if let shapeView = interaction.view as? ShapeView {
            if let targetedPreview = shapeView.targetedPreview() {
                // Which kind of shape view are we applying the pointer effect to?
                    // UIPointerEffect attempts to determine the appropriate effect for the given preview automatically.
                    let pointerEffect = UIPointerEffect.automatic(targetedPreview)

                    // Since this shape is a simple square, don't pass in a custom shape.
                    pointerStyle = UIPointerStyle(effect: pointerEffect, shape: nil)
                //}
            }
        }
//        else if let alphaControl = interaction.view as? AlphaControl {
//            // Apply the hover pointer effect to the color control.
//            let targetedPreview = alphaControl.targetedPreview()
//            let pointerEffect = UIPointerEffect.hover(targetedPreview, prefersShadow: false, prefersScaledContent: false)
//            pointerStyle = UIPointerStyle(effect: pointerEffect, shape: nil)
//        }

        return pointerStyle
    }

    /** Called when the pointer enters a given region.
        Add animations to run them alongside the pointer's entrance animation.
    */
    func pointerInteraction(_ interaction: UIPointerInteraction,
                            willEnter region: UIPointerRegion,
                            animator: UIPointerInteractionAnimating) {
        if region.identifier == ShapeView.regionIdentifier {
            // The pointer has entered the shape view's region path.

            // For example, show the effect label inside the shape.
            if let shapeView = interaction.view as? ShapeView {
                // Perform any kind of "enter animation" within this shape view with 'animator'.
                animator.addAnimations {
                    shapeView.effectLabel.isHidden = false
                }
                // Perform any kind of "enter completion" animation within this shape view with 'animator'.
                animator.addCompletion { _ in
                    //.
                }
            }
        }
//        if region.identifier == AlphaControl.regionIdentifier {
//            // The pointer has entered the alpha control's region path.
//        }
    }

    /** Called when the pointer exists a given region.
        Add animations to run them alongside the pointer's exit animation.
    */
    func pointerInteraction(_ interaction: UIPointerInteraction,
                            willExit region: UIPointerRegion,
                            animator: UIPointerInteractionAnimating) {
        if region.identifier == ShapeView.regionIdentifier {
            // The pointer has exited the shape view's region path.

            // For example, hide the effect label inside the shape.
            if let shapeView = interaction.view as? ShapeView {
                // Perform any kind of "exit animation" within this shape view with 'animator'.
                animator.addAnimations {
                    shapeView.effectLabel.isHidden = true

                    // If the user pressed command-option while interacting with the shape view, restore its alpha.
                    if shapeView.alpha != 1.0 { shapeView.alpha = 1.0 }
                }
                // Perform any kind of "exit completion" animation within this shape view with 'animator'.
                animator.addCompletion { _ in
                    //..
                }
            }
        }
//        else if region.identifier == AlphaControl.regionIdentifier {
//            // The pointer has exited the alpha control's region path.
//        }
    }

    // Return a triangle bezier path for the pointer's shape.
    func trianglePointerShape() -> UIBezierPath {
        let width = 20.0
        let height = 20.0
        let offset = 10.0 // Coordinate location to match up with the coordinate of default pointer shape.

        let pathView = UIBezierPath()
        pathView.move(to: CGPoint(x: (width / 2) - offset, y: -offset))
        pathView.addLine(to: CGPoint(x: -offset, y: height - offset))
        pathView.addLine(to: CGPoint(x: width - offset, y: height - offset))
        pathView.close()

        return pathView
    }
}

#endif
#endif
#endif
