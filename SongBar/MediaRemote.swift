//
//  MediaRemote.swift
//  SongBar
//
//  Created by Justin Oakes on 11/8/21.
//  Copyright © 2021 corpe. All rights reserved.
//

import Cocoa
import Kingfisher

@objc class MediaRemoteListner: NSObject, MediaWatching {

    private let mediaRemoteBundle: CFBundle

    private let titleString = "SongBar"

    @objc dynamic var menuTitle: String = ""

    @objc dynamic var trackName: String = ""

    @objc dynamic var artistName: String = ""

    @objc dynamic var art: NSImage = NSImage(imageLiteralResourceName: "missingArtwork")

    @objc dynamic var playbackState: NSNumber = 0

    @objc dynamic var playbackHeadPosition: NSNumber = 0

    // Listen to Notifications
    private typealias MRMediaRemoteRegisterForNowPlayingNotificationsFunction = @convention(c) (DispatchQueue) -> Void // swiftlint:disable:this type_name
    private let MRMediaRemoteRegisterForNowPlayingNotificationsPointer: UnsafeMutableRawPointer // swiftlint:disable:this identifier_name
    private let MRMediaRemoteRegisterForNowPlayingNotifications: MRMediaRemoteRegisterForNowPlayingNotificationsFunction // swiftlint:disable:this identifier_name

    // Get now playing
    private typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    private let MRMediaRemoteGetNowPlayingInfoPointer: UnsafeMutableRawPointer
    private let MRMediaRemoteGetNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction

    // Get is playing
    private typealias MRMediaRemoteGetNowPlayingApplicationPlaybackStateFunction = @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void
    private let MRMediaRemoteGetNowPlayingApplicationPlaybackStatePointer: UnsafeMutableRawPointer
    private let MRMediaRemoteGetNowPlayingApplicationPlaybackState: MRMediaRemoteGetNowPlayingApplicationPlaybackStateFunction

    override init() {
        // link to media remote framework
        mediaRemoteBundle =  CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

        // configure now playing function
        MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
        MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)

        // configure playback state function
        MRMediaRemoteGetNowPlayingApplicationPlaybackStatePointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString)
        MRMediaRemoteGetNowPlayingApplicationPlaybackState = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationPlaybackStatePointer, to: MRMediaRemoteGetNowPlayingApplicationPlaybackStateFunction.self)
        
        // configure register for notifications function
        MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString)
        MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: MRMediaRemoteRegisterForNowPlayingNotificationsFunction.self)

        super.init()

        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nowPlayingDidUpdate(_:)),
                                               name: .mediaRemoteNowPlayingInfoDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(isPlayingDidUpdate(_:)),
                                               name: .mediaRemoteNowPlayingApplicationPlaybackStateDidChange,
                                               object: nil)

    }

    func populateMusicData() {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { [weak self] (information) in
            guard let self = self else { return }
            self.trackName = self.currentTrackName(from: information)
            self.artistName = self.currentArtistName(from: information)
            self.menuTitle = self.currentMenuTitle(from: information)
            self.art = self.currentArt(from: information)
        })
        // TODO: Get playback state
        MRMediaRemoteGetNowPlayingApplicationPlaybackState(DispatchQueue.main, { [weak self] (information) in
            guard let self = self else { return }
            print(information)
        })
    }

    func pausePlayPlayback() {
        print("play pause")
    }

    func rewindPlayback() {
        print("rewind")
    }

    func fastForwardPlayback() {
        print("fastforward")
    }

    func incrementPlayHeadPosition() {
        print("increment")
    }

    func setPlaybacktoWithPercentage(_ percentage: NSNumber) {
        print("set play head")
    }

    func playbackHeadPosition(at percentage: NSNumber, in track: MusicTrack) -> NSNumber {
        return NSNumber(value: 42)
    }

    func playbackHeadPercentage(for track: MusicTrack, in application: MusicApplication) -> NSNumber {
        return NSNumber(value: 42)
    }

    func setPlaybackto(percentage: NSNumber) {
        print("set playback")
    }

}

// Media data lookup
private extension MediaRemoteListner {

    func currentTrackName(from metaData: [String: Any]) -> String {
        return metaData["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? titleString
    }

    func currentArtistName(from metaData: [String: Any]) -> String {
        metaData["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
    }

    func currentMenuTitle(from metaData: [String: Any]) -> String {
        // TODO: shorten to correct length
        let trackName = currentTrackName(from: metaData)
        let artistName = currentArtistName(from: metaData)
        if !artistName.isEmpty {
            return "\(trackName) - \(artistName)"
        }
        return trackName
    }

    func currentArt(from metaData: [String: Any]) -> NSImage {
        if let artworkData = metaData["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
           return NSImage(data: artworkData) ?? NSImage(imageLiteralResourceName: "missingArtwork")
        } else {
            return NSImage(imageLiteralResourceName: "missingArtwork")
        }
    }
}

// Notification handling
private extension MediaRemoteListner {

    @objc func nowPlayingDidUpdate(_ notification: NSNotification) {
        print("updated")
        populateMusicData()
    }

    @objc func isPlayingDidUpdate(_ notification: NSNotification) {
        print("play/pause")
        guard let info = notification.userInfo as! [String: Any]? else {
            return
        }
        let systemPlaybackState = (info["kMRMediaRemotePlaybackStateUserInfoKey"] as? Int)
        print(systemPlaybackState)
    }
}

private extension Notification.Name {
    static let mediaRemoteNowPlayingInfoDidChange = Notification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification")
    static let mediaRemoteNowPlayingApplicationPlaybackStateDidChange = Notification.Name("kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification")
// swiftlint:disable:previous identifier_name
}
