//
//  CustomPointerView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 6/21/23.
//

import Foundation
import SwiftUI
#if !os(macOS)

class CustomPointerView: UIView, UIPointerInteractionDelegate {
    var mode: PointerBezMode = .topLeft

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Add a pointer interaction to the view.
        self.addInteraction(UIPointerInteraction(delegate: self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Supply pointer style with custom shape.
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        let shape = UIPointerShape.path(mode.shape())
        return UIPointerStyle(shape: shape)
    }
}

enum PointerBezMode {
    case topLeft
    case topRight
    case vertical
    case horizontal

    func shape() -> UIBezierPath {
        switch self {
            // Top left shape is used for bottom right too.
        case .topLeft: return Beziers.createTopLeft()
        case .topRight: return Beziers.createTopRight()
        case .vertical: return Beziers.createTopLeft()
        case .horizontal: return Beziers.createTopLeft()
        }
    }
}

struct CustomPointerRepresentableView: UIViewRepresentable {

    let mode: PointerBezMode
    init(mode: PointerBezMode) {
        self.mode = mode
    }
    func makeUIView(context: Context) -> CustomPointerView {
        let customPointerView = CustomPointerView()
        customPointerView.mode = mode
        return customPointerView
    }

    func updateUIView(_ uiView: CustomPointerView, context: Context) {
        // Update the view.
    }
}

struct Beziers {
    static func createTopLeft() -> UIBezierPath {
        let triangleSize: CGFloat = 15
        let triangleSpacing: CGFloat = 12
        let triangleTranslation: CGFloat = -22.5

        // Create the first triangle (rotated 180 degrees)
        let trianglePath1 = UIBezierPath()
        trianglePath1.move(to: CGPoint(x: triangleSize, y: triangleSize))
        trianglePath1.addLine(to: CGPoint(x: 0, y: 0))
        trianglePath1.addLine(to: CGPoint(x: triangleSize, y: 0))
        trianglePath1.close()
        let rotate1 = CGAffineTransform(rotationAngle: .pi / 2)
        trianglePath1.apply(rotate1)

        // Create the second triangle
        let trianglePath2 = UIBezierPath()
        trianglePath2.move(to: CGPoint(x: triangleSize, y: triangleSize))
        trianglePath2.addLine(to: CGPoint(x: 0, y: 0))
        trianglePath2.addLine(to: CGPoint(x: triangleSize, y: 0))
        trianglePath2.close()
        let rotate2 = CGAffineTransform(rotationAngle: -.pi/2)
        trianglePath2.apply(rotate2)

        let translate2 = CGAffineTransform(translationX: triangleTranslation, y: triangleSpacing)
        trianglePath2.apply(translate2)
        // Append the second triangle path to the first to create the final path
        trianglePath1.append(trianglePath2)
        return trianglePath1
    }
    static func createTopRight() -> UIBezierPath {
        let topLeftShape = createTopLeft()

        let rotate2 = CGAffineTransform(rotationAngle: .pi / 2)
        topLeftShape.apply(rotate2)

        return topLeftShape
    }
}
#endif
