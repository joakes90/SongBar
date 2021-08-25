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

    @objc dynamic var launchAtLogin = LaunchAtLogin.kvo

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

}
