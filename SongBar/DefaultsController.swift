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
    private var defaultsProvider: DefaultsProviding
    private let purchaseController = PurchaseController.shared
    private var cancelables = Set<AnyCancellable>()

    @Published var isPremium: Bool = false {
        didSet {
            setTrackValue(newValue: self.isPremium ? defaultsProvider.trackInfo : true)
            setControlsValue(newValue: self.isPremium ? defaultsProvider.controls : true)
        }
    }

    @Published var license: String = ""

    init(_ defaultsProvider: DefaultsProviding = UserDefaults.standard) {
        self.defaultsProvider = defaultsProvider
        defaultsProvider.register(
            defaults: [
                UserDefaults.Keys.controls: true,
                UserDefaults.Keys.trackInfo: true,
                UserDefaults.Keys.exceptions: true
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
        defaultsProvider.trackInfoEnabledPublisher()
            .map { self.isPremium ? $0 : true}
            .eraseToAnyPublisher()
    }

    func controlsEnabled() -> AnyPublisher<Bool, Never> {
        defaultsProvider.controlsEnabledPublisher()
            .map { self.isPremium ? $0 : true }
            .eraseToAnyPublisher()
    }

    func premiumFeaturesEnabled() -> AnyPublisher<Bool, Never> {
        defaultsProvider.premiumFeaturesEnabledPublisher()
            .combineLatest(defaultsProvider.controlsEnabledPublisher())
            .map { self.isPremium ? $0 || $1 : true}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func userLicense() -> AnyPublisher<String, Never> {
        defaultsProvider.licensePublisher()
            .map { $0 ?? "" }
            .eraseToAnyPublisher()
    }

    func setTrackValue(newValue: Bool) {
        defaultsProvider.trackInfo = newValue
    }

    func setControlsValue(newValue: Bool) {
        defaultsProvider.controls = newValue
    }

    func setLicense(newValue: String) async throws {
        defaultsProvider.license = newValue
        try await purchaseController.update(with: newValue)
    }
}

protocol DefaultsProviding {
    var trackInfo: Bool { get set }
    var controls: Bool { get set }
    var license: String? { get set }

    func register(defaults: [String: Any])
    func trackInfoEnabledPublisher() -> AnyPublisher<Bool, Never>
    func controlsEnabledPublisher() -> AnyPublisher<Bool, Never>
    func premiumFeaturesEnabledPublisher() -> AnyPublisher<Bool, Never>
    func licensePublisher() -> AnyPublisher<String?, Never>
}

extension UserDefaults: DefaultsProviding {

    enum Keys {
        static var trackInfo = "trackInfo"
        static var controls = "controls"
        static var license = "license"
        static var exceptions = "NSApplicationCrashOnExceptions"
    }

    func trackInfoEnabledPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.trackInfo)
            .eraseToAnyPublisher()
    }

    func controlsEnabledPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.controls)
            .eraseToAnyPublisher()
    }

    func premiumFeaturesEnabledPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.trackInfo)
            .eraseToAnyPublisher()
    }

    func licensePublisher() -> AnyPublisher<String?, Never> {
        publisher(for: \.license)
            .eraseToAnyPublisher()
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
