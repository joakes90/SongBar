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
    private let purchaseController = PurchaseController.shared
    private var cancelables = Set<AnyCancellable>()

    @Published var isPremium: Bool = false {
        didSet {
            setTrackValue(newValue: self.isPremium ? userDefaults.trackInfo : true)
            setControlsValue(newValue: self.isPremium ? userDefaults.controls : true)
        }
    }

    @Published var license: String = ""

    init() {
        userDefaults.register(
            defaults: [
                UserDefaults.Keys.controls: true,
                UserDefaults.Keys.trackInfo: true
            ])
        userLicense()
            .sink { string in
                self.license = string
            }
            .store(in: &cancelables)

        Task {
            let isPremium = await purchaseController.deluxeEnabled()
            DispatchQueue.main.async {
                self.isPremium = isPremium
            }
        }
    }

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

    func userLicense() -> AnyPublisher<String, Never> {
        userDefaults.publisher(for: \.license)
            .map { $0 ?? "" }
            .eraseToAnyPublisher()
    }

    func setTrackValue(newValue: Bool) {
        userDefaults.trackInfo = newValue
    }

    func setControlsValue(newValue: Bool) {
        userDefaults.controls = newValue
    }

    func setLicense(newValue: String) async throws {
        userDefaults.license = newValue
        try await purchaseController.update(with: newValue)
    }
}

extension UserDefaults {

    enum Keys {
        static var trackInfo = "trackInfo"
        static var controls = "controls"
        static var license = "license"
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

    @objc dynamic var license: String? {
        get {
            string(forKey: Keys.license)
        }
        set {
            set(newValue, forKey: Keys.license)
        }
    }
}
