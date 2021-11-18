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
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { [weak self] (information) in
            guard let self = self else { return }
            self.trackName = self.currentTrackName(from: information)
            self.artistName = self.currentArtistName(from: information)
            self.menuTitle = self.currentMenuTitle(from: information)
            self.art = self.currentArt(from: information)
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

private extension MediaRemoteListner {

    func currentTrackName(from metaData: [String: Any]) -> String {
        return metaData["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? titleString
    }

    func currentArtistName(from metaData: [String: Any]) -> String {
        metaData["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
    }

    func currentMenuTitle(from metaData: [String: Any]) -> String {
        let trackName = currentTrackName(from: metaData)
        let artistName = currentArtistName(from: metaData)
        if artistName.isEmpty {
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
