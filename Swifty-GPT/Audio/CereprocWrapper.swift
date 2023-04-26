//
//  CereprocWrapper.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/23/23.
//

import Foundation

class CereProcWrapper {
    private var engine: OpaquePointer?
    private var player: OpaquePointer?

    init(voiceFile: String, licenseFile: String, rootCert: String, clientCert: String, clientKey: String) {
        engine = CPRCEN_engine_load(voiceFile, licenseFile, rootCert, clientCert, clientKey)
    }

    deinit {
        if let engine = engine {
            CPRCEN_engine_delete(engine)
        }
    }

    func speak(text: String) {
        guard let engine = engine else { return }

        let sound = CPRCEN_engine_speak(engine, text)
        player = CPRC_sc_player_new(sound!.pointee.sample_rate)

        let buffer = CPRC_sc_audio_short_disposable(sound!.pointee.wavdata, sound!.pointee.size)
        CPRC_sc_audio_cue(player, buffer)

        while CPRC_sc_audio_busy(player) != 0 {
            CPRC_sc_sleep_msecs(50)
        }

        CPRCEN_engine_clear(engine)
        if let player = player {
            CPRC_sc_player_delete(player)
        }
    }
}
