//
//  MediaRemote.swift
//  SongBar
//
//  Created by Justin Oakes on 11/8/21.
//  Copyright © 2021 corpe. All rights reserved.
//

import Foundation

protocol MediaWatching {
    var menuTitle: String? { get }
    var trackName: String? { get }
    var artistName: String? { get }
    var art: NSImage? { get }
    
    func populateMusicData()
    func pausePlayPlayback()
    func rewindPlayback()
    func fastfordwardPlayback()
    func incrementPlayHeadPosition()
    func setPlaybackto(percentage: NSNumber)
}
