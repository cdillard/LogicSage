//
//  AVVoice.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation
import AVFoundation

let avVoices = [
"com.apple.eloquence.en-US.Flo",
"com.apple.speech.synthesis.voice.Bahh",
"com.apple.speech.synthesis.voice.Albert",
"com.apple.speech.synthesis.voice.Fred",
"com.apple.speech.synthesis.voice.Hysterical",
"com.apple.speech.synthesis.voice.Organ",
"com.apple.speech.synthesis.voice.Cellos",
"com.apple.speech.synthesis.voice.Zarvox",
"com.apple.eloquence.en-US.Rocko",
"com.apple.eloquence.en-US.Shelley",
"com.apple.speech.synthesis.voice.Princess",
"com.apple.eloquence.en-US.Grandma",
"com.apple.eloquence.en-US.Eddy",
"com.apple.speech.synthesis.voice.Bells",
"com.apple.eloquence.en-US.Grandpa",
"com.apple.speech.synthesis.voice.Trinoids",
"com.apple.speech.synthesis.voice.Kathy",
"com.apple.eloquence.en-US.Reed",
"com.apple.speech.synthesis.voice.Boing",
"com.apple.speech.synthesis.voice.Whisper",
"com.apple.speech.synthesis.voice.GoodNews",
"com.apple.speech.synthesis.voice.Deranged",
"com.apple.ttsbundle.siri_Nicky_en-US_compact",
"com.apple.speech.synthesis.voice.BadNews",
"com.apple.ttsbundle.siri_Aaron_en-US_compact",
"com.apple.speech.synthesis.voice.Bubbles",
"com.apple.voice.compact.en-US.Samantha",
"com.apple.eloquence.en-US.Sandy",
"com.apple.speech.synthesis.voice.Junior",
"com.apple.speech.synthesis.voice.Ralph"
]
func  aiVoiceArray() -> [AVSpeechSynthesisVoice]  {
    var ret = [AVSpeechSynthesisVoice]()
    avVoices.forEach {
        guard let v = AVSpeechSynthesisVoice(identifier: $0) else { print("fail voice") ; return}

        ret.append(v)

    }
    return ret
}
