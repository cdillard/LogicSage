//
//  MovableDivider.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/17/23.
//

import Foundation
import SwiftUI

struct MovableDivider: View {
    @Binding var dividerWidth: CGFloat
    @State private var currentWidth: CGFloat = 0
    @State private var tempWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 8, height: geometry.size.height)
                    .contentShape(Rectangle())
#if !os(tvOS)

                    .gesture(

                        DragGesture()
                           .onChanged { value in
                               let delta = value.location.x - value.startLocation.x
                               let newWidth = tempWidth + delta
                               if newWidth > 0 && newWidth < geometry.size.width {
                                   currentWidth = newWidth
                                   dividerWidth = currentWidth
                               }
                            }
                            .onEnded { _ in
                                tempWidth = currentWidth
                            }
                      )
#endif

            }
            .frame(width: currentWidth, height: geometry.size.height, alignment: .leading)
            .position(x: currentWidth / 2)
        }
        .onAppear {
            currentWidth = dividerWidth
            tempWidth = dividerWidth
        }
    }
}
