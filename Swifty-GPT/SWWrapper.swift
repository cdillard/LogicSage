//
//  SWWrapper.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

let modelName = "ggml-base.en"

//.package(url: "https://github.com/exPHAT/SwiftWhisper.git", revision: "6ed3484c5cf449041b5c9bcb3ac82455d6a586d7"),


// Download https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large.bin




//class SWWrapper:WhisperDelegate {
//    static let instance = SWWrapper()
//
//    func whisper(_ aWhisper: Whisper, didUpdateProgress progress: Double) {
//        print("whisper=\(aWhisper) progress = \(progress)")
//
//
//    }
//
//    // Any time a new segments of text have been transcribed
//    func whisper(_ aWhisper: Whisper, didProcessNewSegments segments: [Segment], atIndex index: Int) {
//        print(segments)
//    }
//
//    // Finished transcribing, includes all transcribed segments of text
//    func whisper(_ aWhisper: Whisper, didCompleteWithSegments segments: [Segment]) {
//        print(segments)
//
//    }
//
//    // Error with transcription
//    func whisper(_ aWhisper: Whisper, didErrorWith error: Error) {
//        print(error)
//    }
//}

var modalPath:String {
    get {
        if let plistPath = Bundle.main.path(forResource: modelName, ofType: "bin") {
            return plistPath
        }
        return ""
    }
}

var whisperContext: WhisperContext?

func doTranscription(on audioFileURL:URL) async {

    convertAudioFileToPCMArray(fileURL: audioFileURL) { result in
        Task {
            switch result {
            case .success(let frames):

                whisperContext = try WhisperContext.createContext(path: modalPath)

                await whisperContext?.fullTranscribe(samples: frames)

                let text = await whisperContext?.getTranscription()
                if let text = text {
                    gptCommand(input: text)
                }
                else {
                    print("failed")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

import AudioKit

func convertAudioFileToPCMArray(fileURL: URL, completionHandler: @escaping (Result<[Float], Error>) -> Void) {
    var options = FormatConverter.Options()
    options.format = .wav
    options.sampleRate = 16000
    options.bitDepth = 16
    options.channels = 1
    options.isInterleaved = false

    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
    let converter = FormatConverter(inputURL: fileURL, outputURL: tempURL, options: options)
    converter.start { error in
        if let error {
            completionHandler(.failure(error))
            return
        }
        do {
            let data = try Data(contentsOf: tempURL) // Handle error here

            let floats = stride(from: 44, to: data.count, by: 2).map {
                return data[$0..<$0 + 2].withUnsafeBytes {
                    let short = Int16(littleEndian: $0.load(as: Int16.self))
                    return max(-1.0, min(Float(short) / 32767.0, 1.0))
                }
            }
            do {
                try FileManager.default.removeItem(at: tempURL)

                completionHandler(.success(floats))
            }
            catch {
                print("great fails")
            }
        }
        catch {
            print("greater fails")

        }
    }
}

/*

 func decodeWaveFile(_ url: URL) throws -> [Float] {
     let data = try Data(contentsOf: url)
     let floats = stride(from: 44, to: data.count, by: 2).map {
         return data[$0..<$0 + 2].withUnsafeBytes {
             let short = Int16(littleEndian: $0.load(as: Int16.self))
             return max(-1.0, min(Float(short) / 32767.0, 1.0))
         }
     }
     return floats
 }
 */
