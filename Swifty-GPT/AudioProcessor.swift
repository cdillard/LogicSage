//
//  AudioProcessor.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation
import AVFoundation
import os.log
import AVFoundation
import CoreMedia

var chosenVoice: String?

func voice() -> String {
    if chosenVoice == nil {
        chosenVoice = randomVoice()
    }
    return chosenVoice!
}

func randomVoice() -> String {
    // SERIOUS VOICES
    ["Karen", "Zarvox", "Trinoids", "Rishi"].randomElement()!

    // FUN VOICES
//    ["Jester", "Good News", "Bubbles", "Boing", "Bad News"].randomElement()!
}

// LISTEN

let avFoundationLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AVFoundation")

let audioRecordingFileFormat = ".m4a"
let tempAudioRecordingFileFormat = ".caf"

class AudioRecorder {
    var audioEngine: AVAudioEngine!
    var outputFileURL: URL!
    var outputTempFileURL: URL!

    var audioFile: AVAudioFile!
    
    var isRunning = false

    init(outputFileURL: URL) {
        self.audioEngine = AVAudioEngine()

        self.outputFileURL = outputFileURL

        let index = Int.random(in: 0..<90000)
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)"
        let tempAudioPath = "\(projectPath)/audio-\(index)\(tempAudioRecordingFileFormat)"

        self.outputTempFileURL = URL(fileURLWithPath:tempAudioPath)
    }

    func startRecording() {
        // SEEMS LIKE CRASH OCCURS IF YOU TRY TO TALK WHEN THEY ARE
        // 2023-04-15 20:37:07.713005-0600 Swifty-GPT[64119:16301563] *** Terminating app due to uncaught exception 'com.apple.coreaudio.avfaudio', reason: 'required condition is false: format.sampleRate == hwFormat.sampleRate' wtf
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        isRunning = true
        do {
            audioFile = try AVAudioFile(forWriting: outputTempFileURL, settings: inputFormat.settings)
        } catch {
            print("Error initializing audio file: \(error)")
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] (buffer, _) in
            guard let strongSelf = self else { return }

            do {
                try strongSelf.audioFile.write(from: buffer)
            } catch {
                print("Error writing to audio file: \(error)")
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
            return
        }
    }

    func stopRecording() {
        isRunning = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        let asset = AVAsset(url: outputTempFileURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            print("Failed to create export session")
            return
        }

        exportSession.outputURL = outputFileURL
        exportSession.outputFileType = .m4a

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("Recording finished successfully")
            case .failed:
                print("Export failed: \(String(describing: exportSession.error))")
            case .cancelled:
                print("Export cancelled")
            default:
                break
            }
        }
    }
}


// Only say Swifty-GPT the fist time they open

// SPEAK


func runTest() {
    let date = Date()
    let calendar = Calendar.current

    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    textToSpeech(text: "Hi! Welcome It's about \(hour):\(minutes). I'm \(voice()) and I'll be your A.I.")
}

func textToSpeech(text: String) {
    if !voiceOutputEnabled { return }
    
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
