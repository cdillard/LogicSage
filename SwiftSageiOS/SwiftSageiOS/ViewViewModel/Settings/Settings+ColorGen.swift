//
//  Settings+ColorGen.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/30/23.
//

import Foundation
import SwiftUI

#if !os(macOS)

func extractPrimaryColors(from image: UIImage, numberOfColors: Int, completionHandler: @escaping ([Color]) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let ciImage = CIImage(image: image)
        let filter = CIFilter(name: "CIAreaAverage",
                              parameters: [kCIInputImageKey: ciImage!,
                                           "inputExtent": CIVector(cgRect: ciImage!.extent)])

        let outputImage = filter!.outputImage!
        let context = CIContext()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        var pixelData = [UInt8](repeating: 0, count: 4)

        context.render(outputImage,
                       toBitmap: &pixelData,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: CIFormat.RGBA8,
                       colorSpace: colorSpace)

        let color = Color(hex: UInt((Int(pixelData[0]) << 16) + (Int(pixelData[1]) << 8) + Int(pixelData[2])),
                          alpha: 1)

        DispatchQueue.main.async {
            completionHandler([color])
        }
    }
}

func contrastRatio(between color1: UIColor, and color2: UIColor) -> CGFloat {
    let l1 = color1.luminance
    let l2 = color2.luminance

    if l1 > l2 {
        return (l1 + 0.05) / (l2 + 0.05)
    } else {
        return (l2 + 0.05) / (l1 + 0.05)
    }
}

extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    var luminance: CGFloat {
        let components = self.components
        let R = components.red <= 0.03928 ? components.red / 12.92 : pow((components.red + 0.055) / 1.055, 2.4)
        let G = components.green <= 0.03928 ? components.green / 12.92 : pow((components.green + 0.055) / 1.055, 2.4)
        let B = components.blue <= 0.03928 ? components.blue / 12.92 : pow((components.blue + 0.055) / 1.055, 2.4)

        return 0.2126 * R + 0.7152 * G + 0.0722 * B
    }
}

func complementaryColor(of color: UIColor) -> UIColor {
    let components = color.components
    return UIColor(red: 1 - components.red,
                   green: 1 - components.green,
                   blue: 1 - components.blue,
                   alpha: 1)
}


#endif
