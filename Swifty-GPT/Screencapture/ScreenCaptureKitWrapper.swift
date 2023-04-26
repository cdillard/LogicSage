//
//  ScreenCaptureKitWrapper.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import ScreenCaptureKit
import AVFoundation
import Cocoa
import Quartz


func getSimulatorWindows() -> [CGWindowID: CGRect] {
    let windowInfoList = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: AnyObject]]
    var simulatorWindows = [CGWindowID: CGRect]()

    for windowInfo in windowInfoList! {
        if let windowOwnerName = windowInfo[kCGWindowOwnerName as String] as? String,
           windowOwnerName == "Simulator" {
            if let windowNumber = windowInfo[kCGWindowNumber as String] as? CGWindowID,
               let windowBoundsDict = windowInfo[kCGWindowBounds as String] as? [String: CGFloat] {
                let windowBounds = CGRect(x: windowBoundsDict["X"]!,
                                          y: windowBoundsDict["Y"]!,
                                          width: windowBoundsDict["Width"]!,
                                          height: windowBoundsDict["Height"]!)
                simulatorWindows[windowNumber] = windowBounds
            }
        }
    }

    return simulatorWindows
}



class VideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession?
    static let shared = VideoCapture()
    private var simulatorWindowID: CGWindowID?
    private var captureTimer: DispatchSourceTimer?

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Process the sample buffer
        processSampleBuffer(sampleBuffer)
    }

    private func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        // Get a CVPixelBuffer from the sample buffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get pixel buffer from sample buffer")
            return
        }

        // Convert the pixel buffer to a JPEG image
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create CGImage from CIImage")
            return
        }

        let nsImage = NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
        let bitmapRep = NSBitmapImageRep(data: nsImage.tiffRepresentation!)!
        let imageData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.8])

        // ... (your streaming logic here)
        localPeerConsole.sendImageData(imageData)

    }


    func startSimulatorWindowCapture(simulatorWindowID: CGWindowID) {
        self.simulatorWindowID = simulatorWindowID
        let queue = DispatchQueue(label: "SimulatorWindowCapture")
        captureTimer = DispatchSource.makeTimerSource(queue: queue)
        captureTimer?.schedule(deadline: .now(), repeating: .milliseconds(100))
        captureTimer?.setEventHandler(handler: captureSimulatorWindow)
        captureTimer?.resume()
    }


    func captureSimulatorWindow() {


        let simulatorWindows = getSimulatorWindows()

      //  if let firstSimulatorWindow = simulatorWindows.first {
            let windowInfoList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as! [NSDictionary]
        let filteredWindows = windowInfoList.filter { ($0[kCGWindowOwnerName] as? String) == "Simulator" }


            guard let simulatorWindow = filteredWindows.first,
                  let windowBounds = simulatorWindow[kCGWindowBounds] as? NSDictionary,
                  let windowX = windowBounds["X"] as? CGFloat,
                  let windowY = windowBounds["Y"] as? CGFloat,
                  let windowWidth = windowBounds["Width"] as? CGFloat,
                  let windowHeight = windowBounds["Height"] as? CGFloat else {
                print("Failed to get simulator window bounds")
                return
            }
            let mainDisplayID = CGMainDisplayID()
            guard let fullScreenImage = CGDisplayCreateImage(mainDisplayID) else {
                print("Failed to capture the screen")
                return
            }

            let simulatorWindowRect = CGRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight)
            guard let croppedImage = fullScreenImage.cropping(to: simulatorWindowRect) else {
                print("Failed to crop the screen image")
                return
            }


            let ciImage = CIImage(cgImage: croppedImage)
            let context = CIContext(options: nil)

            guard let pixelBuffer = self.createPixelBuffer(from: ciImage, context: context) else {
                print("Failed to create pixel buffer from captured image")
                return
            }

            guard let sampleBuffer = self.createSampleBuffer(from: pixelBuffer) else {
                print("Failed to create sample buffer from pixel buffer")
                return
            }

            self.processSampleBuffer(sampleBuffer)
//        }
//        else {
//            print("failed")
//            return
//        }


    }


    private func createSampleBuffer(from pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer? = nil
        var timingInfo = CMSampleTimingInfo(duration: CMTime.invalid, presentationTimeStamp: CMTime.invalid, decodeTimeStamp: CMTime.invalid)

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var formatDescription: CMVideoFormatDescription?
        let statusFormat = CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)

        guard statusFormat == noErr else {
            print("Failed to create video format description: \(statusFormat)")
            return nil
        }

        let status = CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescription: formatDescription!, sampleTiming: &timingInfo, sampleBufferOut: &sampleBuffer)

        guard status == noErr else {
            print("Failed to create sample buffer: \(status)")
            return nil
        }

        return sampleBuffer
    }

    private func createPixelBuffer(from ciImage: CIImage, context: CIContext) -> CVPixelBuffer? {
        let width = Int(ciImage.extent.width)
        let height = Int(ciImage.extent.height)

        var pixelBuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, nil, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            print("Failed to create pixel buffer: \(status)")
            return nil
        }

        context.render(ciImage, to: pixelBuffer!)
        return pixelBuffer
    }


//    func captureSageSimulator() {
//        let simulatorWindows = getSimulatorWindows()
//
//        if let firstSimulatorWindow = simulatorWindows.first {
//            startSimulatorWindowCapture(simulatorWindowID: firstSimulatorWindow.key)
//        } else {
//            print("No simulator windows found")
//        }
//
//    }
}
