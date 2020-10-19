//
//  PlaybackMenuItem.swift
//  SongBar
//
//  Created by Justin Oakes on 10/13/20.
//  Copyright © 2020 corpe. All rights reserved.
//

import Cocoa

class PlaybackMenuItem: NSMenuItem {
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        let playbackView = PlaybackView(frame: NSRect(x: 0.0,
                                                      y: 0.0,
                                                      width: 420.0,
                                                      height: 420.0))
        view = playbackView
    }
}
