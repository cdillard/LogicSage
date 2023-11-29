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


        // Remove URLS from uttered text.
        let utteredText =  removeHttpLinks(utterance: text)


        let speechUtterance = AVSpeechUtterance(string: utteredText)

        // TODO DOUBLE CHECK THESE FLAGS
        speechUtterance.prefersAssistiveTechnologySettings = false

        speechUtterance.accessibilityTraits = .startsMediaSession

        // END DOUBLE CHECK

        // MAC CATALYST TTS IS FUCKED, USE THIS INSTEAD.
#if targetEnvironment(macCatalyst)
        let custVoice = AVSpeechSynthesisVoice(language: "en-AU")
        speechUtterance.voice = custVoice
#else
#if !targetEnvironment(simulator) || os(visionOS)
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
        DispatchQueue.main.async {
            self.installedVoices = installedVoices.sorted {
                let voice0Premium = $0.voiceName.contains("Premium")
                let voice1Premium = $1.voiceName.contains("Premium")
                let voice0Enhanced = $0.voiceName.contains("Enhanced")
                let voice1Enhanced = $1.voiceName.contains("Enhanced")

                if voice0Premium, !voice1Premium {
                    return true
                } else if !voice0Premium, voice1Premium {
                    return false
                } else if voice0Enhanced, !voice1Enhanced {
                    return true
                } else if !voice0Enhanced, voice1Enhanced {
                    return false
                }

                return $0.voiceName < $1.voiceName
            }

            for voice in self.installedVoices {
                if voice.voiceName == self.voiceOutputSavedName {
                    self.selectedVoice = voice
                    return
                }
            }
            if self.selectedVoice == nil {
                self.selectedVoice = installedVoices.first
            }
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


    /// utility
    ///
    ///
    ///
    ///

    func removeHttpLinks(utterance: String) -> String {
        var text = utterance
        let pattern = #"https?:\/\/[-A-Za-z0-9._~:\/?#\[\]@!$&'()*\+,;=%]+"#

        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))

        // Loop through matches array in reverse to avoid changing the index of the following matches when removing the text
        for match in matches.reversed() {
            if let range = Range(match.range, in: text) {
                // Remove the range from the text
                text.removeSubrange(range)
            }
        }
        return text
    }
}
class SpeakerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        //print("synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        //print("speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        // print("speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        //print("speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        //print("speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance")
    }
}
