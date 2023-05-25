//
//  PixelScan.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 5/23/23.
//

import Foundation
import CoreGraphics

func contentRect(inImage image: CGImage) -> CGRect {
    guard let provider = image.dataProvider else { return CGRect(origin: .zero, size: CGSize(width: image.width, height: image.height)) }
    guard let pixelData = provider.data else { return CGRect(origin: .zero, size: CGSize(width: image.width, height: image.height)) }
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

    var left = 0, right = image.width, top = 0, bottom = image.height

    // Scan from left
    scan: for x in 0..<image.width {
        for y in 0..<image.height {
            let pixelIndex = ((image.width * y) + x) * 4
            if data[pixelIndex] != 0 || data[pixelIndex+1] != 0 || data[pixelIndex+2] != 0 {
                left = x
                break scan
            }
        }
    }

    // Scan from right
    scan: for x in stride(from: image.width - 1, through: 0, by: -1) {
        for y in 0..<image.height {
            let pixelIndex = ((image.width * y) + x) * 4
            if data[pixelIndex] != 0 || data[pixelIndex+1] != 0 || data[pixelIndex+2] != 0 {
                right = x
                break scan
            }
        }
    }

    // Scan from top
    scan: for y in 0..<image.height {
        for x in 0..<image.width {
            let pixelIndex = ((image.width * y) + x) * 4
            if data[pixelIndex] != 0 || data[pixelIndex+1] != 0 || data[pixelIndex+2] != 0 {
                top = y
                break scan
            }
        }
    }

    // Scan from bottom
    scan: for y in stride(from: image.height - 1, through: 0, by: -1) {
        for x in 0..<image.width {
            let pixelIndex = ((image.width * y) + x) * 4
            if data[pixelIndex] != 0 || data[pixelIndex+1] != 0 || data[pixelIndex+2] != 0 {
                bottom = y
                break scan
            }
        }
    }

    return CGRect(x: left, y: top, width: right - left, height: bottom - top)
}
