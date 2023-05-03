//
//  Speak.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/29/23.
//

import Foundation
import AVFoundation
let speechSynthesizer = AVSpeechSynthesizer()


struct VoicePair: Hashable {

    let voiceName: String
    let voiceIdentifier : String
}

func speak(_ text: String) {
    if !SettingsViewModel.shared.voiceOutputenabled {
        //print("DONT say: \(text)")
        //consoleManager.print("say: \(text)")
        return
    }
    let speechUtterance = AVSpeechUtterance(string: text)

#if !targetEnvironment(simulator)
    if let customVoice = SettingsViewModel.shared.selectedVoice?.voiceIdentifier {
        speechUtterance.voice = AVSpeechSynthesisVoice(identifier: customVoice)

    }
    else {
        speechUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Ava")
    }

   // speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
#endif
    // Optional: Set properties like voice, pitch, rate, or volume if desired
    // speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    // speechUtterance.pitchMultiplier = 1.0
    // speechUtterance.rate = 0.5
    // speechUtterance.volume = 0.8

    speechSynthesizer.speak(speechUtterance)
}
func stopVoice() {
    speechSynthesizer.stopSpeaking(at: .immediate)
}
func configureAudioSession() {
#if !os(macOS)
    if SettingsViewModel.shared.voiceOutputenabled {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
            try audioSession.setActive(true)

        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
#endif
}

func printVoicesInMyDevice() {
#if !os(macOS)
    var installedVoices = [VoicePair]()
    for voice in installedVoiesArr() {
        installedVoices += [ VoicePair(voiceName: voice.name, voiceIdentifier: voice.identifier)]
    }

    installedVoices.sort { $0.voiceName < $1.voiceName }

    SettingsViewModel.shared.installedVoices = installedVoices.sorted {
        if $0.voiceName.contains("Premium") || $0.voiceName.contains("Enhanced")  {
            return $0.voiceName > $1.voiceName
        }
        return $0.voiceName < $1.voiceName
    }
#endif

}

func  installedVoiesArr() -> [AVSpeechSynthesisVoice]  {
    var ret = [AVSpeechSynthesisVoice]()
    AVSpeechSynthesisVoice.speechVoices().forEach {

        ret.append($0)

    }
    return ret
}

func requestMicrophoneAccess(completion: @escaping (Bool) -> Void) {
#if !os(macOS)

    let audioSession = AVAudioSession.sharedInstance()
    audioSession.requestRecordPermission { granted in
        DispatchQueue.main.async {
            completion(granted)
        }
    }
#endif

}
