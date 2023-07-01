//
//  IDProvider.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 5/24/23.
//

import Foundation
import SwiftUI

private struct DateProviderKey: EnvironmentKey {
    static let defaultValue: () -> Date = Date.init
}

extension EnvironmentValues {
    public var dateProviderValue: () -> Date {
        get { self[DateProviderKey.self] }
        set { self[DateProviderKey.self] = newValue }
    }
}

extension View {
    public func dateProviderValue(_ dateProviderValue: @escaping () -> Date) -> some View {
        environment(\.dateProviderValue, dateProviderValue)
    }
}
