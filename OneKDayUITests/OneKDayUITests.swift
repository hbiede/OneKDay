//
//  OneKDayUITests.swift
//  OneKDayUITests
//
//  Created by Hundter Biede on 11/15/22.
//

import XCTest

class WhatsNextUITests: XCTestCase {

    override func setUpWithError() throws {
        super.setUp()
        continueAfterFailure = false
    }

    // swiftlint:disable function_body_length
    func testSnapshots() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        app.activate()

        let lang = getLanguage()
        UserDefaults.standard.set(lang, forKey: "i18n_language")
        UserDefaults.standard.set(lang, forKey: "app_lang")

        snapshot("1Main")

        XCTAssertGreaterThan(app.cells.count, 0)
    }
    // swiftlint:enable function_body_length

    // Uncomment when not using as a snapshot scheme
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
