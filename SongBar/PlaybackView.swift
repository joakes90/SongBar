//
//  PlaybackView.swift
//  SongBar
//
//  Created by Justin Oakes on 10/12/20.
//  Copyright © 2020 corpe. All rights reserved.
//

import Cocoa

class PlaybackView: NSView {
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var pausePlayButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var backButton: NSButton!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var artistTextField: NSTextField!
    
    private let playbackListner = PlaybackListner()
    private var songTitleObserver: NSKeyValueObservation?
    private var artistObserver: NSKeyValueObservation?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        loadFromNib()
        titleTextField.stringValue = playbackListner.trackName
        artistTextField.stringValue = playbackListner.artistName
        songTitleObserver = playbackListner.observe(\PlaybackListner.trackName,
                                                     options: .new,
                                                     changeHandler: { (listner, name) in
                                                        self.titleTextField.stringValue = name.newValue ?? ""
                                                     })
        artistObserver = playbackListner.observe(\PlaybackListner.artistName,
                                                  options: .new,
                                                  changeHandler: { (listner, artist) in
                                                    self.artistTextField.stringValue = artist.newValue ?? ""
                                                  })
    }
    private func loadFromNib() {
        var nibObjects: NSArray?
        Bundle.main.loadNibNamed(NSNib.Name(stringLiteral: "PlaybackView"),
                                 owner: self,
                                 topLevelObjects: &nibObjects)
        let view = nibObjects?.filter({ $0 is NSView }).first as! NSView
        addSubview(view)
    }
    
}
