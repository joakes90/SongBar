//
//  MediaRemote.swift
//  SongBar
//
//  Created by Justin Oakes on 11/8/21.
//  Copyright © 2021 corpe. All rights reserved.
//

import Cocoa
import Combine
import Kingfisher

@objc class MediaRemoteListner: NSObject, MediaWatching {

    private let mediaRemoteBundle: CFBundle

    private let titleString = "SongBar"

    @objc dynamic var menuTitle: String = ""

    @objc dynamic var trackName: String = ""

    @objc dynamic var artistName: String = ""

    @objc dynamic var art: NSImage = NSImage(imageLiteralResourceName: "missingArtwork")

    @objc dynamic var playbackState: NSNumber = 0

    @objc dynamic var playbackHeadPosition: NSNumber = 0

    private var sourceApp: NSRunningApplication?

    private var nowPlayingInformation: [String: Any] = [:]

    private var trackDuration: Double?

    private var elapsedTime: Double?

    private var lastUpdate: Date?

    private var supportsRewind: Bool = false

    private var cancelables = Set<AnyCancellable>()

    private var debounceHeadPosition: Bool {
        !(lastUpdate?.timeIntervalSinceNow  ?? -1 < -1)
    }

    // Listen to Notifications
    private typealias MRMediaRemoteRegisterForNowPlayingNotificationsFunction = @convention(c) (DispatchQueue) -> Void // swiftlint:disable:this type_name
    private let MRMediaRemoteRegisterForNowPlayingNotificationsPointer: UnsafeMutableRawPointer // swiftlint:disable:this identifier_name
    private let MRMediaRemoteRegisterForNowPlayingNotifications: MRMediaRemoteRegisterForNowPlayingNotificationsFunction // swiftlint:disable:this identifier_name

    // Get now playing
    private typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping @convention(block) ([String: Any]) -> Void) -> Void
    private let MRMediaRemoteGetNowPlayingInfoPointer: UnsafeMutableRawPointer
    private let MRMediaRemoteGetNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction

    // Get now playing application PID
    // swiftlint:disable type_name
    // swiftlint:disable identifier_name
    private typealias MRMediaRemoteGetNowPlayingApplicationPIDFunction = @convention(c) (DispatchQueue, @escaping @convention(block) (Int) -> Void) -> Void
    private let MRMediaRemoteGetNowPlayingApplicationPIDPointer: UnsafeMutableRawPointer
    private let MRMediaRemoteGetNowPlayingApplicationPID: MRMediaRemoteGetNowPlayingApplicationPIDFunction

    // Get is playing
    private typealias MRMediaRemoteGetNowPlayingApplicationPlaybackStateFunction = @convention(c) (DispatchQueue, @escaping @convention(block) (Bool) -> Void) -> Void
    private let MRMediaRemoteGetNowPlayingApplicationPlaybackStatePointer: UnsafeMutableRawPointer
    private let MRMediaRemoteGetNowPlayingApplicationPlaybackState: MRMediaRemoteGetNowPlayingApplicationPlaybackStateFunction

    // Send commands to media remote
    private typealias MRMediaRemoteSendCommandFunction = @convention(c) (MRMediaRemoteCommand, NSDictionary?) -> Bool
    private let MRMediaRemoteSendCommandPointer: UnsafeMutableRawPointer
    private let MRMediaRemoteSendCommand: MRMediaRemoteSendCommandFunction

    // Set elpsed time
    private typealias MRMediaRemoteSetElapsedTimeFunction = @convention(c) (Double) -> Void
    private let MRMediaRemoteSetElapsedTimePointer: UnsafeMutableRawPointer
    private let MRMediaRemoteSetElapsedTime: MRMediaRemoteSetElapsedTimeFunction

    @objc enum MRMediaRemoteCommand: Int {
        /*
         * Use nil for userInfo.
         */
        case MRMediaRemoteCommandPlay
        case MRMediaRemoteCommandPause
        case MRMediaRemoteCommandTogglePlayPause
        case MRMediaRemoteCommandStop
        case MRMediaRemoteCommandNextTrack
        case MRMediaRemoteCommandPreviousTrack
        case MRMediaRemoteCommandAdvanceShuffleMode
        case MRMediaRemoteCommandAdvanceRepeatMode
        case MRMediaRemoteCommandBeginFastForward
        case MRMediaRemoteCommandEndFastForward
        case MRMediaRemoteCommandBeginRewind
        case MRMediaRemoteCommandEndRewind
        case MRMediaRemoteCommandRewind15Seconds
        case MRMediaRemoteCommandFastForward15Seconds
        case MRMediaRemoteCommandRewind30Seconds
        case MRMediaRemoteCommandFastForward30Seconds
        case MRMediaRemoteCommandToggleRecord
        case MRMediaRemoteCommandSkipForward
        case MRMediaRemoteCommandSkipBackward
        case MRMediaRemoteCommandChangePlaybackRate

        /*
         * Use a NSDictionary for userInfo, which contains three keys:
         * kMRMediaRemoteOptionTrackID
         * kMRMediaRemoteOptionStationID
         * kMRMediaRemoteOptionStationHash
         */
        case MRMediaRemoteCommandRateTrack
        case MRMediaRemoteCommandLikeTrack
        case MRMediaRemoteCommandDislikeTrack
        case MRMediaRemoteCommandBookmarkTrack

        /*
         * Use nil for userInfo.
         */
        case MRMediaRemoteCommandSeekToPlaybackPosition
        case MRMediaRemoteCommandChangeRepeatMode
        case MRMediaRemoteCommandChangeShuffleMode
        case MRMediaRemoteCommandEnableLanguageOption
        case MRMediaRemoteCommandDisableLanguageOption
    }

    override init() {
        // link to media remote framework
        mediaRemoteBundle =  CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

        // configure now playing function
        MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
        MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)

        // configure playback state function
        MRMediaRemoteGetNowPlayingApplicationPlaybackStatePointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString)
        MRMediaRemoteGetNowPlayingApplicationPlaybackState = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationPlaybackStatePointer, to: MRMediaRemoteGetNowPlayingApplicationPlaybackStateFunction.self)

        // configure now playing app PID function
        MRMediaRemoteGetNowPlayingApplicationPIDPointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteGetNowPlayingApplicationPID" as CFString)
        MRMediaRemoteGetNowPlayingApplicationPID = unsafeBitCast(MRMediaRemoteGetNowPlayingApplicationPIDPointer, to: MRMediaRemoteGetNowPlayingApplicationPIDFunction.self)

        // configure register for notifications function
        MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString)
        MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: MRMediaRemoteRegisterForNowPlayingNotificationsFunction.self)

        // configure message passing
        MRMediaRemoteSendCommandPointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteSendCommand" as CFString)
        MRMediaRemoteSendCommand = unsafeBitCast(MRMediaRemoteSendCommandPointer, to: MRMediaRemoteSendCommandFunction.self)

        // configure set elapsed time
        MRMediaRemoteSetElapsedTimePointer = CFBundleGetFunctionPointerForName(mediaRemoteBundle, "MRMediaRemoteSetElapsedTime" as CFString)
        MRMediaRemoteSetElapsedTime = unsafeBitCast(MRMediaRemoteSetElapsedTimePointer, to: MRMediaRemoteSetElapsedTimeFunction.self)

        super.init()

        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)

        NotificationCenter.default.publisher(for: .mediaRemoteNowPlayingApplicationPlaybackStateDidChange)
            .debounce(for: .milliseconds(250),
                         scheduler: DispatchQueue.main)
            .sink(receiveValue: { notification in
                guard let userInfo = notification.userInfo as? [String: Any],
                      let playbackState = userInfo["kMRMediaRemotePlaybackStateUserInfoKey"] as? Int else { return }
                self.lastUpdate = Date()
                switch playbackState {
                case 1:
                    self.playbackState = NSNumber(value: MusicEPlSPlaying.rawValue)
                case 2:
                    self.playbackState = NSNumber(value: MusicEPlSPaused.rawValue)
                default:
                    self.playbackState = NSNumber(value: MusicEPlSStopped.rawValue)
                    self.nowPlayingInformation = [:]
                }
            })
            .store(in: &cancelables)

        NotificationCenter.default.publisher(for: .mediaRemoteNowPlayingInfoDidChange)
            .debounce(for: .milliseconds(250),
                         scheduler: DispatchQueue.main)
            .sink { _ in
                self.populateMusicData()
            }
            .store(in: &cancelables)

    }

    func populateMusicData() {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { [weak self] (information) in
            guard let self = self else { return }
            self.trackName = self.currentTrackName(from: information)
            self.artistName = self.currentArtistName(from: information)
            self.menuTitle = self.currentMenuTitle(from: information)
            self.trackDuration = self.trackDuration(from: information)
            self.elapsedTime = self.elapsedTime(from: information)
            self.lastUpdate = self.lastUpdate(from: information)
            self.art = self.currentArt(from: information)
            self.nowPlayingInformation = information
        })

        MRMediaRemoteGetNowPlayingApplicationPID(DispatchQueue.main, { [weak self] (pid) in
            guard let self = self else { return }
            self.sourceApp = self.application(for: pid)
        })

        MRMediaRemoteGetNowPlayingApplicationPlaybackState(DispatchQueue.main, { [weak self] (playing) in
            guard let self = self else { return }
            switch (playing, (self.nowPlayingInformation.count > 0) ) {
            case (true, _):
                self.playbackState = NSNumber(value: MusicEPlSPlaying.rawValue)
            case (false, true):
                self.playbackState = NSNumber(value: MusicEPlSPaused.rawValue)
            case (false, false):
                self.playbackState = NSNumber(value: MusicEPlSStopped.rawValue)
            }
        })

    }

    func pausePlayPlayback() {
        playbackState = MusicEPlS(playbackState.uint32Value) == MusicEPlSPlaying ? NSNumber(value: MusicEPlSPaused.rawValue) : NSNumber(value: MusicEPlSPlaying.rawValue)
        lastUpdate = Date()
        send(command: .MRMediaRemoteCommandTogglePlayPause)
    }

    func rewindPlayback() {
        let command: MRMediaRemoteCommand = /*.MRMediaRemoteCommandRewind15Seconds / MRMediaRemoteCommandRewind30Seconds :*/ .MRMediaRemoteCommandPreviousTrack
        send(command: command)
    }

    func fastForwardPlayback() {
        let command: MRMediaRemoteCommand = /*.MRMediaRemoteCommandFastForward15Seconds / MRMediaRemoteCommandFastForward30Seconds :*/ .MRMediaRemoteCommandNextTrack
        send(command: command)
    }

    func skipForward() {
        guard let elapsedTime = currentElapsedTime() else { return }
        MRMediaRemoteSetElapsedTime(elapsedTime + 15.0)
        self.elapsedTime = elapsedTime
        incrementPlayHeadPosition(forceUpdate: true)
    }

    func skipBackward() {
        guard let elapsedTime = currentElapsedTime() else { return }
        MRMediaRemoteSetElapsedTime(elapsedTime - 15.0)
        self.elapsedTime = elapsedTime
        incrementPlayHeadPosition(forceUpdate: true)
    }

    func incrementPlayHeadPosition() {
        incrementPlayHeadPosition(forceUpdate: false)
    }

    func setPlaybackToPercentage(_ percentage: NSNumber) {
        guard let duration = trackDuration else { return }
        let time = (duration / 100) * percentage.doubleValue
        lastUpdate = Date()
        MRMediaRemoteSetElapsedTime(time)
    }
}

// Media data lookup and MRMediaRemote message passing
private extension MediaRemoteListner {

    @discardableResult func send(command: MRMediaRemoteCommand, with userInfo: NSDictionary? = nil) -> Bool {
        return MRMediaRemoteSendCommand(command, userInfo)
    }

    func currentTrackName(from metaData: [String: Any]) -> String {
        return metaData["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? titleString
    }

    func currentArtistName(from metaData: [String: Any]) -> String {
        metaData["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
    }

    func currentMenuTitle(from metaData: [String: Any]) -> String {
        let trackName = currentTrackName(from: metaData)
        let artistName = currentArtistName(from: metaData)
        if !artistName.isEmpty {
            return "\(trackName) - \(artistName)"
        }
        return trackName
    }

    func currentArt(from metaData: [String: Any]) -> NSImage {
        if let artworkData = metaData["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
            return NSImage(data: artworkData) ?? NSImage(imageLiteralResourceName: "missingArtwork")
        } else {
            return sourceApp?.iconForPresenting ?? NSImage(imageLiteralResourceName: "missingArtwork")
        }
    }

    func trackDuration(from metaData: [String: Any]) -> Double? {
        metaData["kMRMediaRemoteNowPlayingInfoDuration"] as? Double
    }

    func elapsedTime(from metaData: [String: Any]) -> Double? {
        metaData["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double
    }

    func lastUpdate(from metaData: [String: Any]) -> Date? {
        metaData["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date
    }

    func incrementPlayHeadPosition(forceUpdate: Bool = false) {
        guard let elapsedTime = self.elapsedTime,
              let trackDuration = self.trackDuration else { return }
        let timeInterval = (self.playbackState.uint32Value == MusicEPlSPlaying.rawValue) ? Date().timeIntervalSince(self.lastUpdate ?? Date()) : 0
        let percentage = ((elapsedTime + timeInterval) / trackDuration) * 100
        if !debounceHeadPosition || forceUpdate {
            playbackHeadPosition = NSNumber(value: percentage)
        }
    }

    func currentElapsedTime() -> Double? {
        if case MusicEPlSPlaying.rawValue = playbackState.uint32Value {
            let timeInterval = (lastUpdate?.timeIntervalSinceNow ?? 0.0) * -1
            return (elapsedTime ?? 0.0) + timeInterval
        }
        return elapsedTime
    }
}

// Application Lookup
private extension MediaRemoteListner {

    func application(for pid: Int) -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications
            .filter({
                $0.processIdentifier == pid
            })
            .first
    }
}

private extension Notification.Name {
    static let mediaRemoteNowPlayingInfoDidChange = Notification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification")
    static let mediaRemoteNowPlayingApplicationPlaybackStateDidChange = Notification.Name("kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification")
    // swiftlint:disable:previous identifier_name
}

private extension NSRunningApplication {
    var iconForPresenting: NSImage? {
        self.bundleIdentifier == "com.apple.WebKit.GPU" ? NSImage(named: "safari") : icon
    }
}
