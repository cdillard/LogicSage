//
//  UIView+Screenshot.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/4/23.
//

import Foundation
import UIKit

extension UIView {
    func screenshot() -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
        }
    }
}

func addBorders(image: UIImage) -> UIImage? {
    let borderSize: CGFloat = 135 // border size

    let imageSize = image.size

    UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize.width, height: imageSize.height + borderSize * 2), false, image.scale)

    let origin = CGPoint(x: 0, y: borderSize)   // where the image starts
    image.draw(at: origin)

    let newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // add the black border to the new image
    if let newImage = newImage, let borderedImage = newImage.borderImage(borderInsets: UIEdgeInsets(top: borderSize, left: borderSize * 6, bottom: borderSize, right: borderSize * 9), color: .clear) {
        return borderedImage
    }

    return nil
}

extension UIImage {
    func borderImage(borderInsets: UIEdgeInsets, color: UIColor) -> UIImage? {

        let newWidth = self.size.width + borderInsets.left + borderInsets.right
        let newHeight = self.size.height + borderInsets.top + borderInsets.bottom

        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        color.set()  // set the border color

        let rect = CGRect(x: borderInsets.left, y: borderInsets.top, width: self.size.width, height: self.size.height)
        // fill borderInsets
        context?.fill(CGRect(x: 0, y: 0, width: newWidth, height: borderInsets.top)) // Top border
        context?.fill(CGRect(x: 0, y: borderInsets.top + self.size.height, width: newWidth, height: borderInsets.bottom)) // Bottom border
        context?.fill(CGRect(x: 0, y: 0, width: borderInsets.left, height: newHeight)) // Left border
        context?.fill(CGRect(x: borderInsets.left + self.size.width, y: 0, width: borderInsets.right, height: newHeight)) // Right border

        self.draw(in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func resized(to newSize: CGSize) -> UIImage? {
      UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
      defer { UIGraphicsEndImageContext() }

      draw(in: CGRect(origin: .zero, size: newSize))
      return UIGraphicsGetImageFromCurrentImageContext()
    }
}
