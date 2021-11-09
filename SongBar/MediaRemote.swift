//
//  MediaRemote.swift
//  SongBar
//
//  Created by Justin Oakes on 11/8/21.
//  Copyright © 2021 corpe. All rights reserved.
//

import Cocoa
import Kingfisher

@objc protocol MediaWatching: AnyObject {
    dynamic var menuTitle: String { get }
    dynamic var trackName: String { get }
    dynamic var artistName: String { get }
    dynamic var art: NSImage { get }
    dynamic var playbackState: NSNumber { get }
    dynamic var playbackHeadPosition: Float { get }

    // Optional proerties for Apple Events implementation
    dynamic var iTunesArt: NSImage? { get }
    dynamic var spotifyArtworkURL: NSString? { get }

    func populateMusicData()
    func pausePlayPlayback()
    func rewindPlayback()
    func fastForwardPlayback()
    func incrementPlayHeadPosition()
    func setPlaybackto(percentage: NSNumber)
}

@objc class MediaRemoteListner: NSObject, MediaWatching {

    @objc dynamic var menuTitle: String { "Songbar" }

    @objc dynamic var trackName: String { "" }

    @objc dynamic var artistName: String { "" }

    @objc dynamic var art: NSImage { NSImage() }

    @objc dynamic var playbackState: NSNumber { 0 }

    @objc dynamic var playbackHeadPosition: Float { 0.0 }

    @objc dynamic var iTunesArt: NSImage?

    @objc dynamic var spotifyArtworkURL: NSString?

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

    func setPlaybackto(percentage: NSNumber) {
        print("set playback")
    }

}
