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

    @objc dynamic var menuTitle: String { "Songbar" }

    @objc dynamic var trackName: String { "" }

    @objc dynamic var artistName: String { "" }

    @objc dynamic var art: NSImage { NSImage() }

    @objc dynamic var playbackState: NSNumber { 0 }

    @objc dynamic var playbackHeadPosition: NSNumber { 0.0 }

    func populateMusicData() {
        print("populate")
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
