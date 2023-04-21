//
//  SwiftyGPTTests.swift
//  SwiftyGPTTests
//
//  Created by Chris Dillard on 4/20/23.
//

import XCTest
import SourceKittenFramework

@testable import Swifty_GPT

final class SwiftyGPTTests: XCTestCase {
    // MARK: - Properties
    private var swiftyGPT: SwiftyGPT!

    // MARK: - Setup and Teardown
    override func setUp() {
        super.setUp()
        swiftyGPT = SwiftyGPT()
    }

    override func tearDown() {
        swiftyGPT = nil
        super.tearDown()
    }

    // MARK: - Test Cases
    func testCreateFixItPrompt() {
        let errors = ["Error 1", "Error 2"]
        let currentRetry = 1
        let result = swiftyGPT.createFixItPrompt(errors: errors, currentRetry: currentRetry)

        XCTAssertTrue(result.contains("Error 1"))
        XCTAssertTrue(result.contains("Error 2"))
    }

    func testCreateIdeaPrompt() {
        let command = "Build an iOS app"
        let result = swiftyGPT.createIdeaPrompt(command: command)

        XCTAssertTrue(result.contains("Build an iOS app"))
    }

    func testGenerateCodeUntilSuccessfulCompilation() {
        let expectation = self.expectation(description: "Waiting for successful compilation")

        swiftyGPT.generateCodeUntilSuccessfulCompilation(prompt: "Create a simple iOS app", retryLimit: 3, currentRetry: 0, errors: []) { response in
            XCTAssertNotNil(response)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 60, handler: nil)
    }
}

extension SwiftyGPTTests {
    static var allTests = [
        ("testCreateFixItPrompt", testCreateFixItPrompt),
        ("testCreateIdeaPrompt", testCreateIdeaPrompt),
        ("testGenerateCodeUntilSuccessfulCompilation", testGenerateCodeUntilSuccessfulCompilation),
    ]
}
