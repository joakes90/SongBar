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
    @IBOutlet weak var playbackProgressIndicator: NSSlider!
    
    private let playbackListner = PlaybackListner()
    private var songTitleObserver: NSKeyValueObservation?
    private var artistObserver: NSKeyValueObservation?
    private var spotifyArtworkObserver: NSKeyValueObservation?
    private var iTunesArtworkObserver: NSKeyValueObservation?
    private var playbackStateObserver: NSKeyValueObservation?
    private var playHeadPositionObserver: NSKeyValueObservation?
    private var timer: Timer?

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
        
        songTitleObserver = playbackListner.observe(\PlaybackListner.trackName,
                                                     options: .new,
                                                     changeHandler: { [titleTextField] (listner, name) in
                                                        let attributedTitle = self.attributedText(from: name.newValue ?? "")
                                                        titleTextField?.attributedStringValue = attributedTitle
                                                     })
        artistObserver = playbackListner.observe(\PlaybackListner.artistName,
                                                  options: .new,
                                                  changeHandler: { [artistTextField] (listner, artist) in
                                                    let attributeedArtist = self.attributedText(from: artist.newValue ?? "", withSize: 18.0)
                                                    artistTextField?.attributedStringValue = attributeedArtist
                                                  })
        spotifyArtworkObserver = playbackListner.observe(\PlaybackListner.spotifyArtworkURL,
                                                         options: .new,
                                                         changeHandler: { [imageView] (listner, url) in
                                                            guard let url = url.newValue else {
                                                                imageView?.image = nil
                                                                return
                                                            }
                                                            self.imageView.kf.setImage(with: URL(string: url))
                                                         })
        iTunesArtworkObserver = playbackListner.observe(\PlaybackListner.iTunesArt,
                                                        options: .new,
                                                        changeHandler: { [imageView] (listner, image) in
                                                            imageView?.image = image.newValue
                                                        })
        playbackStateObserver = playbackListner.observe(\PlaybackListner.playbackState,
                                                        options: .new,
                                                        changeHandler: { [weak self] (listner, state) in
                                                            guard let intValue = state.newValue?.uint32Value else { return }
                                                            let playbackState = MusicEPlS(rawValue: intValue)
                                                            self?.playbackButton(for: playbackState)
                                                        })
        playHeadPositionObserver = playbackListner.observe(\PlaybackListner.playbackHeadPosition,
                                                           options: .new,
                                                           changeHandler: { [playbackProgressIndicator] listner, percentage in
                                                            guard let number = percentage.newValue else { return }
                                                            playbackProgressIndicator?.doubleValue = number.doubleValue
                                                           })
        
        titleTextField.stringValue = playbackListner.trackName
        artistTextField.stringValue = playbackListner.artistName
        imageView.image = playbackListner.iTunesArt
        playbackButton(for: MusicEPlS(playbackListner.playbackState.uint32Value))
        guard let spotifyImageUrl = URL(string: playbackListner.spotifyArtworkURL) else { return }
        imageView.kf.setImage(with: spotifyImageUrl)
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
    
    private func playbackButton(for state: MusicEPlS) {
        switch state {
        // Playing
        case MusicEPlS(rawValue: 1800426320):
            pausePlayButton.image = #imageLiteral(resourceName: "pauseplaybackcontrol")
        default:
            pausePlayButton.image = #imageLiteral(resourceName: "playplaybackcontol")
        }
    }

    func beginPlayheadPolling() {
        guard timer == nil else { return }
        let timer = Timer(fire: Date(), interval: 1.0, repeats: true) { [playbackListner] _ in
            playbackListner.incrementPlayHeadPosition()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func endPlayheadPolling() {
        timer?.invalidate()
        timer = nil
    }

    @IBAction func pausePlayButtonClicked(_ sender: Any) {
        playbackListner.pausePlayPlayback()
    }
    
    @IBAction func rewindButtonClicked(_ sender: Any) {
        playbackListner.rewindPlayback()
    }
    
    @IBAction func fastForwardButtonClicked(_ sender: Any) {
        playbackListner.fastForwardPlayback()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        (NSApplication.shared.delegate as? AppDelegate)?.closeApp()
    }
}
