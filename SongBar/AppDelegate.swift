//
//  AppDelegate.swift
//  SongBar
//
//  Created by Kevin Cooper on 10/21/14.
//  Copyright (c) 2014 corpe. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var menu: NSMenu!
    var playbackListener = PlaybackListener()
    var sysBar: NSStatusItem!
    private var menuTitleObserver: NSKeyValueObservation?
    // magic number
    private let variableStatusItemLength: CGFloat = -1

    func applicationDidFinishLaunching(_ notification: Notification) {
        sysBar = NSStatusBar.system.statusItem(withLength: variableStatusItemLength)
        sysBar.title = "SongBar"
        sysBar.menu = menu
        menuTitleObserver = playbackListener.observe(\PlaybackListener.menuTitle,
                                options: .new) { (_, title) in
            self.sysBar.title = self.menuTitleOfMaximumLength(title: title.newValue)
        }
        playbackListener.populateMusicData()
    }

    func closeApp() {
        NSApplication.shared.terminate(self)
    }

    private func menuTitleOfMaximumLength(title: String?) -> String {
        let maximumLength = 57
        let ellipsesLength = 3
        guard var title = title else { return "SongBar" }
        if title.count > maximumLength {
            let lengthToTrim = ((maximumLength + ellipsesLength) - title.count) * -1
            let startIndex = title.index(title.startIndex, offsetBy: (title.count / 2) - (lengthToTrim / 2))
            let endIndex = title.index(title.startIndex, offsetBy: (title.count / 2) + (lengthToTrim / 2))
            if startIndex < endIndex {
                title.replaceSubrange(startIndex...endIndex, with: "...")
            }
        }
        return title
    }

}
