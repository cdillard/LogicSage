//
//  SettingsViewModelTests.swift
//  LogicSageTests
//
//  Created by Chris Dillard on 5/16/23.
//

import Foundation
import XCTest

@testable import LogicSageDev

class SettingsViewModelTests: XCTestCase {
    var sut: SettingsViewModel!

    override func setUp() {
        super.setUp()
        sut = SettingsViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testToggleTheme() {
        // TODO: Implement this
    }
}
