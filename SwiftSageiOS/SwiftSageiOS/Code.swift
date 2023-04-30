//
//  Code.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/29/23.
//

import Foundation
let code1 = """
struct WaveView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let waveCount = 6
                ForEach(0..<waveCount) { index in
                    Path { p in
                        let x: CGFloat = CGFloat(index) / CGFloat(waveCount)
                        let y = CGFloat(sin((.pi * 2 * Double(x)) - (Double(geometry.frame(in: .local).minX) / 100))) / 3
                        p.move(to: CGPoint(x: geometry.frame(in: .local).minX, y: (1 + y) * geometry.frame(in: .local).height / 2))
                        for x in stride(from: geometry.frame(in:.local).minX, to: geometry.frame(in:.local).maxX, by: 4) {
                            let y = CGFloat(sin((.pi * 2 * Double(x/100)) + (Double(index) * .pi / 3) - (Double(geometry.frame(in: .local).minX) / 100))) / 3
                            p.addLine(to: CGPoint(x:x, y: (1 + y) * geometry.frame(in: .local).height / 2))
                        }
                        p.addLine(to: CGPoint(x:geometry.frame(in:.local).maxX, y:geometry.frame(in:.local).maxY))
                        p.addLine(to: CGPoint(x:geometry.frame(in:.local).minX, y:geometry.frame(in:.local).maxY))
                        p.addLine(to: CGPoint(x:geometry.frame(in:.local).minX, y:(1 - y) * geometry.frame(in: .local).height / 2))
                    }
                    .fill(Color(red: Double(index) / Double(waveCount), green: Double((waveCount - index) / waveCount), blue: 1.0 - Double(index) / Double(waveCount)))
                    .opacity(0.5)
                }
            }
        }
    }
}
"""
