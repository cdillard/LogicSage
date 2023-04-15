//
//  AudioProcessor.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation
import AVFoundation



// LISTEN
class AudioInputHandler: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private var audioFile: AVAudioFile?

    init(outputFileURL: URL) {
        super.init()

        do {
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)
            audioFile = try AVAudioFile(forWriting: outputFileURL, settings: format!.settings)

            let captureDevice = AVCaptureDevice.default(for: .audio)
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(captureDeviceInput)

            let captureAudioDataOutput = AVCaptureAudioDataOutput()
            let queue = DispatchQueue(label: "audioQueue")
            captureAudioDataOutput.setSampleBufferDelegate(self, queue: queue)
            captureSession.addOutput(captureAudioDataOutput)
        } catch {
            print("Error initializing audio capture: \(error)")
        }
    }

    func start() {
        captureSession.startRunning()
    }

    func stop() {
        captureSession.stopRunning()
        audioFile = nil
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let audioFile = audioFile else { return }

        var blockBuffer: CMBlockBuffer?
        var audioBufferList = AudioBufferList()
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: &audioBufferList,
            bufferListSize: MemoryLayout<AudioBufferList>.size,
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: 0,
            blockBufferOut: &blockBuffer
        )

        let buffer: AudioBuffer = audioBufferList.mBuffers

        do {
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(buffer.mDataByteSize) / audioFile.processingFormat.streamDescription.pointee.mBytesPerFrame)!
            audioBuffer.frameLength = UInt32(buffer.mDataByteSize) / audioFile.processingFormat.streamDescription.pointee.mBytesPerFrame
            memcpy(audioBuffer.mutableAudioBufferList.pointee.mBuffers.mData, buffer.mData, Int(buffer.mDataByteSize))
            try audioFile.write(from: audioBuffer)
        } catch {
            print("Error writing to audio file: \(error)")
        }
    }

}


// SPEAK
func runTest() {
    textToSpeech(text: "Hello, this is a test.")
}

func textToSpeech(text: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/say")
    task.arguments = [text]

    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        print("Error running text-to-speech: \(error)")
    }
}
