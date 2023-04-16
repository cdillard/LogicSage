//
//  AudioProcessor.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//


var chosenVoice: String?

func voice() -> String {
    if chosenVoice == nil {
        chosenVoice = randomVoice()
    }
    return chosenVoice!
}

func randomVoice() -> String {
    // SERIOUS VOICES
   // ["TingTing","Karen", "Zarvox", "Yuna", "Trinoids", "Rishi", "Kanya"].randomElement()!

    // FUN VOICES
    ["Jester", "Good News", "Bubbles", "Boing", "Bad News"].randomElement()!
}

// LISTEN
import Foundation
import AVFoundation
import os.log

let avFoundationLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AVFoundation")

class AudioInputHandler: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private var audioFile: AVAudioFile?
    private var outputFileURL: URL

    var isRunning = false

    init(outputFileURL: URL) {
        os_log(.info, log: avFoundationLog, "Audio subsytem initialization.")
        self.outputFileURL = outputFileURL
        super.init()

        do {
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
        print("&&&&&&&&&& STARTING CAPTURE SESSION &&&&")

        isRunning = true
        captureSession.startRunning()
    }

    func stop() {
        print("&&&&&&&&&& STOPPING CAPTURE SESSION &&&&")
        isRunning = false
        captureSession.stopRunning()
       // audioFile = nil
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100, channels: 1, interleaved: false)
        guard let settin = format?.settings else { return  print("Error initializing audio file")}
        do {
            audioFile = try AVAudioFile(forWriting: outputFileURL, settings: settin)
        } catch {
            print("Error initializing audio file: \(error)")
            return
        }

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
    textToSpeech(text: "Hi! Welcome to Swifty-GPT. I'm your debugging assistant \(voice()).")
}

func textToSpeech(text: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/say")
    task.arguments = [text, "-v", voice()]

    do {
        try task.run()
        task.waitUntilExit()
    } catch {
        print("Error running text-to-speech: \(error)")
    }
}

import AVFoundation

func requestMicrophoneAccess(completion: @escaping (Bool) -> Void) {
    AVCaptureDevice.requestAccess(for: .audio) { granted in
        DispatchQueue.main.async {
            completion(granted)
        }
    }
}
