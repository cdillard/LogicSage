//
//  CurvedEdgeArc.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 6/20/23.
//

import Foundation
import SwiftUI

struct CurvedEdgeArc: Shape {
    var cornerRadius: CGFloat
    var curveSize: CGFloat
    var position: CornerPosition

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center: CGPoint
        let start: CGPoint
        let end: CGPoint
        let control1: CGPoint
        let control2: CGPoint

        switch position {
        case .topLeft:
            center = CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius)

            start = CGPoint(x: center.x + cornerRadius, y: center.y)
            end = CGPoint(x: center.x, y: center.y - cornerRadius)
            control1 = CGPoint(x: start.x - curveSize, y: start.y)
            control2 = CGPoint(x: end.x, y: end.y + curveSize)
        case .topRight:
            center = CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius)

            start = CGPoint(x: center.x, y: center.y - cornerRadius)
            end = CGPoint(x: center.x - cornerRadius, y: center.y)
            control1 = CGPoint(x: start.x, y: start.y + curveSize)
            control2 = CGPoint(x: end.x + curveSize, y: end.y)
        case .bottomLeft:
            center = CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius)

            start = CGPoint(x: center.x, y: center.y + cornerRadius)
            end = CGPoint(x: center.x + cornerRadius, y: center.y)
            control1 = CGPoint(x: start.x, y: start.y - curveSize)
            control2 = CGPoint(x: end.x - curveSize, y: end.y)
        case .bottomRight:
            center = CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius)

            start = CGPoint(x: center.x - cornerRadius, y: center.y)
            end = CGPoint(x: center.x, y: center.y + cornerRadius)
            control1 = CGPoint(x: start.x + curveSize, y: start.y)
            control2 = CGPoint(x: end.x, y: end.y - curveSize)
        }

        path.move(to: start)
        path.addCurve(to: end, control1: control1, control2: control2)

        return path
    }

    enum CornerPosition {
        case topLeft, topRight, bottomLeft, bottomRight
    }
}
