//
//  PlaybackMenuItem.swift
//  SongBar
//
//  Created by Justin Oakes on 10/13/20.
//  Copyright © 2020 corpe. All rights reserved.
//

import Cocoa

class PlaybackMenuItem: NSMenuItem {

    private var playbackView: PlaybackView? {
        view as? PlaybackView
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        Task {
            await MainActor.run {
                let playbackView = PlaybackView(frame: NSRect(x: 0.0,
                                                              y: 0.0,
                                                              width: 420.0,
                                                              height: 420.0))
                view = playbackView
            }
        }
    }
}

extension PlaybackMenuItem: NSMenuDelegate {
    @MainActor
    func menuWillOpen(_ menu: NSMenu) {
        playbackView?.beginPlayheadPolling()
    }

    @MainActor
    func menuDidClose(_ menu: NSMenu) {
        playbackView?.endPlayheadPolling()
    }
}
