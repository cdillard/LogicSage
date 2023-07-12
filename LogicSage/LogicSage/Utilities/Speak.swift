//
//  Speak.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/29/23.
//

import Foundation

import AVFoundation

struct VoicePair: Hashable {
    let voiceName: String
    let voiceIdentifier : String
    let voiceLanguage : String?

}
extension SettingsViewModel {
    func speak(_ text: String) {
        if !voiceOutputEnabled {
            //print("DONT say: \(text)")
            //consoleManager.print("say: \(text)")
            return
        }
        speechSynthesizer.delegate = speakerDelegate
        
        let speechUtterance = AVSpeechUtterance(string: text)

        // TODO DOUBLE CHECK THESE FLAGS
        speechUtterance.prefersAssistiveTechnologySettings = false

        speechUtterance.accessibilityTraits = .startsMediaSession

        // END DOUBLE CHECK

        // MAC CATALYST TTS IS FUCKED, USE THIS INSTEAD.
#if targetEnvironment(macCatalyst)
            let custVoice = AVSpeechSynthesisVoice(language: "en-AU")
            speechUtterance.voice = custVoice
#else
#if !targetEnvironment(simulator)
        if let customVoice = SettingsViewModel.shared.selectedVoice?.voiceIdentifier {
            let custVoice = AVSpeechSynthesisVoice(identifier: customVoice)
            speechUtterance.voice = custVoice
        }
        else {
            let custVoice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Ava")
            
            speechUtterance.voice = custVoice
        }
#endif
#endif

        speechSynthesizer.speak(speechUtterance)
    }
    func stopVoice() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    func configureAudioSession() {
        if voiceOutputEnabled {
#if !os(macOS)
            let audioSession = AVAudioSession.sharedInstance()
            do {
                let defOpt: AVAudioSession.CategoryOptions
                if duckingAudio {
                    defOpt = AVAudioSession.CategoryOptions(arrayLiteral: [AVAudioSession.CategoryOptions.duckOthers, AVAudioSession.CategoryOptions.mixWithOthers])
                    
                }
                else {
                    defOpt = AVAudioSession.CategoryOptions(arrayLiteral: [AVAudioSession.CategoryOptions.mixWithOthers])
                }
                
                try audioSession.setCategory(.playback, mode: .spokenAudio, options: defOpt)
                try audioSession.setActive(true)
                
            } catch {
                logD("Failed to configure audio session: \(error.localizedDescription)")
            }
#endif
        }
    }
    func printVoicesInMyDevice() {
        var installedVoices = [VoicePair]()
        for voice in installedVoiesArr() {
            installedVoices += [ VoicePair(voiceName: voice.name, voiceIdentifier: voice.identifier, voiceLanguage: voice.language)]
        }
        
        installedVoices.sort { $0.voiceName < $1.voiceName }
        
        self.installedVoices = installedVoices.sorted {
            if $0.voiceName.contains("Premium") || $0.voiceName.contains("Enhanced")  {
                return $0.voiceName > $1.voiceName
            }
            return $0.voiceName < $1.voiceName
        }
//        print("INSTALLED VOICES")
//        for voice in installedVoices {
//            print(voice)
//        }

        for voice in self.installedVoices {
            if voice.voiceName == voiceOutputSavedName {
                selectedVoice = voice
                return
            }
        }
        if selectedVoice == nil {
            selectedVoice = installedVoices.first
        }
    }
    func  installedVoiesArr() -> [AVSpeechSynthesisVoice]  {
        var ret = [AVSpeechSynthesisVoice]()
        AVSpeechSynthesisVoice.speechVoices().forEach { voice in
            if ret.contains(where: { otherVoice in
                otherVoice.name == voice.name
            }) {
                
            }
            else {
                ret.append(voice)
            }
        }
        return ret
    }
}
class SpeakerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance")
    }
}
