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

    override func viewDidLoad() {
        super.viewDidLoad()
        defaultsController.$isPremium
            .assign(to: \.isEnabled, on: displayTrackCheckbox)
            .store(in: &cancelables)
        defaultsController.$isPremium
            .assign(to: \.isEnabled, on: displayControlsCheckbox)
            .store(in: &cancelables)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        (NSApp.delegate as? AppDelegate)?.becomeAccessory()
    }
}
