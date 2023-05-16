//
//  Robot.swift
//  com.chrozzla.MySwiftyApp
//
//  Created by Chris Dillard on 4/14/23.
//


// Testing 123 

import SwiftUI
import UIKit

// Custom function to mirror an emoji
func mirrorEmoji(_ emoji: String) -> UIImage? {
    if let image = emoji.image() {
        return UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .upMirrored)
    }
    return nil
}

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as NSString).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

struct RobotHead: View {
    var body: some View {
        Text("🤖")
            .font(.system(size: 40))
    }
}

struct RobotLeftArm: View {
    var body: some View {
        if let mirroredImage = mirrorEmoji("🦾") {
            Image(uiImage: mirroredImage)
        }
    }
}

struct RobotRightArm: View {
    var body: some View {
        Text("🦾")
            .font(.system(size: 40))
    }
}

struct RobotLeftLeg: View {
    var body: some View {
        if let mirroredImage = mirrorEmoji("🦿") {
            Image(uiImage: mirroredImage)
        }
    }
}

struct RobotRightLeg: View {
    var body: some View {
        Text("🦿")
            .font(.system(size: 40))
    }
}


