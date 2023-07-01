//
//  ShapeView.swift
//  SwiftSageiOS

import Foundation

#if !os(macOS)

import UIKit

class ShapeView: UIView {

    // The outer view path surrounding the view content.
    var viewPath: UIBezierPath!
    var viewPathColor = UIColor.systemYellow

    // The inner view path surrounding the image.
    var innerPath = UIBezierPath()
#if !os(tvOS)

    var innerPathColor = UIColor.secondarySystemBackground
    #else
    var innerPathColor = UIColor.secondaryLabel

    #endif
    // Identifier for the shape view UIPointerInteraction region.
    static let regionIdentifier: AnyHashable = "viewPath"

    // The inner-most center image view.
    private var imageView: UIImageView!

    // The inset amount for the image view.
    private let innerInset: CGFloat = 15.0

    // The pointer effect name for this shape view (to be shown and hidden during effect animations).
    var effectLabel: UILabel!
    var effectName: String = "" {
        didSet {
            effectLabel.text = effectName
            effectLabel.sizeToFit()
            effectLabel.frame.origin.x =
                (bounds.width - effectLabel.bounds.size.width) / 2
            effectLabel.frame.origin.y =
                bounds.size.height - effectLabel.bounds.size.height - innerInset - 2.0
            effectLabel.isHidden = true
        }
    }

    // MARK: -

    func commonInit() {
        // Create the outer view path surrounding the view content.
        let bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        viewPath = pathViewForFrame(bounds)

        // Create the inner view path surrounding the image.
        let innerBounds = bounds.insetBy(dx: innerInset, dy: innerInset)
        innerPath = pathViewForFrame(innerBounds)

        effectLabel = UILabel(frame: CGRect())
        addSubview(effectLabel)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func draw(_ rect: CGRect) {
        viewPathColor.setFill()
        viewPath.fill()

        innerPathColor.setFill()
        innerPath.fill()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // View hit testing for events and gestures goes through here.
        // Implementing this means we don't have to do it repeatedly elsewhere.
        return viewPath.contains(point)
    }

    func restoreOuterFrameColor() {
        viewPathColor = UIColor.systemYellow
        setNeedsDisplay()
    }

    func pathViewForFrame(_ frame: CGRect) -> UIBezierPath {
        return UIBezierPath(rect: frame)
    }

    func targetedPreview() -> UITargetedPreview? {
        let parameters = UIPreviewParameters()

        // Use the entire view's shape for the preview.
        let visiblePath = viewPath
        parameters.visiblePath = visiblePath

        return UITargetedPreview(view: self, parameters: parameters)
    }
}

// MARK: - TriangleShapeView

class TriangleShapeView: ShapeView {
    override func pathViewForFrame(_ frame: CGRect) -> UIBezierPath {
        let pathView: UIBezierPath!
        let height = frame.size.height
        let width = frame.size.width
        pathView = UIBezierPath()
        pathView.move(to: CGPoint(x: (width / 2) + frame.origin.x, y: frame.origin.y * 2))
        pathView.addLine(to: CGPoint(x: width + frame.origin.x - 20, y: height + frame.origin.y))
        pathView.addLine(to: CGPoint(x: frame.origin.x + 20, y: height + frame.origin.y))
        pathView.close()
        return pathView
    }

}

// MARK: - RoundrectShapeView

class RoundrectShapeView: ShapeView {
    static let cornerRadious: CGFloat = 30.0
    override func pathViewForFrame(_ frame: CGRect) -> UIBezierPath {
        return UIBezierPath(roundedRect: frame, cornerRadius: RoundrectShapeView.cornerRadious)
    }

}

// MARK: - OvalShapeView

class OvalShapeView: ShapeView {
    override func pathViewForFrame(_ frame: CGRect) -> UIBezierPath {
        return UIBezierPath(ovalIn: frame)
    }

}

#endif
