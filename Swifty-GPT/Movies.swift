//
//  Movies.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/21/23.
//

import Foundation
import PNG
// Define ASCII character set
let useMatrixLettrs = ":.=*+-¦|_ﾊﾐﾋｰｳｼ012ç34578ﾘ9ﾅ日ﾓﾆｻﾜﾂｵﾘçｱｸﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾘﾈｽﾀﾇﾍｦｲｸｺçｿﾁﾄﾉﾌﾔﾖﾙﾚﾛﾝｲｸﾁﾄﾉﾌﾍﾖﾙﾚﾛﾝ"
// + Array(logoAscii5) + Array(useMatrixLettrs)
let ASCII_CHARS: [Character] = ["@", "#", "S", "%", "?", "*", "+", ";", ":", ",", "."]

func goToMovies() {
    if let path = Bundle.main.path(forResource: "IMG_5563", ofType: "PNG") {
        let ascii = imageToAscii(imagePath: path, width: 160)
        print(ascii)
    }
    else {
        print("no movie 4 u....")
    }
    if let path = Bundle.main.path(forResource: "IMG_5564", ofType: "png") {
        let ascii = imageToAscii(imagePath: path, width: 160)
        print(ascii)
    }
    else {
        print("no movie 4 u....")
    }
    if let path = Bundle.main.path(forResource: "IMG_5565", ofType: "png") {
        let ascii = imageToAscii(imagePath: path, width: 160)
        print(ascii)
    }
    else {
        print("no movie 4 u....")
    }
    if let path = Bundle.main.path(forResource: "IMG_5566", ofType: "png") {
        let ascii = imageToAscii(imagePath: path, width: 160)
        print(ascii)
    }
    else {
        print("no movie 4 u....")
    }
}

func imageToAscii(imagePath: String, width: Int) -> String {
    do {
        guard let image:PNG.Data.Rectangular = try .decompress(path: imagePath) else {
            print("fail") ; return ""

        }

           // let resizedImage = resizeImage(image: image, newWidth: width)
            let asciiImage = convertToAscii(image: image)
            return asciiImage
    }
    catch {
        return "errormovvin  e=\(error)"
    }
}

func convertToAscii(image: PNG.Data.Rectangular) -> String {
        let rgba:[PNG.RGBA<UInt8>] = image.unpack(as: PNG.RGBA<UInt8>.self),
            size:(x:Int, y:Int)    = image.size

    let width = Int(size.x)
    let height = Int(size.y)

    var asciiArt = ""

    for y in 0..<height {
        for x in 0..<width {
            let pixelColor = getPixel(x: x, y: y, width: width, rgb: rgba)
            let grayScaleValue = 0.299 * Double(pixelColor.red) + 0.587 * Double(pixelColor.green) + 0.114 * Double(pixelColor.blue)
            let index = Int(grayScaleValue / 255.0 * Double(ASCII_CHARS.count))
            asciiArt += String(ASCII_CHARS[index])
        }
        asciiArt += "\n"
    }
    return asciiArt
}



func getPixel(x: Int, y: Int, width: Int, rgb: [PNG.RGBA<UInt8>]) -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
    let index = y * width + x
    let pixel = rgb[index]
    return (red: pixel.r, green: pixel.g, blue: pixel.b, alpha: 255)
}
