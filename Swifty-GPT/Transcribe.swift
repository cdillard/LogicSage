//
//  Transcribe.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation
import AVFoundation
import Speech

func transcribeAudioFile(url: URL, completion: @escaping (String) -> Void) {
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) else {
        print("Speech recognition not supported for the given locale")
        completion("")
        return
    }

    let request = SFSpeechURLRecognitionRequest(url: url)

    recognizer.recognitionTask(with: request) { (result, error) in
        if let error = error {
            print("Error transcribing audio: \(error)")
            completion("")
            return
        }

        guard let result = result else {
            print("No transcription result found")
            completion("")
            return
        }

        if result.isFinal {
            completion(result.bestTranscription.formattedString)
        }
    }
}
func doTranscription(on audioFileURL:URL) {
    SFSpeechRecognizer.requestAuthorization { (status) in
        if status == .authorized {

            let transcriptionSemaphore = DispatchSemaphore(value: 3)

            transcribeAudioFile(url: audioFileURL) { (transcription) in
                print("Transcription: \(transcription)")
                transcriptionSemaphore.signal()
            }

            let runLoop = RunLoop.current
            while transcriptionSemaphore.wait(timeout: .now()) == .timedOut &&
                runLoop.run(mode: .default, before: .distantFuture) {}

        } else {
            print("Speech recognition authorization denied")
        }
    }

}
