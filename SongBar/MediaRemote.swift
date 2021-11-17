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

    @objc dynamic var menuTitle: String = "SongBar"

    @objc dynamic var trackName: String = ""

    @objc dynamic var artistName: String = ""

    @objc dynamic var art: NSImage = NSImage(imageLiteralResourceName: "missingArtwork")

    @objc dynamic var playbackState: NSNumber = 0

    @objc dynamic var playbackHeadPosition: NSNumber = 0

    private let mediaRemoteBundle: CFBundle

    // Get now playing
    private typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    private let MRMediaRemoteGetNowPlayingInfoPointer: UnsafeMutableRawPointer
    private let MRMediaRemoteGetNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction

    override init() {
        mediaRemoteBundle =  CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
        MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
        MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        super.init()
    }

    func populateMusicData() {
        print("populate")

        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { [weak self] (information) in
            guard let trackName = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String else {
                self?.setValue("SongBar", forKey: "menuTitle")
                self?.setValue("SongBar", forKey: "trackName")
                self?.setValue(nil, forKey: "artistName")
                self?.setValue(NSImage(imageLiteralResourceName: "missingArtwork"), forKey: "art")
                return
            }
            // TODO: Break this out and make sure it's the correct length or shorter
            if let artistName = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
                self?.artistName = artistName
                let menuTitle = "\(trackName) - \(artistName)"
                self?.menuTitle = menuTitle
            } else {
                self?.menuTitle = trackName
                self?.artistName = ""
            }
            if let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data,
               let image = NSImage(data: artworkData) {
                self?.art = image
            } else {
                let image = NSImage(imageLiteralResourceName: "missingArtwork")
                self?.setValue(image, forKey: "art")
            }
            self?.setValue(trackName, forKey: "trackName")
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
