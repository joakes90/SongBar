//
//  DefaultsControllerTests.swift
//  SongBarTests
//
//  Created by Justin Oakes on 4/14/22.
//  Copyright © 2022 joakes. All rights reserved.
//

import XCTest
import Combine
@testable import SongBar

class DefaultsControllerTests: XCTestCase {

    private var sut: DefaultsController?
    private var mock: DefaultsMock?

    private var cancelables = Set<AnyCancellable>()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let newMock = DefaultsMock()
        mock = newMock
        sut = DefaultsController(newMock)
        cancelables.removeAll()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIsPremium() {
        let expectation = XCTestExpectation(description: "Publishes premium and then updates enabled options")
        var expectedValue = true
        sut?.$isPremium
            .sink(receiveValue: { value in
                if expectedValue == value {
                    XCTAssert(value)
                    expectation.fulfill()
                }
            })
            .store(in: &cancelables)
        expectedValue = true
        sut?.isPremium = expectedValue
        wait(for: [expectation], timeout: 0.5)
    }

    func testLicense() {
        let expectation = XCTestExpectation(description: "Publishes license")
        expectation.expectedFulfillmentCount = 2
        var expectedValue = ""
        sut?.$license
            .sink(receiveValue: { value in
                XCTAssert(value == expectedValue)
                expectation.fulfill()
            })
            .store(in: &cancelables)
        expectedValue = "abcd-1234"
        sut?.license = expectedValue
        wait(for: [expectation], timeout: 0.5)

    }

    func testTrackInfoEnabled() {
        let expectation = XCTestExpectation(description: "Publishes if track info is enabled")
        expectation.expectedFulfillmentCount = 2
        var expectedValue = true
        sut?.trackInfoEnabled()
            .sink(receiveValue: { value in
                XCTAssert(value == expectedValue)
                expectation.fulfill()
            })
            .store(in: &cancelables)

        sut?.isPremium = true
        expectedValue = false
        sut?.setTrackValue(newValue: false)

        sut?.trackInfoEnabled()
            .sink(receiveValue: { value in
                XCTAssert(value == expectedValue)
                expectation.fulfill()
            })
            .store(in: &cancelables)

        wait(for: [expectation], timeout: 0.5)
    }

    func testControlsEnabled() {
        let expectation = XCTestExpectation(description: "Publishes if controls are is enabled")
        expectation.expectedFulfillmentCount = 2
        var expectedValue = true
        sut?.controlsEnabled()
            .sink(receiveValue: { value in
                XCTAssert(value == expectedValue)
                expectation.fulfill()
            })
            .store(in: &cancelables)

        sut?.isPremium = true
        expectedValue = false
        sut?.setControlsValue(newValue: false)

        sut?.controlsEnabled()
            .sink(receiveValue: { value in
                XCTAssert(value == expectedValue)
                expectation.fulfill()
            })
            .store(in: &cancelables)

        wait(for: [expectation], timeout: 0.5)
    }

    func testPremiumFeaturesEnabled() {
        let expectation = XCTestExpectation(description: "Publishes if any premium features are enabled")
        expectation.expectedFulfillmentCount = 2
        var expectedValue = true

        sut?.premiumFeaturesEnabled()
            .sink(receiveValue: { value in
                XCTAssert(expectedValue == value)
                expectation.fulfill()
            })
            .store(in: &cancelables)

        sut?.isPremium = true
        expectedValue = false
        sut?.setTrackValue(newValue: false)

        sut?.premiumFeaturesEnabled()
            .sink(receiveValue: { value in
                XCTAssert(expectedValue == value)
                expectation.fulfill()
            })
            .store(in: &cancelables)

        wait(for: [expectation], timeout: 0.5)
    }

    func testUserLicense() async {
        let expectation = XCTestExpectation(description: "Publishes license value")
        expectation.expectedFulfillmentCount = 2
        var expectedValue = ""

        sut?.$license
            .sink(receiveValue: { value in
                XCTAssert(value == expectedValue)
                expectation.fulfill()
            })
            .store(in: &cancelables)

        sut?.isPremium = true
        expectedValue = "abcd-1234"
        sut?.license = "abcd-1234"

        sut?.$license
            .sink(receiveValue: { value in
                XCTAssert(value == expectedValue)
                expectation.fulfill()
            })
            .store(in: &cancelables)

        wait(for: [expectation], timeout: 0.5)
    }
}
