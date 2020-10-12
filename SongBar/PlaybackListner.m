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
        [self refresh];
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
                                                        selector:@selector(refresh)
                                                            name:@"com.apple.iTunes.playerInfo"
                                                          object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(refresh)
                                                            name:@"com.spotify.client.PlaybackStateChanged"
                                                          object:nil];
}

- (void)refresh {
    BOOL iTunesOpen = [self applicationOpenWithBundleId:[PlaybackListner musicBundleIdentifier]];
    BOOL spotifyOpen = [self applicationOpenWithBundleId:[PlaybackListner spotifyBundleIdentifier]];
    NSString *iTunesString;
    NSString *spotifyString;
    if (iTunesOpen && self.musicApplication.playerState == MusicEPlSPlaying) {
        iTunesString = [self getTrackFrom:_musicApplication];
    }
    if (spotifyOpen && self.spotifyApplication.playerState == SpotifyEPlSPlaying) {
        spotifyString = [self getTrackFrom:_spotifyApplication];
    }

    [self updateMenuTitleWithString:@"SongBar"];
}

- (void) updateMenuTitleWithString:(NSString *)title {
    [self setValue:title forKey:@"menuTitle"];
}

- (BOOL)applicationOpenWithBundleId:(NSString *)bundleId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bundleIdentifier == %@", bundleId];
    NSArray<NSRunningApplication *> *runningAplications = [[[NSWorkspace sharedWorkspace] runningApplications] filteredArrayUsingPredicate:predicate];
    
    return ([runningAplications count] > 0);
}

- (NSString *)getTrackFrom:(SBApplication *)application {
    MusicTrack *currentTrack = [application performSelector:@selector(currentTrack)];
    NSLog(@"%@", currentTrack);
    return @"SongBar";
}
@end
