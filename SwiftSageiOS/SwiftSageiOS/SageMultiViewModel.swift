//
//  SageMultiViewModel.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/9/23.
//

import Foundation
#if !os(macOS)

class SageMultiViewModel: ObservableObject {
    @Published var windowInfo: WindowInfo
    @Published var sourceCode: String

    init(windowInfo: WindowInfo) {
        self.windowInfo = windowInfo
        self.sourceCode = windowInfo.fileContents
    }
}
#endif
