//
//  SWWrapper.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/15/23.
//

import Foundation

let modelName = "ggml-small.en"


// Download https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large.bin

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
    print("Using Swift Whisper to transcribe recorded audio at \(audioFileURL)... please wait...")
    startRandomSpinner()
    convertAudioFileToPCMArray(fileURL: audioFileURL) { result in
        Task {
            switch result {
            case .success(let frames):

                whisperContext = try WhisperContext.createContext(path: modalPath)

                await whisperContext?.fullTranscribe(samples: frames)

                let text = await whisperContext?.getTranscription()
                if let text = text {
                        stopRandomSpinner()
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

import Foundation

@objc protocol SwiftProtocol {
    func helloFromSwift(input: NSString)
}

class WhisperProtocolSwift: NSObject, SwiftProtocol {
    func helloFromSwift(input: NSString) {
        gptCommand(input: input as String)
    }
}
