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
    private var settings: NSWindow?

    #if APPSTORE
        @objc dynamic var playbackListener: MediaWatching? = PlaybackListener()
    #else
        @objc dynamic var playbackListener: MediaWatching? = MediaRemoteListner()
    #endif

    var sysBar: NSStatusItem!
    private var menuTitleObserver: NSKeyValueObservation?
    // magic number
    private let variableStatusItemLength: CGFloat = -1

    func applicationDidFinishLaunching(_ notification: Notification) {
        sysBar = NSStatusBar.system.statusItem(withLength: variableStatusItemLength)
        sysBar.title = "SongBar"
        sysBar.menu = menu
        sysBar.isVisible = true
        menuTitleObserver = observe(\.playbackListener?.menuTitle, options: .new, changeHandler: { [weak self] _, title in
            guard let self = self,
                  let title = title.newValue else { return }
            self.sysBar.title = self.menuTitleOfMaximumLength(title: title)
        })
        playbackListener?.populateMusicData()
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

extension AppDelegate {

    @IBAction func closeApp(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    @IBAction func launchSettings(_ sender: NSMenuItem) {
        if  settings == nil {
            settings = NSWindow(contentViewController: SettingsView(nibName: "SettingsView", bundle: nil))
            settings?.minSize = CGSize(width: 480.0, height: 270.0)
            settings?.title = "Preferences"
        }
        settings?.makeKeyAndOrderFront(self)
    }
}
