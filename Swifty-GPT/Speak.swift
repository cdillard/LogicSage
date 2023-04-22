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


class Speak: NSObject, AVSpeechSynthesizerDelegate {

    static let shared = Speak()

    let synthesizer1 = AVSpeechSynthesizer()
    let synthesizer2 = AVSpeechSynthesizer()
    let synthesizer3 = AVSpeechSynthesizer()

    let synthesizers: [AVSpeechSynthesizer]
    let speechSemaphore: DispatchSemaphore

    override init() {
        synthesizers = [synthesizer1, synthesizer2, synthesizer3]
        speechSemaphore = DispatchSemaphore(value: synthesizers.count)
        super.init()

        synthesizers.forEach { $0.delegate = self }
    }

    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speechSemaphore.signal()
    }


    func speakText(_ text: String, _ voice: String, _ wpm: Int) {
        speechSemaphore.wait()

        DispatchQueue.global().async {
            if let availableSynthesizer = self.synthesizers.first(where: { !$0.isSpeaking }) {
                let utterance = AVSpeechUtterance(string: text)
                utterance.voice = AVSpeechSynthesisVoice(identifier: voice)

                availableSynthesizer.speak(utterance)
            } else {
                print("All synthesizers are busy.")
            }
        }
    }

}

// var sayProcess = Process()
// other way

func stopSayProcess() {
    // Send the signal to the process
    //kill(sayProcess.processIdentifier, SIGTERM)
    // TODO: Reimplement to stop ALL utterance = AVSpeechUtterance out ther ein the synth
    Speak.shared.synthesizer1.stopSpeaking(at: .immediate)
    Speak.shared.synthesizer2.stopSpeaking(at: .immediate)
    Speak.shared.synthesizer3.stopSpeaking(at: .immediate)

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

    let useVoice = overrideVoice ?? defaultVoice
    let useWpm = Int(overrideWpm ?? "") ?? 200
    print("speakk wit \(useVoice) and \(useWpm)")
    Speak.shared.speakText(text,  useVoice,  useWpm)
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
    // REIMPLMENT WITH AV AUDIO VOICES
    // TODO;
    stopSayProcess()
}
//
//func addSpeakTask(text: String, overrideVoice: String? = nil, overrideWpm: String? = nil){
//
//
//    var voice = voice()
//    if overrideVoice != nil && overrideVoice?.isEmpty == false {
//        voice = overrideVoice!
//    }
//    var useWpm = wpm
//    if overrideWpm != nil && overrideWpm?.isEmpty == false {
//        useWpm = overrideWpm!
//    }
//    print("using v = \(voice) and wpm = \(useWpm)")
// //   DispatchQueue.speechQueue.async {
//
//        print("say: \(text)")
//
//        if !voiceOutputEnabled { return }
//
//
//        Speak.shared.speakText(text, voice, Int(useWpm) ?? 200)
//   // }
//}

//extension DispatchQueue {
//    static let speechQueue = DispatchQueue(label: "speechQueue")
//}
