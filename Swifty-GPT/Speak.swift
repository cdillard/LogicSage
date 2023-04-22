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

    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("finished speech")
    }

    var count = 0

    func speakText(_ text: String, _ voice: String, _ wpm: Int) {
        DispatchQueue.global(qos: .background).async { [self] in
            let readySynth = synthesizers[count % synthesizers.count]

            print("say: " + text)
            let utterance = AVSpeechUtterance(string: text)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.voice = AVSpeechSynthesisVoice(identifier: voice)

            readySynth.speak(utterance)

            self.count += 1
        }
    }
}

func stopSayProcess() {
    shared.synthesizers.forEach {
        $0.stopSpeaking(at: .immediate)
    }
}

func runTest() {
    let hour = Calendar.current.component(.hour, from: Date())
    var greeting1 = "Welcome"
    switch hour {
    case 6..<12 : greeting1 = "Good Morning"
    case 12 : greeting1 = "It's Noon"
    case 13..<17 : greeting1 = "Good Afternoon"
    case 17..<22 : greeting1 = "Good Evening"
    default: greeting1 = "Good Night"
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h"
    // presise time setting let currentTime = dateFormatter.string(from: Date().round(precision: 60 * 60))
    textToSpeech(text: "\(welcomeWord()). \(greeting1)! I'm \( !customFemaleName.isEmpty ? customFemaleName : voice()) and I'm \(noun()).")
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

func textToSpeech(text: String, overrideVoice: String? = nil, overrideWpm: String? = nil) {

    //    var voice = voice()
    //    if overrideVoice != nil && overrideVoice?.isEmpty == false {
    //        voice = overrideVoice!
    //    }
    //    var useWpm = wpm
    //    if overrideWpm != nil && overrideWpm?.isEmpty == false {
    //        useWpm = overrideWpm!
    //    }
    //    print("using v = \(voice) and wpm = \(useWpm)")


    let useVoice = overrideVoice ?? defaultVoice
    let useWpm = Int(overrideWpm ?? "") ?? 200
    print("speakk wit \(useVoice) and \(useWpm)")
    shared.speakText(text,  useVoice,  useWpm)
}

func welcomeWord() -> String {
    if Int.random(in: 0...1) == 0 {
        return "Hi"
    }
    else {
        return "Hello"
    }
}

func killAllVoices() {
    stopSayProcess()
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
