//
//  MediaRemote.swift
//  SongBar
//
//  Created by Justin Oakes on 11/8/21.
//  Copyright © 2021 corpe. All rights reserved.
//

import Cocoa
import Kingfisher

@objc protocol MediaWatching where Self: NSObject {
    var menuTitle: String { get }
    var trackName: String? { get }
    var artistName: String? { get }
    var art: NSImage { get }
    var playbackState: NSNumber { get }
    var playbackHeadPosition: Float { get }

    // Optional proerties for Apple Events implementation
    var iTunesArt: NSImage? { get }
    var spotifyArtworkURL: NSString? { get }

    func populateMusicData()
    func pausePlayPlayback()
    func rewindPlayback()
    func fastForwardPlayback()
    func incrementPlayHeadPosition()
    func setPlaybackto(percentage: NSNumber)
}

@objc class MediaRemoteListner: NSObject, MediaWatching {

    var menuTitle: String { "Songbar" }

    var trackName: String?

    var artistName: String?

    var art: NSImage { NSImage() }

    var playbackState: NSNumber { 0 }

    var playbackHeadPosition: Float { 0.0 }

    var iTunesArt: NSImage?

    var spotifyArtworkURL: NSString?

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
