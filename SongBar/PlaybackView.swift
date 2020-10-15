//
//  PlaybackView.swift
//  SongBar
//
//  Created by Justin Oakes on 10/12/20.
//  Copyright © 2020 corpe. All rights reserved.
//

import Cocoa
import Kingfisher

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
    private var spotifyArtworkObserver: NSKeyValueObservation?
    private var iTunesArtworkObserver: NSKeyValueObservation?
    
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
                                                        let attributedTitle = self.attributedText(from: name.newValue ?? "")
                                                        self.titleTextField.attributedStringValue = attributedTitle
                                                     })
        artistObserver = playbackListner.observe(\PlaybackListner.artistName,
                                                  options: .new,
                                                  changeHandler: { (listner, artist) in
                                                    let attributeedArtist = self.attributedText(from: artist.newValue ?? "", withSize: 18.0)
                                                    self.artistTextField.attributedStringValue = attributeedArtist
                                                  })
        spotifyArtworkObserver = playbackListner.observe(\PlaybackListner.spotifyArtworkURL,
                                                         options: .new,
                                                         changeHandler: { (listner, url) in
                                                            guard let url = url.newValue else {
                                                                self.imageView.image = nil
                                                                return
                                                            }
                                                            self.imageView.kf.setImage(with: URL(string: url))
                                                         })
        iTunesArtworkObserver = playbackListner.observe(\PlaybackListner.iTunesArt,
                                                        options: .new,
                                                        changeHandler: { (listner, image) in
                                                            self.imageView.image = image.newValue
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
    
    private func attributedText(from string: String, withSize fontSize: CGFloat = 24.0) -> NSAttributedString {
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .center
        let attributedString = NSAttributedString(string: string,
                                                  attributes: [.strokeWidth : -1.0,
                                                               .strokeColor : NSColor.white,
                                                               .foregroundColor : NSColor.black,
                                                               .paragraphStyle : pStyle,
                                                               .font : NSFont.boldSystemFont(ofSize: fontSize)])
        return attributedString
    }
}
