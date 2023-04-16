//
//  SWWrapper.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

let modelName = "ggml-large-v1"

//.package(url: "https://github.com/exPHAT/SwiftWhisper.git", revision: "6ed3484c5cf449041b5c9bcb3ac82455d6a586d7"),


// Download https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large.bin


import SwiftWhisper


var modalPath:String {
    get {
        if let plistPath = Bundle.main.path(forResource: modelName, ofType: "bin") {
            return plistPath
        }
        return ""
    }
}

func doTranscription(on audioFileURL:URL) async {

    convertAudioFileToPCMArray(fileURL: audioFileURL) { result in
        Task {
            switch result {
            case .success(let frames):
                let whisper = Whisper(fromFileURL:URL(fileURLWithPath: modalPath))
                let segments = try await whisper.transcribe(audioFrames:frames)

                print("Transcribed audio:", segments.map(\.text).joined())
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

        let data = try! Data(contentsOf: tempURL) // Handle error here

        let floats = stride(from: 44, to: data.count, by: 2).map {
            return data[$0..<$0 + 2].withUnsafeBytes {
                let short = Int16(littleEndian: $0.load(as: Int16.self))
                return max(-1.0, min(Float(short) / 32767.0, 1.0))
            }
        }

        try? FileManager.default.removeItem(at: tempURL)

        completionHandler(.success(floats))
    }
}
