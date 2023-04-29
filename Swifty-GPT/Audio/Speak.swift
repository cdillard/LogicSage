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
import AudioKit
import CoreAudio
import AudioToolbox

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

    var count = 0


    // Stream da synth.
    let audioEngine = AudioEngine()
    var mixer = Mixer()
    var audioData = Data()
    var streamSpeaker: StreamSpeaker?

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

        if swiftSageIOSAudioStreaming {
            streamSpeaker = StreamSpeaker()
        }

    }
    func convertToData(floatChannelData: UnsafeMutablePointer<Float>, dataSize: Int) -> Data {
        let data = Data(bytes: floatChannelData, count: dataSize * MemoryLayout<Float>.size)
        return data
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

    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        stopRandomSpinner()
    }

    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // This could be used for all sorts of things like making voies not overlap
        if !hasInitializedVoiceSynth {

            // If using cereproc vs built in
            // COMMENT THIS OUT, DO NOT CHECK IN - CHRIS
            // multiPrinter("v: \(currentCereprocVoiceName())")

            hasInitializedVoiceSynth = true
        }
    }
    func speakText(_ text: String, _ voice: String, _ wpm: Int, skipLog: Bool = false) -> TimeInterval {

        let utterance = AVSpeechUtterance(string: text)
        DispatchQueue.global(qos: .background).async { [self] in
            let readySynth = synthesizers[count % synthesizers.count]

            if !skipLog {
                multiPrinter("say: " + text)
                multiPrinter("🗣️=\(text.count)...")
            }

            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.voice = AVSpeechSynthesisVoice(identifier: voice)

            // Quite nice for Flow (lol)
           //  utterance.pitchMultiplier = 0.75

            if voiceOutputEnabled {
                readySynth.speak(utterance)
                startRandomSpinner()
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

    let useVoice = overrideVoice ?? defaultVoice ?? sageVoice
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


class StreamSpeaker {
    let engine = AudioEngine()
    let mixer = Mixer()
    var blackHoleDevice: Device?

    init() {
        setupSession()

        var blackHoleDevice: Device?

        let devices = AudioEngine.outputDevices  // outputDevices is static, so you call the AudioEngine type directly, not thru an instance.
        for device in devices {
            if device.name.contains("BlackHole") {
                blackHoleDevice = device
                break
            }

        }
        if blackHoleDevice == nil {
            print("couldn't make blackhole, failing")
            return
        }


        self.blackHoleDevice = blackHoleDevice

        do {
            guard let device = self.blackHoleDevice else {
                print("blackhole failed") ; return

            }
            try engine.setDevice(device)

        } catch {
            print("errror = \(error)")
        }



        // Set up the input node
        let inputNode = engine.input!
        engine.output = mixer

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let bufferSize = AVAudioFrameCount(2048)

        inputNode.avAudioNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { buffer, time in
            guard let floatData = buffer.floatChannelData else {
                return
            }
            let data = Data(bytes: floatData[0], count: Int(buffer.frameLength) * MemoryLayout<Float>.size)
            // Handle the audio data, e.g., send it via WebSocket
            print("Sent data: \(data.count) bytes")
            localPeerConsole.webSocketClient.websocket.write(data: data)

        }
//        let inputNode = engine.inputNode
  //      let outputNode = engine.outputNode

        print("Input node format: \(inputNode.avAudioNode.inputFormat(forBus: 0))")
        print("Output node format: \(engine.output?.avAudioNode.outputFormat(forBus: 0))")

        do {
            try engine.start()
        } catch {
            print("Error starting the audio engine:", error)
        }
    }

    func setupSession() {



        // Create an instance of the Audio Unit
        var audioUnit: AudioUnit? = nil
        var audioComponentDescription = AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kAudioUnitSubType_DefaultOutput,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0)
        let audioComponent = AudioComponentFindNext(nil, &audioComponentDescription)
        AudioComponentInstanceNew(audioComponent!, &audioUnit)

        // Set the sample rate for the Audio Unit
        var sampleRate: Float64 = 44100.0
        AudioUnitSetProperty(audioUnit!, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &sampleRate, UInt32(MemoryLayout<Float64>.size))


        // Set the default input device
        var inputDeviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster
        )

        let result1 = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &inputDeviceID
        )

        if result1 != 0 {
            print("Error setting default input device: \(result1)")
        }

        // Set the default output device
        var outputDeviceID = AudioDeviceID(0)
        size = UInt32(MemoryLayout<AudioDeviceID>.size)
        address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster
        )

        let result2 = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &outputDeviceID
        )

        if result2 != 0 {
            print("Error setting default output device: \(result2)")
        }

//        // Set the sample rate
//        //var sampleRate = Float64(44100)
//        size = UInt32(MemoryLayout<Float64>.size)
//        address = AudioObjectPropertyAddress(
//            mSelector: kAudioHardwarePropertyDefaultSampleRate,
//            mScope: kAudioObjectPropertyScopeGlobal,
//            mElement: kAudioObjectPropertyElementMaster
//        )
//
//        let result = AudioObjectSetPropertyData(
//            AudioObjectID(kAudioObjectSystemObject),
//            &address,
//            0,
//            nil,
//            size,
//            &sampleRate
//        )
//
//        if result != 0 {
//            print("Error setting sample rate: \(result)")
//        }
    }
}
