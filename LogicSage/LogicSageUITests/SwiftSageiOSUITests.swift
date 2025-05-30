//
//  LogicSageUITests.swift
//  LogicSageUITests
//
//  Created by Chris Dillard on 5/16/23.
//

import XCTest
//
final class SwiftSageiOSUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testNewAnimatedButton() throws {
        let app = XCUIApplication()
        app.launch()

        // It's good practice to wait for a key element to ensure the UI is ready.
        // Let's assume the main conversation view or a specific element within it appears.
        // If the "ConvoView" or a specific text field is consistently present, wait for it.
        // For now, we'll use a generic predicate for *any* button on the screen,
        // as the new button itself should be present shortly after launch if a window opens.
        // A more specific element would be better in a complex app.
        let initialElementPredicate = NSPredicate(format: "exists == 1")
        let expectation = XCTNSPredicateExpectation(predicate: initialElementPredicate, object: app.windows.firstMatch) // Check if any window exists
        guard XCTWaiter.wait(for: [expectation], timeout: 10) == .completed else {
            XCTFail("App did not load main UI in time.")
            return
        }

        let newButton = app.buttons["newAnimatedButton"]

        // Verify the button exists and is hittable before tapping
        XCTAssertTrue(newButton.exists, "The new animated button should exist on screen.")
        XCTAssertTrue(newButton.isHittable, "The new animated button should be hittable.")

        newButton.tap()

        // Wait for a short period to allow the animation to theoretically complete.
        // In a real scenario with more complex animations or state changes,
        // you'd ideally wait for a specific condition related to the animation's outcome.
        // Since this animation is purely visual and brief, a small fixed delay is a pragmatic approach.
        let _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Wait for animation")], timeout: 1.0) // 0.5s for animation + buffer

        // Verify the button still exists and is hittable after the tap and animation
        XCTAssertTrue(newButton.exists, "The new animated button should still exist after tap.")
        XCTAssertTrue(newButton.isHittable, "The new animated button should still be hittable after tap and animation.")
    }
}
