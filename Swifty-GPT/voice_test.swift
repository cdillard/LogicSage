import AppKit

let synthesizer = NSSpeechSynthesizer()

let voices = NSSpeechSynthesizer.availableVoices


for voice in voices.reversed() {
    if let voiceName = NSSpeechSynthesizer.attributes(forVoice: voice)[.name] as? String {
        // Skip international
        if voiceName.contains("(") { continue }

                print("Voice: \(voiceName)")

        synthesizer.setVoice(voice)
        synthesizer.startSpeaking("Hi Chris, I am \(voiceName).")
        while synthesizer.isSpeaking {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
    }
}
