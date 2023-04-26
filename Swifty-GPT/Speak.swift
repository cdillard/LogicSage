//
//  Speak.swift
//  
//
//  Created by Chris Dillard on 4/15/23.
//

// Only say Swifty-GPT the fist time they open

// SPEAK

import Foundation
import AVFoundation

let wpm = "244"
let concurrentVoicesLimit = 2
var concurrentVoices = 0
let customFemaleName = "Sage"
let customMaleName = "Data"
let rateScale: Float = 0.1

let shared = Speak()

class Speak: NSObject, AVSpeechSynthesizerDelegate {

    var synthesizers: [AVSpeechSynthesizer] = []
    let synthesizerQueue = DispatchQueue(label: "com.chrisswiftygpt.SwiftSage")
    let initialSynthesizersCount = 25
    let minimumSynthesizersCount = 5
    let batchSynthesizersCount = 10
    private var timer: RepeatingTimer?
    var audioData = Data()
    override init() {

        super.init()

        synthesizers.forEach { $0.delegate = self }

        // Create the specified number of synthesizers upfront
         for _ in 0..<initialSynthesizersCount {
             let synthesizer = AVSpeechSynthesizer()
             synthesizer.delegate = self
             synthesizers.append(synthesizer)
         }

        // Start the timer
        startReplenishTimer()
    }

    private func startReplenishTimer() {

        timer = RepeatingTimer(interval: 5) {
            self.replenishSynthesizersIfNeeded()
        }
        timer?.start()

    }

    private func replenishSynthesizersIfNeeded() {
        if count + minimumSynthesizersCount >= synthesizers.count {
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.delegate = self
                synthesizers.append(synthesizer)
        }
    }
    var hasInitializedVoiceSynth = false
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // This could be used for all sorts of things like making voies not overlap
        if !hasInitializedVoiceSynth {
            multiPrinter("Voice synthesis init...")
            hasInitializedVoiceSynth = true
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakAudioBufferData buffer: AVAudioBuffer, utterance: AVSpeechUtterance) {
        // Handle the synthesized audio data
        if let pcmBuffer = buffer as? AVAudioPCMBuffer {
            let dataSize = Int(pcmBuffer.frameLength * pcmBuffer.format.streamDescription.pointee.mBytesPerFrame)

            if pcmBuffer.format.commonFormat == .pcmFormatFloat32, let floatChannelData = pcmBuffer.floatChannelData {
                let data = Data(bytes: floatChannelData.pointee, count: dataSize)
//                audioData.append(data)
                multiPrinter("pusing to websocket audio chunk len = \(data.count)")
                localPeerConsole.webSocketClient.websocket.write(data: data)
            } else if pcmBuffer.format.commonFormat == .pcmFormatInt16, let int16ChannelData = pcmBuffer.int16ChannelData {
                let data = Data(bytes: int16ChannelData.pointee, count: dataSize)
                multiPrinter("pusing to websocket audio chunk len = \(data.count)")
                localPeerConsole.webSocketClient.websocket.write(data: data)
            }
        }
        else {
            print("buf != AVAudioPCMBuffer")
        }
    }


    var count = 0

    func speakText(_ text: String, _ voice: String, _ wpm: Int, skipLog: Bool = false) -> TimeInterval {

        let utterance = AVSpeechUtterance(string: text)
        DispatchQueue.global(qos: .background).async { [self] in
            let readySynth = synthesizers[count % synthesizers.count]

            if !skipLog {
                multiPrinter("say: " + text)
            }

            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.voice = AVSpeechSynthesisVoice(identifier: voice)

            // Quite nice for Flow (lol)
           //  utterance.pitchMultiplier = 0.75

            if voiceOutputEnabled {
                readySynth.speak(utterance)
            }

            self.count += 1
        }
        return estimatedDuration(for: utterance)
    }
}

func stopSayProcess() {
    shared.synthesizers.forEach {
        $0.stopSpeaking(at: .immediate)
    }
}

func noun() -> String {
    switch Int.random(in: 0...5)
    {
    case 0:
        return  "your A.I."
    case 1:
        return "online."
    case 2:
        return "ready."
    case 3:
        return "in the mood to code.."
    case 4:
        return "here to help."
    default:
        return "here."
    }
}

public extension Date {

    func round(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .toNearestOrAwayFromZero)
    }
    
    private func round(precision: TimeInterval, rule: FloatingPointRoundingRule) -> Date {
        let seconds = (self.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision;
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
}

 func estimatedDuration(for utterance: AVSpeechUtterance) -> TimeInterval {
    let wordsPerMinute: Double = 180 // Adjust this value based on the desired words per minute
    let wordsInText = utterance.speechString.split(separator: " ").count
    let minutes = Double(wordsInText) / wordsPerMinute
    return minutes * 60
}

@discardableResult
func textToSpeech(text: String, overrideVoice: String? = nil, overrideWpm: String? = nil, skipLog: Bool = false) -> TimeInterval {

    let useVoice = overrideVoice ?? defaultVoice
    let useWpm = Int(overrideWpm ?? "") ?? 200
    return shared.speakText(text,  useVoice,  useWpm, skipLog: skipLog)
}

func welcomeWord() -> String {
    if Int.random(in: 0...1) == 0 {
        return "Hi"
    }
    else {
        return "Hello"
    }
}

class RepeatingTimer {
    private let timer: DispatchSourceTimer
    private let interval: TimeInterval

    init(interval: TimeInterval, handler: @escaping () -> Void) {
        self.interval = interval
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.setEventHandler(handler: handler)
    }

    func start() {
        timer.schedule(deadline: .now() + interval, repeating: interval)
        timer.resume()
    }

    func stop() {
        timer.cancel()
    }
}

