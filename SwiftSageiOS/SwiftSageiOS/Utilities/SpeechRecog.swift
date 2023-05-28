//
//  SpeechRecog.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/30/23.
//

import Foundation
import SwiftUI
import Speech

let recogDelay: CGFloat = 2.0

class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var stopTimer: Timer?
    override init() {
        super.init()
        self.speechRecognizer.delegate = self
    }
}



extension SpeechRecognizer {
    func startRecording() {
#if !os(macOS)

        // Check if recognitionTask is running
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        // Prepare and start the audioEngine
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                SettingsViewModel.shared.recognizedText = result.bestTranscription.formattedString

                // Reset the timer every time a new result is received
                self.stopTimer?.invalidate()
                self.stopTimer = Timer.scheduledTimer(withTimeInterval: recogDelay, repeats: false) { _ in
                    self.stopRecording()
                }
            } else if let error = error {
                logD("Error: \(error.localizedDescription)")
            }
        }


        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try! audioEngine.start()

#endif

    }

    func stopRecording() {
#if !os(macOS)
        logD("Stopped recording...")
        consoleManager.print("Stopped recording...")

        logD("Spoken Command received: \(SettingsViewModel.shared.recognizedText)")
        consoleManager.print("Spoken Command received: \(SettingsViewModel.shared.recognizedText)")
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil
        SettingsViewModel.shared.isRecording = false

        // open Command mode, plop in recognizedText, tap Exec.

        
        // clear out speech regognition text after sending command
        SettingsViewModel.shared.multiLineText = SettingsViewModel.shared.recognizedText
        SettingsViewModel.shared.recognizedText = ""
#endif

    }
}
