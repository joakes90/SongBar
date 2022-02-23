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
    @objc dynamic var launchAtLogin = LaunchAtLogin.kvo
    private var defaultsController = DefaultsController.shared
    private var cancelables = Set<AnyCancellable>()
    private var purchaseController = PurchaseController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
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
    @IBAction func purchaseDidClick(_ sender: Any) {
        Task {
            do {
                try await purchaseController.purchaseDeluxe()
            } catch {
                print(error)
            }
        }
    }
}
