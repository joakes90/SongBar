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

@interface PlaybackListner ()

@property (strong, nonatomic) MusicApplication *musicApplication;
@property (strong, nonatomic) SpotifyApplication *spotifyApplication;

@end

@implementation PlaybackListner

- (instancetype)init
{
    self = [super init];
    if (self) {
        _musicApplication = [SBApplication applicationWithBundleIdentifier:[PlaybackListner musicBundleIdentifier]];
        _spotifyApplication = [SBApplication applicationWithBundleIdentifier:[PlaybackListner spotifyBundleIdentifier]];
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
    } else if (iTunesOpen) {
        [self setTrackInfoFrom:_musicApplication];
        [self setiTunesArtUsing:_musicApplication];
    } else {
        [self setValue:@"SongBar" forKey:@"menuTitle"];
        [self setValue:nil forKey:@"trackName"];
        [self setValue:nil forKey:@"artistName"];
    }
}

- (void)refreshWithNotification:(nullable NSNotification *)notification {
    NSString *notificationName = notification.name;
    NSString *playerState = notification.userInfo[@"Player State"];

    if ([playerState isEqualToString:@"Stopped"]) {
        [self setTrackInfoFrom:nil];
        [self setSpotifyArtworkURLUsing:nil];
        return;
    }
    if ([notificationName isEqualToString:@"com.apple.iTunes.playerInfo"]) {
        [self setTrackInfoFrom:_musicApplication];
        [self setiTunesArtUsing:_musicApplication];
        return;
    }
    if ([notificationName isEqualToString:@"com.spotify.client.PlaybackStateChanged"]) {
        [self setSpotifyArtworkURLUsing:_spotifyApplication];
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
    NSNumber *headPosistion = [self playbackHeadPositionFor:currentTrack in: mApp];

    [self setValue:trackName forKey:@"trackName"];
    [self setValue:artistName forKey:@"artistName"];
    [self setValue:playbackState forKey:@"playbackState"];
    [self setValue:headPosistion forKey:@"playbackHeadPosition"];
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

- (NSNumber *)playbackHeadPositionFor:(MusicTrack *) track in:(MusicApplication *) application {
    SpotifyTrack *sptTrack = track;
    double trackLengthSeconds = sptTrack.duration/1000;
    double playerPosition = application.playerPosition;
    double percentage = (playerPosition/trackLengthSeconds) * 100;
    return [NSNumber numberWithDouble:percentage];
}
@end
