//
//  AppDelegate.swift
//  SongBar
//
//  Created by Kevin Cooper on 10/21/14.
//  Copyright (c) 2014 corpe. All rights reserved.
//

import Cocoa
import AppKit
import SwiftUI
import StoreKit
import Combine
import Firebase

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var updateMenuItem: NSMenuItem!
    private var settings: NSWindow?
    private var registration: NSWindow?
    private var cancelables = Set<AnyCancellable>()
    private var observers = Set<NSKeyValueObservation>()
    private var isPremium = false
    // magic number
    private let variableStatusItemLength: CGFloat = -1
    @objc dynamic var playbackListener: MediaWatching = PlaybackListener()
#if !APPSTORE
    @objc dynamic var mediaRemoteListner: MediaWatching = MediaRemoteListner()
    private let isAppstore = false
#else
    private let isAppstore = true
#endif
    var sysBar: NSStatusItem?

    @MainActor
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()
        if !isAppstore {
            updateMenuItem.isHidden = false
            DefaultsController.shared.$isPremium
                .sink(receiveValue: {
                    self.isPremium = $0
                    self.populate()
                })
                .store(in: &cancelables)
            Analytics.logEvent(event: .launchDirectDownload, parameters: nil)
        } else {
            Analytics.logEvent(event: .launchMAS, parameters: nil)
        }
        sysBar = NSStatusBar.system.statusItem(withLength: variableStatusItemLength)
        sysBar?.button?.title = "SongBar"
        sysBar?.menu = menu
        sysBar?.isVisible = true
        configureListner()
        populate()
    }

    @MainActor
    private func configureListner() {
        let playbackListenerMenuTitleObserver = observe(\.playbackListener.menuTitle, options: .new, changeHandler: { [weak self] _, title in
            guard let self = self,
                  let title = title.newValue else { return }
            if self.isAppstore || !self.isPremium {
                Task {
                    await MainActor.run {
                        self.sysBar?.button?.title = self.menuTitleOfMaximumLength(title: title)
                    }
                }
            }
        })
        observers.insert(playbackListenerMenuTitleObserver)
#if !APPSTORE
        let mediaRemoteMenuTitleObserver = observe(\.mediaRemoteListner.menuTitle, options: .new, changeHandler: { _, title in
            Task {
                await MainActor.run {
                    guard self.isPremium,
                          let title = title.newValue else { return }
                    self.sysBar?.button?.title = self.menuTitleOfMaximumLength(title: title)
                }
            }
        })
        observers.insert(mediaRemoteMenuTitleObserver)
#endif
    }

    private func populate() {
        playbackListener.populateMusicData()
#if !APPSTORE
        mediaRemoteListner.populateMusicData()
#endif
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
            settings?.title = NSLocalizedString("preferences:window:title", value: "Settings", comment: "Window title for preferences")
            settings?.styleMask = [.closable, .resizable, .titled]
        }
        NSApp.setActivationPolicy(.regular)
        NSApp.presentationOptions = []
        NSApp.activate(ignoringOtherApps: true)
        settings?.makeKeyAndOrderFront(self)
    }

    func becomeAccessory() {
        NSApp.setActivationPolicy(.accessory)
    }

    func displayRegistration() {
#if !APPSTORE
        if registration == nil {
            registration = NSWindow(contentViewController: NSHostingController(rootView: RegisterView()))
            registration?.minSize = CGSize(width: 480.0, height: 150.0)
            registration?.title = NSLocalizedString("registration:window:title", value: "Registration", comment: "Window title for registration")
            registration?.styleMask = [.closable, .resizable, .titled]
        }
        NSApp.setActivationPolicy(.regular)
        NSApp.presentationOptions = []
        NSApp.activate(ignoringOtherApps: true)
        registration?.makeKeyAndOrderFront(self)
#endif
    }
}
