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

    private let playbackListener = PlaybackListener()
    private var songTitleObserver: NSKeyValueObservation?
    private var artistObserver: NSKeyValueObservation?
    private var spotifyArtworkObserver: NSKeyValueObservation?
    private var iTunesArtworkObserver: NSKeyValueObservation?
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

        songTitleObserver = playbackListener.observe(\PlaybackListener.trackName,
                                                     options: .new,
                                                     changeHandler: { [titleTextField] (_, name) in
                                                        let attributedTitle = self.attributedText(from: name.newValue ?? "")
                                                        titleTextField?.attributedStringValue = attributedTitle
                                                     })
        artistObserver = playbackListener.observe(\PlaybackListener.artistName,
                                                  options: .new,
                                                  changeHandler: { [artistTextField] (_, artist) in
                                                    let attributedArtist = self.attributedText(from: artist.newValue ?? "", withSize: 18.0)
                                                    artistTextField?.attributedStringValue = attributedArtist
                                                  })
        spotifyArtworkObserver = playbackListener.observe(\PlaybackListener.spotifyArtworkURL,
                                                         options: .new,
                                                         changeHandler: { [imageView] (_, url) in
                                                            guard let url = url.newValue else {
                                                                imageView?.image = nil
                                                                return
                                                            }
                                                            self.imageView.kf.setImage(with: URL(string: url))
                                                         })
        iTunesArtworkObserver = playbackListener.observe(\PlaybackListener.iTunesArt,
                                                        options: .new,
                                                        changeHandler: { [imageView] (_, image) in
                                                            imageView?.image = image.newValue
                                                        })
        playbackStateObserver = playbackListener.observe(\PlaybackListener.playbackState,
                                                        options: .new,
                                                        changeHandler: { [weak self] (_, state) in
                                                            guard let intValue = state.newValue?.uint32Value else { return }
                                                            let playbackState = MusicEPlS(rawValue: intValue)
                                                            self?.playbackButton(for: playbackState)
                                                        })
        playHeadPositionObserver = playbackListener.observe(\PlaybackListener.playbackHeadPosition,
                                                           options: .new,
                                                           changeHandler: { [playbackProgressIndicator] _, percentage in
                                                            guard let number = percentage.newValue else { return }
                                                            playbackProgressIndicator?.doubleValue = number.doubleValue
                                                           })

        titleTextField.stringValue = playbackListener.trackName
        artistTextField.stringValue = playbackListener.artistName
        imageView.image = playbackListener.iTunesArt
        playbackButton(for: MusicEPlS(playbackListener.playbackState.uint32Value))
        guard let spotifyImageUrl = URL(string: playbackListener.spotifyArtworkURL) else { return }
        imageView.kf.setImage(with: spotifyImageUrl)
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

    private func attributedText(from string: String, withSize fontSize: CGFloat = 24.0) -> NSAttributedString {
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .center
        let attributedString = NSAttributedString(string: string,
                                                  attributes: [.strokeWidth: -1.0,
                                                               .strokeColor: NSColor.white,
                                                               .foregroundColor: NSColor.black,
                                                               .paragraphStyle: pStyle,
                                                               .font: NSFont.boldSystemFont(ofSize: fontSize)])
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
        let timer = Timer(fire: Date(), interval: 1.0, repeats: true) { [weak self] _ in
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

    @IBAction func closeButtonClicked(_ sender: Any) {
        (NSApplication.shared.delegate as? AppDelegate)?.closeApp()
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
            playbackListener.setPlaybackto(NSNumber(value: sender.doubleValue))
            dragging = false
        default:
            dragging = false
        }
    }
}
