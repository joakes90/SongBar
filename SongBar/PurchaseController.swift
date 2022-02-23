//
//  PurchaseController.swift
//  SongBar(AppStore)
//
//  Created by Justin Oakes on 2/21/22.
//  Copyright © 2022 joakes. All rights reserved.
//

import Foundation
import Purchases

class PurchaseController {

    static let shared = PurchaseController()
    private lazy var defaultsController: DefaultsController = {
        DefaultsController.shared
    }()

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_ppUCCJCClgKiAnroBTkqUzBbuHM")
    }

    private func package() async throws -> Purchases.Package? {
        return try await Purchases.shared.offerings().current?.lifetime
    }

    func purchaseDeluxe() async throws {
        // TODO: make an error to respond to
        guard let package = try await package() else { throw NSError()}
        let transaction = try await Purchases.shared.purchasePackage(package)
        let success = transaction.1.entitlements["pro"]?.periodType == .normal
        DispatchQueue.main.async {
            self.defaultsController.isPremium = success
        }
    }

    func deluxeEnabled() async -> Bool {
        guard let transactions = try? await Purchases.shared.purchaserInfo().nonSubscriptionTransactions,
              let package = try? await package() else { return false }
        return transactions.contains(where: {$0.productId == package.product.productIdentifier})
    }
}
