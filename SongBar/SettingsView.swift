//
//  SettingsView.swift
//  SongBar
//
//  Created by Justin Oakes on 8/6/21.
//  Copyright © 2021 corpe. All rights reserved.
//

import Cocoa
import Combine
import LaunchAtLogin
import os
import SwiftUI
import Firebase
import StoreKit

class SettingsView: NSViewController {

    @IBOutlet weak var displayTrackCheckbox: NSButton!
    @IBOutlet weak var displayControlsCheckbox: NSButton!
    @IBOutlet weak var deluxeOwnerView: NSView!
    @IBOutlet weak var purchaseView: NSView!
    @IBOutlet weak var purchaseLabel: NSTextField!
    @IBOutlet weak var registerView: NSView!
    @objc dynamic var launchAtLogin = LaunchAtLogin.kvo
    private var defaultsController = DefaultsController.shared
    private var cancelables = Set<AnyCancellable>()
    private let currencyFormater = NumberFormatter()
    private let logger = Logger(subsystem: "com.joakes.SongBar", category: "SettingsView")

    override func viewDidLoad() {
        super.viewDidLoad()

        currencyFormater.numberStyle = .currency
        currencyFormater.usesGroupingSeparator = true
        defaultsController.$isPremium
            .assign(to: \.isEnabled, on: displayTrackCheckbox)
            .store(in: &cancelables)
        defaultsController.$isPremium
            .assign(to: \.isEnabled, on: displayControlsCheckbox)
            .store(in: &cancelables)
        defaultsController.trackInfoEnabled()
            .sink { self.displayTrackCheckbox.state = $0 ? .on : .off }
            .store(in: &cancelables)
        defaultsController.controlsEnabled()
            .sink { self.displayControlsCheckbox.state = $0 ? .on : .off }
            .store(in: &cancelables)

        defaultsController.$isPremium
            .map { !$0 }
            .assign(to: \.isHidden, on: deluxeOwnerView)
            .store(in: &cancelables)

        #if APPSTORE
        logger.log("App Store specific configuration has started")
        defaultsController.$isPremium
            .assign(to: \.isHidden, on: purchaseView)
            .store(in: &cancelables)
        purchaseController.$price
            .sink {
                self.logger.log("Price information updated")
                if let number = $0 as NSNumber?,
                let formattedCurrency = self.currencyFormater.string(from: number) {
                    // This will need to be fully localized later on
                    self.purchaseLabel.stringValue = "Purchase SongBar Deluxe for \(formattedCurrency)"
                } else {
                    self.logger.error("could not retrieve price information")
                    self.purchaseView.isHidden = true
                }
            }
            .store(in: &cancelables)
        #else
        logger.log("Non App Store specific configuration has started")
        defaultsController.$isPremium
            .assign(to: \.isHidden, on: registerView)
            .store(in: &cancelables)
        #endif
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        (NSApp.delegate as? AppDelegate)?.becomeAccessory()
    }

    @IBAction func displayTrackStateDidChanges(_ sender: Any) {
        let newValue = displayTrackCheckbox.state
        switch newValue {
        case .on:
            defaultsController.setTrackValue(newValue: true)
        case .off:
            defaultsController.setTrackValue(newValue: false)
        default:
            defaultsController.setTrackValue(newValue: true)
        }
        Analytics.logEvent(event: .toggleTrackInfo, parameters: nil)
    }

    @IBAction func displayControlsStateDidChange(_ sender: Any) {
        let newValue = displayControlsCheckbox.state
        switch newValue {
        case .on:
            defaultsController.setControlsValue(newValue: true)
        case .off:
            defaultsController.setControlsValue(newValue: false)
        default:
            defaultsController.setControlsValue(newValue: true)
        }
        Analytics.logEvent(event: .toggleControlls, parameters: nil)
    }

    @IBAction func didClickBuyWeb(_ sender: Any) {
        guard let url = URL(string: "https://songbar.app") else {
            return
        }
        NSWorkspace.shared.open(url)
        Analytics.logEvent(event: .launchWeb, parameters: nil)
    }

    @IBAction func didClickRegister(_ sender: Any) {
        (NSApp.delegate as? AppDelegate)?.displayRegistration()
    }

}

#if APPSTORE
extension SettingsView {
    private var purchaseController: PurchaseController {
        PurchaseController.shared
    }

    @IBAction func didClickBuy(_ sender: Any) {
        Task {
            do {
                try await purchaseController.purchaseDeluxe()
            } catch {
                let alert = NSAlert(error: error)
                _ = alert.runModal()
            }
        }
    }

    @IBAction func didClickRestore(_ sender: Any) {
        Task {
            do {
                try await purchaseController.restorePurchases()
            } catch {
                DispatchQueue.main.async {
                    let alert = NSAlert(error: error)
                    _ = alert.runModal()
                }

            }
        }
    }

}
#endif
