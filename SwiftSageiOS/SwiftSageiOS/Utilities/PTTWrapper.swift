//
//  PTTWrapper.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/2/23.
//

import Foundation
import PushToTalk
import AVFoundation

// TODO: PUSH TO TALK
#if !os(macOS)

class PTTWrapper: NSObject, PTChannelManagerDelegate, PTChannelRestorationDelegate {


    var channelManager: PTChannelManager?

    let shared = PTTWrapper()
    func setUpPTT() async {
        do {
            channelManager = try await PTChannelManager.channelManager(delegate: self,
                                                                       restorationDelegate: self)
        }
        catch {
            logD("error w ptt = \(error)")
        }
    }


    func channelManager(_ channelManager: PTChannelManager, didJoinChannel channelUUID: UUID, reason: PTChannelJoinReason) {

    }

    func channelManager(_ channelManager: PTChannelManager, didLeaveChannel channelUUID: UUID, reason: PTChannelLeaveReason) {

    }

    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didBeginTransmittingFrom source: PTChannelTransmitRequestSource) {
    }

    func channelManager(_ channelManager: PTChannelManager, channelUUID: UUID, didEndTransmittingFrom source: PTChannelTransmitRequestSource) {
    }

    func channelManager(_ channelManager: PTChannelManager, receivedEphemeralPushToken pushToken: Data) {

    }

    func incomingPushResult(channelManager: PTChannelManager, channelUUID: UUID, pushPayload: [String : Any]) -> PTPushResult {
        return .leaveChannel
    }

    func channelManager(_ channelManager: PTChannelManager, didActivate audioSession: AVAudioSession) {
    }

    func channelManager(_ channelManager: PTChannelManager, didDeactivate audioSession: AVAudioSession) {

    }
    func channelDescriptor(restoredChannelUUID channelUUID: UUID) -> PTChannelDescriptor {
        PTChannelDescriptor(name: "SwiftSage", image: nil)
    }

}
#endif
