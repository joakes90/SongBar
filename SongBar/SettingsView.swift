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

class SettingsView: NSViewController {

    @IBOutlet weak var displayTrackCheckbox: NSButton!
    @IBOutlet weak var displayControlsCheckbox: NSButton!
    @IBOutlet weak var deluxeOwnerView: NSView!
    @IBOutlet weak var purchaseView: NSView!
    @IBOutlet weak var purchaseLabel: NSTextField!
    @objc dynamic var launchAtLogin = LaunchAtLogin.kvo
    private var defaultsController = DefaultsController.shared
    private var cancelables = Set<AnyCancellable>()
    private var purchaseController = PurchaseController.shared
    private let currencyFormater = NumberFormatter()

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

        #if APPSTORE
        defaultsController.$isPremium
            .assign(to: \.isHidden, on: purchaseView)
            .store(in: &cancelables)
        defaultsController.$isPremium
            .map { !$0 }
            .assign(to: \.isHidden, on: deluxeOwnerView)
            .store(in: &cancelables)
        purchaseController.$price
            .sink {
                if let number = $0 as NSNumber?,
                let formattedCurrency = self.currencyFormater.string(from: number) {
                    // TODO: This will need to be fully localized later on
                    self.purchaseLabel.stringValue = "Purchase SongBar Deluxe for \(formattedCurrency)"
                    self.purchaseView.isHidden = self.defaultsController.isPremium
                } else {
                    self.purchaseView.isHidden = true
                }
            }
            .store(in: &cancelables)
        #else

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
    }
    @IBAction func didClickBuy(_ sender: Any) {
        Task {
            do {
                try await purchaseController.purchaseDeluxe()
            } catch {
                // TODO: Handle error
                print(error)
            }
        }
    }

    @IBAction func didClickRestore(_ sender: Any) {
        Task {
            do {
                try await purchaseController.restorePurchases()
            } catch {
                // TODO: Handle error
                print(error)
            }
        }
    }
}
