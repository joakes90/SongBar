//
//  DefaultsController.swift
//  SongBar
//
//  Created by Justin Oakes on 2/7/22.
//  Copyright © 2022 corpe. All rights reserved.
//

import Foundation
import Combine
import StoreKit

class DefaultsController: ObservableObject {

    static let shared = DefaultsController()
    private let userDefaults = UserDefaults.standard
    private var cancelables = Set<AnyCancellable>()
    #if APPSTORE
    private let purchaseController = PurchaseController.shared
    #endif

    @Published var isPremium: Bool = false {
        didSet {
            setTrackValue(newValue: self.isPremium ? userDefaults.trackInfo : true)
            setControlsValue(newValue: self.isPremium ? userDefaults.controls : true)
        }
    }

    @Published var license: String = ""
    @Published var email: String = ""

    init() {
        userDefaults.register(
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

        userEmail()
            .sink { string in
                self.email = string
            }
            .store(in: &cancelables)
        #if APPSTORE
        Task {
            let isPremium = await purchaseController.deluxeEnabled()
            DispatchQueue.main.async {
                self.isPremium = isPremium
            }
        }
        #else
        isPremium = licenseMatches()
        #endif
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

    func userEmail() -> AnyPublisher<String, Never> {
        userDefaults.publisher(for: \.email)
            .map { $0 ?? "" }
            .eraseToAnyPublisher()
    }

    func setTrackValue(newValue: Bool) {
        userDefaults.trackInfo = newValue
    }

    func setControlsValue(newValue: Bool) {
        userDefaults.controls = newValue
    }

    func setLicense(newValue: String) {
        userDefaults.license = newValue
    }

    func setEmail(newValue: String) {
        userDefaults.email = newValue
    }

    func licenseMatches() -> Bool {
        return license(for: email) == license
    }
}

extension UserDefaults {

    enum Keys {
        static var trackInfo = "trackInfo"
        static var controls = "controls"
        static var license = "license"
        static var email = "email"
        static var exceptions = "NSApplicationCrashOnExceptions"
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

    @objc dynamic var email: String? {
        get {
            string(forKey: Keys.email)
        }
        set {
            set(newValue, forKey: Keys.email)
        }
    }
}

private extension DefaultsController {
    func license(for string: String) -> String? {
        guard let data = string.data(using: .utf8)?.base64EncodedString() else { return nil }

        let subString = data
            .trimmingCharacters(in: .alphanumerics.inverted)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .padding(toLength: 16, withPad: "0", startingAt: 0)
            .uppercased()
            .enumerated()
            .map { ($0.isMultiple(of: 4) && $0 != 0 ? "-\($1)" : String($1)) }
            .joined()
            .prefix(19)
        return String(subString)
    }
}
