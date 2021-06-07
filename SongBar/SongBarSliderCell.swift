//
//  SongBarSlider.swift
//  SongBar
//
//  Created by Justin Oakes on 6/7/21.
//  Copyright © 2021 corpe. All rights reserved.
//

import Cocoa

class SongBarSliderCell: NSSliderCell {

    override func drawKnob(_ knobRect: NSRect) {
        let rect = NSRect(x: playedWidth - 8.0, y: knobRect.origin.y + 4.0, width: 16.0, height: 16.0)
        #imageLiteral(resourceName: "playback_head").draw(in: rect)
    }

    override func drawBar(inside rect: NSRect, flipped: Bool) {
        let playedRect = NSRect(origin: rect.origin, size: CGSize(width: playedWidth, height: rect.height))
        let unplayedRect = NSRect(x: playedWidth, y: rect.origin.y, width: unplayedWidth, height: rect.height)
        NSColor.darkGray.set()
        playedRect.fill()
        NSColor.lightGray.set()
        unplayedRect.fill()
    }
    
    private var playedWidth: CGFloat {
        ((CGFloat(floatValue) / 100) * self.barRect(flipped: false).width)
    }
    
    private var unplayedWidth: CGFloat {
        self.barRect(flipped: false).width - playedWidth
    }
}
