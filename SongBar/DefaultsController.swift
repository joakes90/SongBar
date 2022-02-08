//
//  DefaultsController.swift
//  SongBar
//
//  Created by Justin Oakes on 2/7/22.
//  Copyright © 2022 corpe. All rights reserved.
//

import Foundation
import Combine

class DefaultsController: ObservableObject {

    static let shared = DefaultsController()
    private let userDefaults = UserDefaults.standard

    // This will be handled by IAP or registration check in the future
    @Published var isPremium: Bool = true

    func trackInfoEnabled() -> AnyPublisher<Bool, Never> {
        userDefaults.publisher(for: \.trackInfo)
            .map { self.isPremium ? $0 : true}
            .eraseToAnyPublisher()
    }

    func controlsEnabled() -> AnyPublisher<Bool, Never> {
        userDefaults.publisher(for: \.controls)
            .map { self.isPremium ? $0 : true }
            .eraseToAnyPublisher()
    }

    func premiumFeaturesEnabled() -> AnyPublisher<Bool, Never> {
        userDefaults.publisher(for: \.trackInfo)
            .combineLatest(userDefaults.publisher(for: \.controls))
            .map { self.isPremium ? $0 || $1 : true}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func setTrackValue(newValue: Bool) {
        userDefaults.trackInfo = newValue
    }

    func setControlsValue(newValue: Bool) {
        userDefaults.controls = newValue
    }
}

extension UserDefaults {

    enum Keys {
        static var trackInfo = "trackInfo"
        static var controls = "controls"
    }

    @objc dynamic var trackInfo: Bool {
        get {
            guard value(forKey: Keys.trackInfo) != nil else { return true }
            return bool(forKey: Keys.trackInfo)
        } set {
            set(newValue, forKey: Keys.trackInfo)
        }
    }

    @objc dynamic var controls: Bool {
        get {
            guard value(forKey: Keys.controls) != nil else { return true }
            return bool(forKey: Keys.controls)
        } set {
            set(newValue, forKey: Keys.controls)
        }
    }
}
