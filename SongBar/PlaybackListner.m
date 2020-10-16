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

    if (spotifyOpen && _spotifyApplication.playerState == SpotifyEPlSPlaying) {
        [self setTrackInfoFrom:_spotifyApplication];
        [self setSpotifyArtworkURLUsing:_spotifyApplication];
    } else if (iTunesOpen && _musicApplication.playerState == MusicEPlSPlaying) {
        [self setTrackInfoFrom:_musicApplication];
        [self setiTunesArtUsing:_musicApplication];
    } else {
        [self setValue:@"SongBar" forKey:@"menuTitle"];
        [self setValue:nil forKey:@"trackName"];
        [self setValue:nil forKey:@"artistName"];
    }
}

- (void)refreshWithNotification:(nullable NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    
//    BOOL iTunesOpen = [self applicationOpenWithBundleId:[PlaybackListner musicBundleIdentifier]];
//    BOOL spotifyOpen = [self applicationOpenWithBundleId:[PlaybackListner spotifyBundleIdentifier]];
//
//    if (spotifyOpen && _spotifyApplication.playerState == SpotifyEPlSPlaying) {
//        [self setTrackInfoFrom:_spotifyApplication];
//        [self setSpotifyArtworkURLUsing:_spotifyApplication];
//    } else if (iTunesOpen && _musicApplication.playerState == MusicEPlSPlaying) {
//        [self setTrackInfoFrom:_musicApplication];
//        [self setiTunesArtUsing:_musicApplication];
//    } else {
//        [self setValue:@"SongBar" forKey:@"menuTitle"];
//        [self setValue:nil forKey:@"trackName"];
//        [self setValue:nil forKey:@"artistName"];
//    }
}

- (BOOL)applicationOpenWithBundleId:(NSString *)bundleId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleIdentifier == %@", bundleId];
    NSArray<NSRunningApplication *> *runningAplications = [[[NSWorkspace sharedWorkspace] runningApplications] filteredArrayUsingPredicate:predicate];
    
    return ([runningAplications count] > 0);
}

- (void)setTrackInfoFrom:(SBApplication *)application {
    MusicApplication *mApp = (MusicApplication *) application;
    MusicTrack *currentTrack = [application performSelector:@selector(currentTrack)];
    NSString *trackName = currentTrack.name;
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
    }
}

- (void)pausePlayPlayback {
    NSLog(@"pause play");
}

- (void)rewindPlayback {
    NSLog(@"rewind");
}

- (void)fastForwardPlayback {
    NSLog(@"fastforward");
}

@end
