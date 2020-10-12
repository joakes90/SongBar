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
    var playbackListner = PlaybackListner()
    private var playbackObserver: NSKeyValueObservation?
    var sysBar: NSStatusItem!

    //magic number
    let variableStatusItemLength: CGFloat = -1;
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        sysBar = NSStatusBar.system.statusItem(withLength: variableStatusItemLength)
        sysBar.menu = menu;
        playbackObserver = playbackListner.observe(\PlaybackListner.menuTitle,
                                options: .new) { (listner, title) in
            self.sysBar.title = title.newValue
        }
        playbackListner.refresh()
    }

}
