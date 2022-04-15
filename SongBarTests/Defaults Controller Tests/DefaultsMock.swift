//
//  DefaultsMock.swift
//  SongBarTests
//
//  Created by Justin Oakes on 4/15/22.
//  Copyright © 2022 joakes. All rights reserved.
//

import Foundation
import Combine
@testable import SongBar

class DefaultsMock: DefaultsProviding {

    var trackInfo: Bool = false

    var controls: Bool = false

    var license: String?

    var registeredVales = [String: Any]()

    func register(defaults: [String: Any]) {
        registeredVales = defaults
    }

    func trackInfoEnabledPublisher() -> AnyPublisher<Bool, Never> {
        CurrentValueSubject(trackEnabled)
            .eraseToAnyPublisher()
    }

    func controlsEnabledPublisher() -> AnyPublisher<Bool, Never> {
        CurrentValueSubject(controlsEnabled)
            .eraseToAnyPublisher()
    }

    func premiumFeaturesEnabledPublisher() -> AnyPublisher<Bool, Never> {
        CurrentValueSubject(premiumEnabled)
            .eraseToAnyPublisher()
    }

    func licensePublisher() -> AnyPublisher<String?, Never> {
        CurrentValueSubject(license)
            .eraseToAnyPublisher()
    }

    // Private impelmentations for the mock
    private var trackEnabled = false
    private var controlsEnabled = false
    private var premiumEnabled = false
    private var licsense: String?
}
