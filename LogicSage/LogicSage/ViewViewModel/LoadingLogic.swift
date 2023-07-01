//
//  LoadingLogic.swift
//  LogicSage
//
//  Created by Chris Dillard on 5/26/23.
//

import Foundation
import SwiftUI

let logoAscii8 = """
🤖 👽 Unleash
the spark ⚡️ Creativity
LogicSage 👽 🤖
"""
let logoAscii6 = """
╭╮╱╱╱╱╱╱╱╱╱╱╱╱╭━━━╮
┃┃╱╱╱╱╱╱╱╱╱╱╱╱┃╭━╮┃
┃┃╱╱╭━━┳━━┳┳━━┫╰━━┳━━┳━━┳━━╮
┃┃╱╭┫╭╮┃╭╮┣┫╭━┻━━╮┃╭╮┃╭╮┃┃━┫
┃╰━╯┃╰╯┃╰╯┃┃╰━┫╰━╯┃╭╮┃╰╯┃┃━┫
╰━━━┻━━┻━╮┣┻━━┻━━━┻╯╰┻━╮┣━━╯
╱╱╱╱╱╱╱╭━╯┃╱╱╱╱╱╱╱╱╱╱╭━╯┃
╱╱╱╱╱╱╱╰━━╯╱╱╱╱╱╱╱╱╱╱╰━━╯
"""
let animFrameDuration: CGFloat = 0.01

var chosenLogo = getRandomLogo()

func getRandomLogo() -> String {
    if !hasSeenLogo() {
        setHasSeenLogo(true)
        return logoAscii6
    }
    switch Int.random(in: 0...10) {
    case 0: return logoAscii6
    case 1: return logoAscii8
    default: return ""
    }
}
var randomColor = getRandomGreen()

func getRandomGreen() -> Color {
    greenShades.randomElement() ?? .green
}

let delay = 0.366
let greenShades = [//[Color.lightGreen, Color.limeGreen, Color.emeraldGreen,
    Color.forestGreen, Color.darkGreen]

struct LoadingLogicView: View {

    @State private var showText: [Bool]
    @State private var positions: [CGSize]

    init() {
        let characterCount = chosenLogo.filter { $0 != "\n" }.count
        _showText = State(initialValue: Array(repeating: false, count: characterCount))
        _positions = State(initialValue: (0..<characterCount).map { _ in LoadingLogicView.randomPosition() })
    }

    static private func randomPosition() -> CGSize {
        let angle = Double.random(in: 0..<360)
        let distance: CGFloat = 266.666
        let x = cos(angle) * Double(distance)
        let y = sin(angle) * Double(distance)
        return CGSize(width: x, height: y)
    }
    var body: some View {
        if !chosenLogo.isEmpty {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(chosenLogo.lines.indices, id: \.self) { lineIndex in
                        HStack(alignment: .top, spacing: 0) {
                            let line = chosenLogo.lines[lineIndex]
                            ForEach(0..<line.count, id: \.self) { index in
                                let characterIndex = chosenLogo.indexForLine(lineIndex: lineIndex, characterIndex: index)
                                Text(String(line[line.index(line.startIndex, offsetBy: index)]))
#if !os(macOS)
                                    .font(Font(UIFont(name: "Menlo", size: 23)!))
#endif
                                    .foregroundColor(randomColor)
                                    .scaleEffect(showText[characterIndex] ? 1: 0.2)
                                    .offset(x: showText[characterIndex] ? 0 : positions[characterIndex].width, y: showText[characterIndex] ? 0 : positions[characterIndex].height)
                                    .opacity(showText[characterIndex] ? 1 : 0)
                                    .animation(.timingCurve(0.3, -0.3, 0.7, 1.3, duration: Double(showText[characterIndex] ? delay : 0))
                                        .delay(Double(characterIndex) * animFrameDuration), value: showText)
                            }
                        }
                    }
                }
                RadialGradient(gradient: Gradient(colors: [.black.opacity(0.666), .clear]),
                               center: .center,
                               startRadius: 0,
                               endRadius: 666)
                .edgesIgnoringSafeArea(.all)
            }
            .onAppear {
                if hasSeenAnim() {
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.98) {
                        for index in 0..<chosenLogo.filter({ $0 != "\n" }).count {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * animFrameDuration) {
                                showText[index] = true

                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * animFrameDuration + delay) {
                                    if Int.random(in: 0...1) == 0 {
                                        playLightImpact()
                                    }
                                    else {
                                        playSoftImpact()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct GreenColors {
    static let lightGreen = Color(red: 0.6, green: 0.9, blue: 0.6)
    static let limeGreen = Color(red: 0.4, green: 0.8, blue: 0.2)
    static let emeraldGreen = Color(red: 0.2, green: 0.6, blue: 0.4)
    static let forestGreen = Color(red: 0.13, green: 0.47, blue: 0.29)
    static let darkGreen = Color(red: 0.0, green: 0.4, blue: 0.13)
}
extension String {
    var lines: [String.SubSequence] { split(separator: "\n") }

    func indexForLine(lineIndex: Int, characterIndex: Int) -> Int {
        let previousLines = lines[0..<lineIndex].joined(separator: "\n")
        let previousCharactersCount = previousLines.filter({ $0 != "\n" }).count
        return previousCharactersCount + characterIndex
    }
}
// Use the provided green colors
extension Color {
    static let lightGreen = GreenColors.lightGreen
    static let limeGreen = GreenColors.limeGreen
    static let emeraldGreen = GreenColors.emeraldGreen
    static let forestGreen = GreenColors.forestGreen
    static let darkGreen = GreenColors.darkGreen
}
extension View {
    func animate(duration: CGFloat, _ execute: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(.linear(duration: duration)) {
                execute()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
}
