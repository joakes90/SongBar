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
    @IBOutlet weak var contentEffectsView: NSVisualEffectView!
    
    #if APPSTORE
        @objc private dynamic var playbackListener: MediaWatching = PlaybackListener()
    #else
        @objc private dynamic var playbackListener: MediaWatching = MediaRemoteListner()
    #endif

    private var songTitleObserver: NSKeyValueObservation?
    private var artistObserver: NSKeyValueObservation?
    private var artObserver: NSKeyValueObservation?
//    private var spotifyArtworkObserver: NSKeyValueObservation?
//    private var iTunesArtworkObserver: NSKeyValueObservation?
    private var playbackStateObserver: NSKeyValueObservation?
    private var playHeadPositionObserver: NSKeyValueObservation?
    private var dragging: Bool = false
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
        contentEffectsView.wantsLayer = true
        contentEffectsView.layer?.cornerRadius = 8.0

        songTitleObserver = observe(\.playbackListener.trackName, options: .new, changeHandler: { [weak self] _, name in
            guard let self = self else { return }
            self.titleTextField.stringValue = name.newValue ?? ""
        })

        artistObserver = observe(\.playbackListener.artistName, options: .new, changeHandler: { [weak self] _, artist in
            self?.artistTextField.stringValue = artist.newValue ?? ""
        })

        artObserver = observe(\.playbackListener.art, options: .new, changeHandler: { [weak self] _, image in
            self?.imageView.image = image.newValue ?? NSImage(imageLiteralResourceName: "missingArtwork")
        })

//        spotifyArtworkObserver = observe(\.playbackListener.spotifyArtworkURL, options: .new, changeHandler: { [weak self] _, url in
//            guard let url = url.newValue as? String else {
//                self?.imageView?.image = NSImage(named: "missingArtwork")
//                return
//            }
//            self?.imageView.kf.setImage(with: URL(string: url))
//        })
//
//        iTunesArtworkObserver = observe(\.playbackListener.iTunesArt, options: .new, changeHandler: { [weak self] _, image in
//            guard let image = image.newValue as? NSImage else { return }
//            self?.imageView?.image = image
//        })


        playbackStateObserver = observe(\.playbackListener.playbackState, options: .new, changeHandler: { [weak self] _, state in
            guard let intValue = state.newValue?.uint32Value else { return }
            let playbackState = MusicEPlS(rawValue: intValue)
            self?.playbackButton(for: playbackState)
            if playbackState == MusicEPlSStopped {
                self?.playbackProgressIndicator.doubleValue = 0.0
                self?.playbackProgressIndicator.isEnabled = false
            } else {
                self?.playbackProgressIndicator.isEnabled = true
            }
        })

        playHeadPositionObserver = observe(\.playbackListener.playbackHeadPosition, options: .new, changeHandler: { [weak self] _, percentage in
            guard let number = percentage.newValue else { return }
            self?.playbackProgressIndicator?.doubleValue = Double(truncating: number)
        })

        titleTextField.stringValue = playbackListener.trackName.isEmpty ? "SongBar" : playbackListener.trackName
        artistTextField.stringValue = playbackListener.artistName
        playbackButton(for: MusicEPlS(playbackListener.playbackState.uint32Value))
        imageView.image = playbackListener.art
        playbackListener.populateMusicData()
    }

    private func loadFromNib() {
        var nibObjects: NSArray?
        Bundle.main.loadNibNamed(NSNib.Name(stringLiteral: "PlaybackView"),
                                 owner: self,
                                 topLevelObjects: &nibObjects)
        // swiftlint:disable:next force_cast
        let view = nibObjects?.filter({ $0 is NSView }).first as! NSView
        addSubview(view)
    }

    private func playbackButton(for state: MusicEPlS) {
        switch state {
        // Playing
        case MusicEPlS(rawValue: MusicEPlSPlaying.rawValue):
            pausePlayButton.image = NSImage(named: "pauseplaybackcontrol")
        default:
            pausePlayButton.image = NSImage(named: "playplaybackcontol")
        }
    }

    func beginPlayheadPolling() {
        guard timer == nil else { return }
        let timer = Timer(fire: Date(), interval: 0.250, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !self.dragging {
                self.playbackListener.incrementPlayHeadPosition()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func endPlayheadPolling() {
        timer?.invalidate()
        timer = nil
    }

    @IBAction func pausePlayButtonClicked(_ sender: Any) {
        playbackListener.pausePlayPlayback()
    }

    @IBAction func rewindButtonClicked(_ sender: Any) {
        playbackListener.rewindPlayback()
    }

    @IBAction func fastForwardButtonClicked(_ sender: Any) {
        playbackListener.fastForwardPlayback()
    }

    @IBAction func sliderValueDidChange(_ sender: NSSlider) {
        guard let event = NSApplication.shared.currentEvent else {
            dragging = false
            return
        }

        switch event.type {
        case .leftMouseDown, .leftMouseDragged:
            dragging = true
        case .leftMouseUp:
            playbackListener.setPlaybackToPercentage(NSNumber(value: sender.doubleValue))
            dragging = false
        default:
            return
        }
    }
}
