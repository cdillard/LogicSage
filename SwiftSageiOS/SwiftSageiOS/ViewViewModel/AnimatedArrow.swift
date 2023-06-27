//
//  AnimatedArrow.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 6/25/23.
//

import Foundation
import SwiftUI

struct AnimatedArrow: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let size = geometry.size.height * 0.3
                let yPosition = size * 0.7
                path.move(to: CGPoint(x: geometry.size.width * 0.5, y: yPosition))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.5 - size * 0.5, y: yPosition + size))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.5 + size * 0.5, y: yPosition + size))
            }
            .fill(Color.gray)
            .opacity(self.animate ? 1.0 : 0.0)
            .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.3))
            .rotationEffect(.degrees(180), anchor: .center)
            .onAppear {
                self.animate = true
            }
        }
    }
}
