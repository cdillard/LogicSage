//
//  AnimatedArrow.swift
//  LogicSage
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
                let size = geometry.size.height * 0.2266
                let yPosition = size * 0.8
                path.move(to: CGPoint(x: geometry.size.width * 0.5, y: yPosition))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.5 - size * 0.5, y: yPosition + size))
                path.addLine(to: CGPoint(x: geometry.size.width * 0.5 + size * 0.5, y: yPosition + size))
            }
            .fill(Color.gray)
            .opacity(self.animate ? 0.4 : 0.0)
            .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1.0))
            .rotationEffect(.degrees(180), anchor: .center)
            .onAppear {
                self.animate = true
            }
        }
    }
}
