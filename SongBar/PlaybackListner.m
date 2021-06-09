//
//  PlaybackListener.m
//  SongBar
//
//  Created by Justin Oakes on 10/9/20.
//  Copyright © 2020 corpe. All rights reserved.
//

#import "Music.h"
#import "Spotify.h"
#import "PlaybackListner.h"
#import "SongBar-Swift.h"

typedef enum observedApplication {
    music,
    spotify,
    none} ObservedApplication;

@interface PlaybackListner ()

@property (strong, nonatomic) MusicApplication *musicApplication;
@property (strong, nonatomic) SpotifyApplication *spotifyApplication;
@property ObservedApplication observedApplication;

@end

@implementation PlaybackListner

- (instancetype)init
{
    self = [super init];
    if (self) {
        _musicApplication = [SBApplication applicationWithBundleIdentifier:[PlaybackListner musicBundleIdentifier]];
        _spotifyApplication = [SBApplication applicationWithBundleIdentifier:[PlaybackListner spotifyBundleIdentifier]];
        self.observedApplication = none;
        [self populateMusicData];
        [self configureObservers];
    }
    return self;
}

// Static Bundle Identifiers
+ (NSString*) musicBundleIdentifier
{
    return @"com.apple.Music";
}

+ (void) setMusicBundleIdentifier:(NSString*)newStr {}

+ (NSString*) spotifyBundleIdentifier
{
    return @"com.spotify.client";
}

+ (void) setSpotifyBundleIdentifier:(NSString*)newStr {}
    
- (void) configureObservers {
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(refreshWithNotification:)
                                                            name:@"com.apple.iTunes.playerInfo"
                                                          object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(refreshWithNotification:)
                                                            name:@"com.spotify.client.PlaybackStateChanged"
                                                          object:nil];
}

- (void) populateMusicData {
    BOOL iTunesOpen = [self applicationOpenWithBundleId:[PlaybackListner musicBundleIdentifier]];
    BOOL spotifyOpen = [self applicationOpenWithBundleId:[PlaybackListner spotifyBundleIdentifier]];

    if (spotifyOpen) {
        [self setTrackInfoFrom:_spotifyApplication];
        [self setSpotifyArtworkURLUsing:_spotifyApplication];
        _observedApplication = spotify;
    } else if (iTunesOpen) {
        [self setTrackInfoFrom:_musicApplication];
        [self setiTunesArtUsing:_musicApplication];
        _observedApplication = music;
    } else {
        [self setValue:@"SongBar" forKey:@"menuTitle"];
        [self setValue:nil forKey:@"trackName"];
        [self setValue:nil forKey:@"artistName"];
        _observedApplication = none;
    }
}

- (void)refreshWithNotification:(nullable NSNotification *)notification {
    NSString *notificationName = notification.name;
    NSString *playerState = notification.userInfo[@"Player State"];

    if ([playerState isEqualToString:@"Stopped"]) {
        [self setTrackInfoFrom:nil];
        [self setSpotifyArtworkURLUsing:nil];
        _observedApplication = none;
        return;
    }
    if ([notificationName isEqualToString:@"com.apple.iTunes.playerInfo"]) {
        [self setTrackInfoFrom:_musicApplication];
        [self setiTunesArtUsing:_musicApplication];
        _observedApplication = music;
        return;
    }
    if ([notificationName isEqualToString:@"com.spotify.client.PlaybackStateChanged"]) {
        [self setSpotifyArtworkURLUsing:_spotifyApplication];
        [self setTrackInfoFrom:_spotifyApplication];
        _observedApplication = spotify;
        return;
    }
}

- (BOOL)applicationOpenWithBundleId:(NSString *)bundleId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleIdentifier == %@", bundleId];
    NSArray<NSRunningApplication *> *runningAplications = [[[NSWorkspace sharedWorkspace] runningApplications] filteredArrayUsingPredicate:predicate];
    
    return ([runningAplications count] > 0);
}

- (void)setTrackInfoFrom:(SBApplication *)application {
    MusicApplication *mApp = (MusicApplication *) application;
    MusicTrack *currentTrack = [application performSelector:@selector(currentTrack)];
    NSString *trackName = currentTrack.name != nil ? currentTrack.name : @"SongBar";
    trackName = [trackName length] > 0 ? trackName : @"SongBar";
    NSString *artistName = currentTrack.artist;
    NSNumber *playbackState = [NSNumber numberWithInteger:mApp.playerState];

    [self setValue:trackName forKey:@"trackName"];
    [self setValue:artistName forKey:@"artistName"];
    [self setValue:playbackState forKey:@"playbackState"];
    if ([artistName length] > 0) {
        NSString *menuTitle = [NSString stringWithFormat:@"%@ - %@", trackName, artistName];
        [self setValue:menuTitle forKey:@"menuTitle"];
        return;
    }
    [self setValue:trackName forKey:@"menuTitle"];
}

- (void) setSpotifyArtworkURLUsing:(SpotifyApplication *)application {
    SpotifyTrack *currentTrack = application.currentTrack;
    NSString *artworkURL = currentTrack.artworkUrl;
    if (![self.spotifyArtworkURL isEqualTo:artworkURL]) {
        [self setValue:artworkURL forKey:@"spotifyArtworkURL"];
    }
}

- (void) setiTunesArtUsing:(MusicApplication *)application {
    MusicTrack *currentTrack = application.currentTrack;
    
    MusicArtwork *artwork = (MusicArtwork *)[[currentTrack artworks] objectAtIndex:0];
    if ([artwork.data isKindOfClass:[NSImage class]]) {
        NSImage *image = artwork.data;
        [self setValue:image forKey:@"iTunesArt"];
    } else {
        [self setValue:nil forKey:@"iTunesArt"];
    }
}

- (void)pausePlayPlayback {
    BOOL iTunesOpen = [self applicationOpenWithBundleId:[PlaybackListner musicBundleIdentifier]];
    BOOL spotifyOpen = [self applicationOpenWithBundleId:[PlaybackListner spotifyBundleIdentifier]];
    
    if (iTunesOpen && !spotifyOpen) {
        [_musicApplication playpause];
    } else if (spotifyOpen && (_spotifyApplication.playerState == SpotifyEPlSPlaying || _spotifyApplication.playerState == SpotifyEPlSPaused)) {
        [_spotifyApplication playpause];
    }
}

- (void)rewindPlayback {
    BOOL iTunesOpen = [self applicationOpenWithBundleId:[PlaybackListner musicBundleIdentifier]];
    BOOL spotifyOpen = [self applicationOpenWithBundleId:[PlaybackListner spotifyBundleIdentifier]];
    
    if (iTunesOpen && (_musicApplication.playerState == MusicEPlSPlaying || _musicApplication.playerState == MusicEPlSPaused)) {
        [_musicApplication backTrack];
    } else if (spotifyOpen && (_spotifyApplication.playerState == SpotifyEPlSPlaying || _spotifyApplication.playerState == SpotifyEPlSPaused)) {
        [_spotifyApplication previousTrack];
    }
}

- (void)fastForwardPlayback {
    BOOL iTunesOpen = [self applicationOpenWithBundleId:[PlaybackListner musicBundleIdentifier]];
    BOOL spotifyOpen = [self applicationOpenWithBundleId:[PlaybackListner spotifyBundleIdentifier]];
    
    if (iTunesOpen && (_musicApplication.playerState == MusicEPlSPlaying || _musicApplication.playerState == MusicEPlSPaused)) {
        [_musicApplication nextTrack];
    } else if (spotifyOpen && (_spotifyApplication.playerState == SpotifyEPlSPlaying || _spotifyApplication.playerState == SpotifyEPlSPaused)) {
        [_spotifyApplication nextTrack];
    }
}

- (NSNumber *)playbackHeadPercentageFor:(MusicTrack *) track in:(MusicApplication *) application {
    // TODO: Support Apple Music
    SpotifyTrack *sptTrack = (SpotifyTrack *)track;
    double trackLengthSeconds = sptTrack.duration/1000;
    double playerPosition = application.playerPosition;
    double percentage = (playerPosition/trackLengthSeconds) * 100;
    return [NSNumber numberWithDouble:percentage];
}

- (NSNumber *)playbackHeadPositionAt:(NSNumber *)percentage in:(MusicTrack *) track {
    // TODO: Support Apple Music
    SpotifyTrack *sptTrack = (SpotifyTrack *)track;
    double duration = sptTrack.duration/1000;
    double position = (duration/100) * percentage.doubleValue;
    return [NSNumber numberWithDouble:position];
}

- (void) incrementPlayHeadPosition {
    MusicApplication *musicApp;
    switch (_observedApplication) {
        case spotify:
            musicApp = (MusicApplication *)_spotifyApplication;
            break;
        case music:
            // TODO: Support Apple Music
            musicApp = _musicApplication;
            return;
        default:
            [self setValue:[NSNumber numberWithDouble:0.0] forKey:@"playbackHeadPosition"];
            return;
    }
    MusicTrack *track = [musicApp performSelector:@selector(currentTrack)];
    NSNumber *headPercentage = [self playbackHeadPercentageFor:track in:musicApp];
    [self setValue:headPercentage forKey:@"playbackHeadPosition"];
}

- (void)setPlaybackto:(NSNumber *) percentage {
    MusicApplication *application;
    MusicTrack *track;
    switch (_observedApplication) {
        case spotify:
            application = (MusicApplication *)_spotifyApplication;
            break;
        case music:
            application = _musicApplication;
            break;
        default:
            return;
    }
    track = [application performSelector:@selector(currentTrack)];
    NSNumber *position = [self playbackHeadPositionAt:percentage in:track];
    [application setPlayerPosition:position.doubleValue];
}

@end
