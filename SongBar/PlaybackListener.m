//
//  PlaybackListener.m
//  SongBar
//
//  Created by Justin Oakes on 10/9/20.
//  Copyright © 2020 corpe. All rights reserved.
//

#import "ScriptingBridge/ScriptingBridge.h"
#import "Music.h"
#import "Spotify.h"
#import "PlaybackListener.h"

typedef enum observedApplication {
    music,
    spotify,
    none} ObservedApplication;

@interface PlaybackListener ()

@property (strong, nonatomic) MusicApplication *musicApplication;
@property (strong, nonatomic) SpotifyApplication *spotifyApplication;
@property (strong, nonatomic) NSURL *spotifyArtworkURL;
@property ObservedApplication observedApplication;
@end

@implementation PlaybackListener

@synthesize artistName, art, trackName, menuTitle, playbackHeadPosition, playbackState;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _musicApplication = [SBApplication applicationWithBundleIdentifier:[PlaybackListener musicBundleIdentifier]];
        _spotifyApplication = [SBApplication applicationWithBundleIdentifier:[PlaybackListener spotifyBundleIdentifier]];
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
    BOOL iTunesOpen = [self applicationOpenWithBundleId:[PlaybackListener musicBundleIdentifier]];
    BOOL spotifyOpen = [self applicationOpenWithBundleId:[PlaybackListener spotifyBundleIdentifier]];

    if (spotifyOpen) {
        [self setTrackInfoFrom:_spotifyApplication];
        [self setArtworkUsing:_spotifyApplication];
        _observedApplication = spotify;
    } else if (iTunesOpen) {
        [self setTrackInfoFrom:_musicApplication];
        [self setArtworkUsing:_musicApplication];
        _observedApplication = music;
    } else {
        [self setValue:@"SongBar" forKey:@"menuTitle"];
        [self setValue:nil forKey:@"trackName"];
        [self setValue:nil forKey:@"artistName"];
        [self setValue:nil forKey:@"art"];
        _observedApplication = none;
    }
}

- (void)refreshWithNotification:(nullable NSNotification *)notification {
    NSString *notificationName = notification.name;
    NSString *playerState = notification.userInfo[@"Player State"];

    if ([playerState isEqualToString:@"Stopped"]) {
        _observedApplication = none;
        [self setTrackInfoFrom:nil];
        [self setArtworkUsing:nil];
        [self setValue:[NSNumber numberWithInt:MusicEPlSStopped] forKey:@"playbackState"];
        return;
    }
    if ([notificationName isEqualToString:@"com.apple.iTunes.playerInfo"]) {
        _observedApplication = music;
        [self setTrackInfoFrom:_musicApplication];
        [self setArtworkUsing:_musicApplication];
        return;
    }
    if ([notificationName isEqualToString:@"com.spotify.client.PlaybackStateChanged"]) {
        _observedApplication = spotify;
        [self setArtworkUsing:_spotifyApplication];
        [self setTrackInfoFrom:_spotifyApplication];
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

- (void) setArtworkUsing:(SBApplication *)application {
    NSImage *image;
    switch (_observedApplication) {
        case spotify:
            image = [self setSpotifyArtworkURLUsing:_spotifyApplication];
            break;
        case music:
            image = [self setiTunesArtUsing:_musicApplication];
            break;
        case none:
            image = nil;
            break;
    }
    [self setValue:image forKey:@"art"];
}

- (NSImage *) setSpotifyArtworkURLUsing:(SpotifyApplication *)application {
    SpotifyTrack *currentTrack = application.currentTrack;
    NSString *artworkURLString = currentTrack.artworkUrl;
    NSURL *artworkURL = [NSURL URLWithString:artworkURLString];
    if (![artworkURL isEqualTo:_spotifyArtworkURL] && artworkURL != nil) {
        _spotifyArtworkURL = artworkURL;
        return [[NSImage alloc] initWithContentsOfURL:_spotifyArtworkURL];
    }
    return self.art;
}

- (NSImage *) setiTunesArtUsing:(MusicApplication *)application {
    MusicTrack *currentTrack = application.currentTrack;
    MusicPlaylist *playlist = [application currentPlaylist];
    MusicArtwork *trackArtwork = (MusicArtwork *)[[currentTrack artworks] objectAtIndex:0];
    MusicArtwork *playlistArtwork = (MusicArtwork *)[[playlist artworks] objectAtIndex:0];
    _spotifyArtworkURL = nil;
    if ([trackArtwork.data isKindOfClass:[NSImage class]]) {
        return trackArtwork.data;
    } else if ([playlistArtwork.data isKindOfClass:[NSImage class]]) {
        return playlistArtwork.data;
    } else {
        return nil;
    }
}

- (void)pausePlayPlayback {
    switch(_observedApplication) {
        case spotify:
            [_spotifyApplication playpause];
            break;
        case music:
            [_musicApplication playpause];
            break;
        default:
            [_musicApplication playpause];
            break;
    }
}

- (void)rewindPlayback {
    switch(_observedApplication) {
        case spotify:
            [_spotifyApplication previousTrack];
            break;
        case music:
            [_musicApplication previousTrack];
            break;
        default:
            break;
    }
}

- (void)fastForwardPlayback {
    switch(_observedApplication) {
        case spotify:
            [_spotifyApplication nextTrack];
            break;
        case music:
            [_musicApplication nextTrack];
            break;
        default:
            break;
    }
}

- (NSNumber *)playbackHeadPercentageFor:(MusicTrack *) track in:(MusicApplication *) application {
    double trackLengthSeconds;
    switch (_observedApplication) {
        case spotify:
             trackLengthSeconds = ((SpotifyTrack *)track).duration/1000;
            break;
        case music:
            trackLengthSeconds = track.duration;
            break;
        default:
            return [NSNumber numberWithDouble:0.0];
    }
    double playerPosition = application.playerPosition;
    double percentage = (playerPosition/trackLengthSeconds) * 100;
    return [NSNumber numberWithDouble:percentage];
}

- (NSNumber *)playbackHeadPositionAt:(NSNumber *)percentage in:(MusicTrack *) track {
    double trackLengthSeconds;
    switch (_observedApplication) {
        case spotify:
             trackLengthSeconds = ((SpotifyTrack *)track).duration/1000;
            break;
        case music:
            trackLengthSeconds = track.duration;
            break;
        default:
            return [NSNumber numberWithDouble:0.0];
    }
    double position = (trackLengthSeconds/100) * percentage.doubleValue;
    return [NSNumber numberWithDouble:position];
}

- (void) incrementPlayHeadPosition {
    MusicApplication *musicApp;
    switch (_observedApplication) {
        case spotify:
            musicApp = (MusicApplication *)_spotifyApplication;
            break;
        case music:
            musicApp = _musicApplication;
            break;
        default:
            [self setValue:[NSNumber numberWithDouble:0.0] forKey:@"playbackHeadPosition"];
            return;
    }
    MusicTrack *track = [musicApp performSelector:@selector(currentTrack)];
    NSNumber *headPercentage = [self playbackHeadPercentageFor:track in:musicApp];
    [self setValue:headPercentage forKey:@"playbackHeadPosition"];
}

- (void)setPlaybackToPercentage:(NSNumber * _Nonnull)percentage {
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

- (void)skipBackward {
    [self populateMusicData];
    MusicApplication *musicApp;
    MusicTrack *track;
    double trackDurationSeconds;
    switch (_observedApplication) {
        case spotify:
            musicApp = (MusicApplication *)_spotifyApplication;
            track = [musicApp performSelector:@selector(currentTrack)];
            NSInteger trackDuration = ((SpotifyTrack *)track).duration;
            trackDurationSeconds = trackDuration / 1000;
            break;
        case music:
            musicApp = _musicApplication;
            track = [musicApp performSelector:@selector(currentTrack)];
            trackDurationSeconds = track.duration;
            break;
        default:
            return;
    }
    NSNumber *headPercentage = [self playbackHeadPercentageFor:track in:musicApp];
    double updatedElapsedTimeSeconds = ((trackDurationSeconds / 100) * headPercentage.doubleValue) - 15.0;
    [musicApp setPlayerPosition:updatedElapsedTimeSeconds];
}


- (void)skipForward {
    [self populateMusicData];
    MusicApplication *musicApp;
    MusicTrack *track;
    double trackDurationSeconds;
    switch (_observedApplication) {
        case spotify:
            musicApp = (MusicApplication *)_spotifyApplication;
            track = [musicApp performSelector:@selector(currentTrack)];
            NSInteger trackDuration = ((SpotifyTrack *)track).duration;
            trackDurationSeconds = trackDuration / 1000;
            break;
        case music:
            musicApp = _musicApplication;
            track = [musicApp performSelector:@selector(currentTrack)];
            trackDurationSeconds = track.duration;
            break;
        default:
            return;
    }
    NSNumber *headPercentage = [self playbackHeadPercentageFor:track in:musicApp];
    double updatedElapsedTimeSeconds = ((trackDurationSeconds / 100) * headPercentage.doubleValue) + 15.0;
    [musicApp setPlayerPosition:updatedElapsedTimeSeconds];
}

@end
