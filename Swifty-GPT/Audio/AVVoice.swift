//
//  AVVoice.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/22/23.
//

import Foundation
import AVFoundation

func  installedVoiesArr() -> [AVSpeechSynthesisVoice]  {
    var ret = [AVSpeechSynthesisVoice]()
    AVSpeechSynthesisVoice.speechVoices().forEach {

        ret.append($0)

    }
    return ret
}
