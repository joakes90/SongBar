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

}
