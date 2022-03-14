//
//  PurchaseController.swift
//  SongBar(AppStore)
//
//  Created by Justin Oakes on 2/21/22.
//  Copyright © 2022 joakes. All rights reserved.
//

import Combine
import Foundation
import Purchases
import StoreKit

class PurchaseController {

    static let shared = PurchaseController()
    @Published var price: Double?
    private lazy var defaultsController: DefaultsController = {
        DefaultsController.shared
    }()

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .error
        #endif

        #if AppStore
        Purchases.configure(withAPIKey: "appl_ppUCCJCClgKiAnroBTkqUzBbuHM")
        #else
        // TODO: pull license from user defaults
        Purchases.configure(withAPIKey: "appl_ppUCCJCClgKiAnroBTkqUzBbuHM", appUserID: "C3RY-AXBL-QGV4-YW1W")
        #endif
        Task {
            let package = try? await package()
            price = package?.product.price as? Double
        }
    }

    private func package() async throws -> Purchases.Package? {
        return try await Purchases.shared.offerings().current?.lifetime
    }

    func purchaseDeluxe() async throws {
        guard let package = try await package() else { throw PurchaseErrors.packageNotAvailable}
        let transaction = try await Purchases.shared.purchasePackage(package)
        let success = transaction.1.entitlements["pro"]?.periodType == .normal
        DispatchQueue.main.async {
            self.defaultsController.isPremium = success
        }
    }

    func restorePurchases() async throws {
        let transaction = try await Purchases.shared.restoreTransactions()
        let success = transaction.entitlements["pro"]?.periodType == .normal
        if !success {
            throw PurchaseErrors.purchasesNotFound

        }
        DispatchQueue.main.async {
            self.defaultsController.isPremium = success
        }
    }

    func deluxeEnabled() async -> Bool {
        guard let _ = try? await Purchases.shared.purchaserInfo().entitlements["pro"] else { return false }
        return true
    }
}

extension PurchaseController {
    enum PurchaseErrors: LocalizedError {
        case packageNotAvailable
        case purchasesNotFound

        // TODO: Localize
        var errorDescription: String? {
            switch self {
            case .packageNotAvailable:
                return "Packages not available"
            case .purchasesNotFound:
                return "Purchases not found"
            }
        }

        var failureReason: String? {
            switch self {
            case .packageNotAvailable:
                return "SongBar Deluxe not available for purchase."
            case .purchasesNotFound:
                return "No previous purchases found"
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .packageNotAvailable:
                return "Check your network connection and try again later"
            case .purchasesNotFound:
                return "If you believe this to be an error please contact Apple support"
            }
        }

        var localizedDescription: String {
            switch self {
            case .purchasesNotFound:
                return "No previous purchases found. If you believe this to be an error please contact Apple support"
            case .packageNotAvailable:
                return "SongBar Deluxe not available for purchase. Check your network connection and try again later"
            }
        }
    }
}
