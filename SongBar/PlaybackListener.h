//
//  PlaybackListener.h
//  SongBar
//
//  Created by Justin Oakes on 10/9/20.
//  Copyright © 2020 corpe. All rights reserved.
//

#import "Cocoa/Cocoa.h"
#import "ScriptingBridge/ScriptingBridge.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MediaWatching <NSObject>

@required

@property (readonly) NSString *menuTitle;
@property (readonly) NSString *trackName;
@property (readonly) NSString *artistName;
@property (readonly) NSImage *art;
@property (readonly) NSNumber *playbackState;
@property (readonly) NSNumber *playbackHeadPosition;

- (void) populateMusicData;
- (void) pausePlayPlayback;
- (void) rewindPlayback;
- (void) fastForwardPlayback;
- (void) incrementPlayHeadPosition;
- (void) setPlaybackto:(NSNumber *) percentage;

@optional

@property (readonly) NSImage *iTunesArt;
@property (readonly) NSString *spotifyArtworkURL;

@end

@interface PlaybackListener : NSObject <MediaWatching>

//@property (strong, readonly) NSString *menuTitle;
//@property (strong, readonly) NSString *trackName;
//@property (strong, readonly) NSString *artistName;
//@property (strong, readonly) NSImage *iTunesArt;
//@property (strong, readonly) NSString *spotifyArtworkURL;
//@property (strong, readonly) NSNumber *playbackState;
//@property (strong, readonly) NSNumber *playbackHeadPosition;

//@property( class, copy ) NSString* musicBundleIdentifier;
//@property( class, copy ) NSString* spotifyBundleIdentifier;
//
//- (void) populateMusicData;
//- (void) pausePlayPlayback;
//- (void) rewindPlayback;
//- (void) fastForwardPlayback;
//- (void) incrementPlayHeadPosition;
//- (void) setPlaybackto:(NSNumber *) percentage;
@end

NS_ASSUME_NONNULL_END
