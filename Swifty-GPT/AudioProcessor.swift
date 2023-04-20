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
var audioRecorder: AudioRecorder?

func voice() -> String {
    if chosenVoice == nil {
        chosenVoice = randomVoice()
    }
    return chosenVoice!
}

var defaultVoice = "Rishi"
// var defaultVoice = "Karen"


func randomVoice() -> String {
    // SERIOUS VOICES
    [defaultVoice].randomElement()! //"Zarvox", "Trinoids", "Rishi"].randomElement()!

   // ["Karen"].randomElement()!

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

        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)"
        let tempAudioPath = "\(projectPath)/audio-\(UUID())\(tempAudioRecordingFileFormat)"

        self.outputTempFileURL = URL(fileURLWithPath:tempAudioPath)
    }

    func startRecording() {

        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceFirstName)"
        let audioFilePath = "\(projectPath)/audio-\(UUID())\(audioRecordingFileFormat)"
        let audioOut = URL(fileURLWithPath: audioFilePath)
        self.outputFileURL = audioOut
        
        let tempAudioPath = "\(projectPath)/audio-\(UUID())\(tempAudioRecordingFileFormat)"
        self.outputTempFileURL = URL(fileURLWithPath:tempAudioPath)


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

    func stopRecording(completion: @escaping (Bool) -> Void) {
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
                completion(true)

            case .failed:
                print("Export failed: \(String(describing: exportSession.error))")
                completion(false)
            case .cancelled:
                print("Export cancelled")
                completion(false)
            default:
                completion(false)
            }
        }
    }
}

func requestMicrophoneAccess(completion: @escaping (Bool) -> Void) {
    AVCaptureDevice.requestAccess(for: .audio) { granted in
        DispatchQueue.main.async {
            completion(granted)
        }
    }
}
