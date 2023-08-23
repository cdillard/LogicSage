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
import Combine

let maxScreenRecordingDuration: TimeInterval = 60.0
let frameInterval: Double = 1.0 // this means one frame per second

@MainActor
class VideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    static let shared = VideoCapture()

    func captureAppWindow(applicationName: String, windowName: String) async {
        // Check for screen recording permission, make sure your Terminal.app or iTerm2.app has screen recording permission
        guard CGPreflightScreenCaptureAccess() else {
            multiPrinter("No screen capture permission `mirror` failed!")
            return
        }

        do {

            var displayCount: UInt32 = 0
            var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: 16) // assuming a maximum of 16 screens

            if CGGetActiveDisplayList(UInt32(onlineDisplays.count), &onlineDisplays, &displayCount) != .success {
                print("Could not get active display list")
                return
            }
            //
            for i in 0..<Int(displayCount) {
                Task {
                    let displayID = onlineDisplays[i]

                    let recordURL = pathToRecordingAssets(name: "recording-\(applicationName)-\(displayID).mov")

                    do {
                        try FileManager.default.removeItem(atPath: recordURL)
                    }
                    catch {
                        multiPrinter("did not exist or delete old \(recordURL)")
                    }

                    let screenRecorder = try await ScreenRecorder2(url: URL(fileURLWithPath: recordURL), displayID: displayID, isSimulator: false, appName:applicationName, windowName: windowName, cropRect: nil)

                    multiPrinter("Starting mirror recording of \(applicationName)")

                    try await screenRecorder.start()

                    // We should stop and delete recording periodically and determine if the avasset writing is really needed to get the sample buffers
                    DispatchQueue.global().asyncAfter(deadline: .now() + maxScreenRecordingDuration) {
                        Task {
                            do {
                                try await screenRecorder.stop()
                                multiPrinter("stopped sim capture. Please run `mirror` again to restart")

                            }
                            catch {
                                multiPrinter("err mirror screen recording = \(error)")
                            }
                        }
                    }
                }
            }

        }
        catch {
            multiPrinter(error)
        }

    }

    func captureSimulatorWindow() async {
        // Check for screen recording permission, make sure your Terminal.app or iTerm2.app has screen recording permission
        guard CGPreflightScreenCaptureAccess() else {
            multiPrinter("No screen capture permission")
            return
        }
        do {


            var displayCount: UInt32 = 0
            var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: 16) // assuming a maximum of 16 screens

            if CGGetActiveDisplayList(UInt32(onlineDisplays.count), &onlineDisplays, &displayCount) != .success {
                print("Could not get active display list")
                return
            }
            //
            for i in 0..<Int(displayCount) {
                Task {
                    do {
                        let displayID = onlineDisplays[i]
                        let recordURL = pathToRecordingAssets(name: "recording-sim-\(displayID).mov")
                        do {
                            try FileManager.default.removeItem(atPath: recordURL)
                        }
                        catch {
                            multiPrinter("did not exist or delete old recording.mov")
                        }

                        let screenRecorder = try await ScreenRecorder2(url: URL(fileURLWithPath: recordURL), displayID: displayID, cropRect: nil)

                        multiPrinter("Starting screen recording of \(displayID) display")

                        try await screenRecorder.start()

                        // We should stop and delete recording periodically and determine if the avasset writing is really needed to get the sample buffers
                        DispatchQueue.global().asyncAfter(deadline: .now() + maxScreenRecordingDuration) {
                            Task {
                                do {
                                    try await screenRecorder.stop()
                                    multiPrinter("stopped sim capture. Please run `simulator` again to restart")

                                }
                                catch {
                                    multiPrinter("err screen recording = \(error)")
                                }
                            }
                        }
                    }
                    catch {
                        multiPrinter("")
                    }
                }
            }
        }
        catch {
            multiPrinter(error)
        }
    }
    func pathToRecordingAssets(name: String = "recording.mov") -> String {
        "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)/\(name)"
    }
}
struct ScreenRecorder2 {
    private let videoSampleBufferQueue = DispatchQueue(label: "com.chrisdillard.LogicSage.VideoSampleBufferQueue")

    private let assetWriter: AVAssetWriter
    private let videoInput: AVAssetWriterInput
    private let streamOutput: StreamOutput
    private var stream: SCStream
    private var foundTarget = false

    init(url: URL, displayID: CGDirectDisplayID, isSimulator: Bool = true, appName: String? = nil, windowName: String? = nil, cropRect: CGRect?) async throws {

        // Create AVAssetWriter for a QuickTime movie file
        self.assetWriter = try AVAssetWriter(url: url, fileType: .mov)

        // Create a filter for the specified display
        let sharableContent = try await SCShareableContent.current

        if let appName = appName, let windowName = windowName, !isSimulator {
            multiPrinter("Hunting for  window \(appName ) \(windowName)\n")
        }
        for window in sharableContent.windows {
            if isSimulator && window.displayName.contains("Simulator:") {
                multiPrinter("found sim wind = \(window.displayName) : \(window.frame) size: \(window.frame.size)\n")
            }

            if let appName = appName, let windowName = windowName, !isSimulator {
                multiPrinter("found wind = \(window.displayName) : \(window.frame) size: \(window.frame.size)\n")

            }
            
        }
        guard let simWindow = sharableContent.windows.first(where: {
            $0.displayName.contains("Simulator:") && $0.frame.origin.x != 0 && $0.frame.origin.y != 0

        }) else {
            multiPrinter("Cannot find sim window\n")
            throw RecordingError("Cannot find sim window")
        }

        let filter = SCContentFilter(desktopIndependentWindow: simWindow)

        // MARK: AVAssetWriter setup

        // AVAssetWriterInput supports maximum resolution of 4096x2304 for H.264
        // Downsize to fit a larger display back into in 4K
        let videoSize = downsizedVideoSize(source: simWindow.frame.size, scaleFactor: 2)

        // This preset is the maximum H.264 preset, at the time of writing this code
        // Make this as large as possible, size will be reduced to screen size by computed videoSize
        guard let assistant = AVOutputSettingsAssistant(preset: .preset3840x2160) else {
            multiPrinter("Can't create AVOutputSettingsAssistant with .preset3840x2160")

            throw RecordingError("Can't create AVOutputSettingsAssistant with .preset3840x2160")
        }
        assistant.sourceVideoFormat = try CMVideoFormatDescription(videoCodecType: .h264, width: videoSize.width, height: videoSize.height)

        guard var outputSettings = assistant.videoSettings else {
            multiPrinter("AVOutputSettingsAssistant has no videoSettings")

            throw RecordingError("AVOutputSettingsAssistant has no videoSettings")
        }
        outputSettings[AVVideoWidthKey] = videoSize.width
        outputSettings[AVVideoHeightKey] = videoSize.height

        // Create AVAssetWriter input for video, based on the output settings from the Assistant
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        videoInput.expectsMediaDataInRealTime = true
        streamOutput = StreamOutput(videoInput: videoInput)
        streamOutput.videoHeight = videoSize.height
        streamOutput.videoWidth = videoSize.width

        // Adding videoInput to assetWriter
        guard assetWriter.canAdd(videoInput) else {
            throw RecordingError("Can't add input to asset writer")
        }
        assetWriter.add(videoInput)

        guard assetWriter.startWriting() else {
            if let error = assetWriter.error {
                throw error
            }
            throw RecordingError("Couldn't start writing to AVAssetWriter")
        }

        // MARK: SCStream setup

        let configuration = SCStreamConfiguration()
        // 6 was OG, testing 4.
        configuration.queueDepth = 4
        multiPrinter("Start = SCSTREAM\n")

        // Create SCStream and add local StreamOutput object to receive samples
        stream = SCStream(filter: filter, configuration: configuration, delegate: nil)
        try stream.addStreamOutput(streamOutput, type: .screen, sampleHandlerQueue: videoSampleBufferQueue)

        foundTarget = true
        multiPrinter("END Start = SCSTREAM\n")

    }

    func start() async throws {

        // Start capturing, wait for stream to start
        try await stream.startCapture()

        // Start the AVAssetWriter session at source time .zero, sample buffers will need to be re-timed
        assetWriter.startSession(atSourceTime: .zero)
        streamOutput.sessionStarted = true
    }

    func stop() async throws {

        // Stop capturing, wait for stream to stop
        try await stream.stopCapture()

        // Repeat the last frame and add it at the current time
        // In case no changes happend on screen, and the last frame is from long ago
        // This ensures the recording is of the expected length
        if let originalBuffer = streamOutput.lastSampleBuffer {
            let additionalTime = CMTime(seconds: ProcessInfo.processInfo.systemUptime, preferredTimescale: 100) - streamOutput.firstSampleTime
            let timing = CMSampleTimingInfo(duration: originalBuffer.duration, presentationTimeStamp: additionalTime, decodeTimeStamp: originalBuffer.decodeTimeStamp)
            let additionalSampleBuffer = try CMSampleBuffer(copying: originalBuffer, withNewTiming: [timing])
            videoInput.append(additionalSampleBuffer)
            streamOutput.lastSampleBuffer = additionalSampleBuffer
        }

        // Stop the AVAssetWriter session at time of the repeated frame
        assetWriter.endSession(atSourceTime: streamOutput.lastSampleBuffer?.presentationTimeStamp ?? .zero)

        // Finish writing
        videoInput.markAsFinished()
        await assetWriter.finishWriting()
    }


    private class StreamOutput: NSObject, SCStreamOutput {
        let videoInput: AVAssetWriterInput
        var sessionStarted = false
        var firstSampleTime: CMTime = .zero
        var lastSampleBuffer: CMSampleBuffer?

        var videoWidth: Int = 0
        var videoHeight: Int = 0
        var lastFrameTime: CMTime = .zero

        init(videoInput: AVAssetWriterInput) {
            self.videoInput = videoInput
        }

        func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
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
            // crop black puxels from top,bottom, left , right.
            guard let newCroppedImage = cropImage(image: cgImage, toRect: contentRect(inImage: cgImage)) else {
                print("Failed to create CGImage from CIImage")
                return
            }

            let nsImage = NSImage(cgImage: newCroppedImage, size: CGSize(width: videoWidth, height: videoHeight))
            let bitmapRep = NSBitmapImageRep(data: nsImage.tiffRepresentation!)!
            let imageData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.8])

            localPeerConsole.sendSimulatorData(imageData)
        }
        func cropImage(image: CGImage, toRect rect: CGRect) -> CGImage? {
            let croppedImage = image.cropping(to: rect)
            return croppedImage
        }
        func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {

            // Return early if session hasn't started yet
            guard sessionStarted else { return }

            // Return early if the sample buffer is invalid
            guard sampleBuffer.isValid else { return }

            // Retrieve the array of metadata attachments from the sample buffer
            guard let attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
                  let attachments = attachmentsArray.first
            else { return }

            // Validate the status of the frame. If it isn't `.complete`, return
            guard let statusRawValue = attachments[SCStreamFrameInfo.status] as? Int,
                  let status = SCFrameStatus(rawValue: statusRawValue),
                  status == .complete
            else { return }

            switch type {
            case .screen:
                if videoInput.isReadyForMoreMediaData {

                    // Only send 1 frame per second over the websocket.
                    let currentTime = CMTimeGetSeconds(sampleBuffer.presentationTimeStamp)
                    let lastFrameTimeSeconds = CMTimeGetSeconds(lastFrameTime)
                    if currentTime - lastFrameTimeSeconds >= frameInterval {

                        processSampleBuffer(sampleBuffer)

                        lastFrameTime = sampleBuffer.presentationTimeStamp
                    }


                    // Save the timestamp of the current sample, all future samples will be offset by this
                    if firstSampleTime == .zero {
                        firstSampleTime = sampleBuffer.presentationTimeStamp
                    }

                    // Offset the time of the sample buffer, relative to the first sample
                    let lastSampleTime = sampleBuffer.presentationTimeStamp - firstSampleTime

                    // Always save the last sample buffer.
                    // This is used to "fill up" empty space at the end of the recording.
                    //
                    // Note that this permanently captures one of the sample buffers
                    // from the ScreenCaptureKit queue.
                    // Make sure reserve enough in SCStreamConfiguration.queueDepth
                    lastSampleBuffer = sampleBuffer

                    // Create a new CMSampleBuffer by copying the original, and applying the new presentationTimeStamp
                    let timing = CMSampleTimingInfo(duration: sampleBuffer.duration, presentationTimeStamp: lastSampleTime, decodeTimeStamp: sampleBuffer.decodeTimeStamp)
                    if let retimedSampleBuffer = try? CMSampleBuffer(copying: sampleBuffer, withNewTiming: [timing]) {
                        videoInput.append(retimedSampleBuffer)
                    } else {
                        print("Couldn't copy CMSampleBuffer, dropping frame")
                    }
                } else {
                    print("AVAssetWriterInput isn't ready, dropping frame")
                }

            case .audio:
                break

            @unknown default:
                break
            }
        }
    }
}

// AVAssetWriterInput supports maximum resolution of 4096x2304 for H.264
private func downsizedVideoSize(source: CGSize, scaleFactor: Int) -> (width: Int, height: Int) {
    let maxSize = CGSize(width: 4096, height: 2304)

    let w = source.width * Double(scaleFactor)
    let h = source.height * Double(scaleFactor)
    let r = max(w / maxSize.width, h / maxSize.height)

    return r > 1
    ? (width: Int(w / r), height: Int(h / r))
    : (width: Int(w), height: Int(h))
}

struct RecordingError: Error, CustomDebugStringConvertible {
    var debugDescription: String
    init(_ debugDescription: String) { self.debugDescription = debugDescription }
}
extension SCWindow {
    var displayName: String {
        switch (owningApplication, title) {
        case (.some(let application), .some(let title)):
            return "\(application.applicationName): \(title)"
        case (.none, .some(let title)):
            return title
        case (.some(let application), .none):
            return "\(application.applicationName): \(windowID)"
        default:
            return ""
        }
    }
}

extension SCDisplay {
    var displayName: String {
        "Display: \(width) x \(height)"
    }
}
