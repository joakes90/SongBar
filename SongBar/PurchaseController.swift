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

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_ppUCCJCClgKiAnroBTkqUzBbuHM")
    }

    private func package() async throws -> Purchases.Package? {
        return try await Purchases.shared.offerings().current?.lifetime
    }

    func purchaseDeluxe() async throws -> Bool {
        guard let package = try await package() else { throw NSError()}
        print(Purchases.shared.appUserID)
        let transaction = try await Purchases.shared.purchasePackage(package)
        return transaction.2
    }

    func deluxeEnabled() async -> Bool {
        guard let transactions = try? await Purchases.shared.purchaserInfo().nonSubscriptionTransactions,
              let package = try? await package() else { return false }
        return transactions.contains(where: {$0.productId == package.product.productIdentifier})
    }
}
