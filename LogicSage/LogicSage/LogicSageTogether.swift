/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The activity that users use to draw together.
*/

import Foundation
import GroupActivities

struct LogicSageTogether: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = NSLocalizedString("LogicSage", comment: "Code & Chat with AI Together.")
        metadata.type = .generic
        return metadata
    }
}
