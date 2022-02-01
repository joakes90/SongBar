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
        let needsRightOffset = (playedWidth > barRect(flipped: false).width - 6)
        let rect = NSRect(x: needsRightOffset ? (barRect(flipped: false).width - 6) : playedWidth - 1.0,
                          y: knobRect.origin.y + 6.0,
                          width: 12.0,
                          height: 12.0)
        #imageLiteral(resourceName: "playback_head").draw(in: rect)
    }

    override func drawBar(inside rect: NSRect, flipped: Bool) {
        let playedRect = NSRect(origin: rect.origin, size: CGSize(width: playedWidth, height: rect.height))
        let unplayedRect = NSRect(x: playedWidth, y: rect.origin.y, width: unplayedWidth, height: rect.height)
        NSColor.textColor.set()
        playedRect.fill()
        NSColor.textBackgroundColor.set()
        unplayedRect.fill()
    }

    private var playedWidth: CGFloat {
        ((CGFloat(floatValue) / 100) * self.barRect(flipped: false).width)
    }

    private var unplayedWidth: CGFloat {
        self.barRect(flipped: false).width - playedWidth
    }
}
