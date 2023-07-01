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
extension SettingsViewModel {
    func speak(_ text: String) {
        if !SettingsViewModel.shared.voiceOutputEnabled {
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

        #if os(xrOS)
        speechUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-AU.Karen")
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
//#else
//            configureAudioExperience()
//#endif

        }
    }
//    enum Presentation {
//        /// Indicates to present the player as a child of a parent user interface.
//        case inline
//        /// Indicates to present the player in full-screen exclusive mode.
//        case fullScreen
//    }
//    private func configureAudioExperience() {
//        #if os(xrOS)
//        do {
//            let experience: AVAudioSessionSpatialExperience = .headTracked(soundStageSize: .small, anchoringStrategy: .front)
//            try AVAudioSession.sharedInstance().setIntendedSpatialExperience(experience)
//        } catch {
//            logD("Unable to set the intended spatial experience. \(error.localizedDescription)")
//        }
//        #endif
//    }

    func printVoicesInMyDevice() {
        var installedVoices = [VoicePair]()
        for voice in installedVoiesArr() {
            installedVoices += [ VoicePair(voiceName: voice.name, voiceIdentifier: voice.identifier)]
        }
        
        installedVoices.sort { $0.voiceName < $1.voiceName }
        
        self.installedVoices = installedVoices.sorted {
            if $0.voiceName.contains("Premium") || $0.voiceName.contains("Enhanced")  {
                return $0.voiceName > $1.voiceName
            }
            return $0.voiceName < $1.voiceName
        }
        
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
