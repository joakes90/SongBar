//
//  PlaybackListener.h
//  SongBar
//
//  Created by Justin Oakes on 10/9/20.
//  Copyright © 2020 corpe. All rights reserved.
//

#import "Cocoa/Cocoa.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MediaWatching <NSObject>

@required
@property (strong, nonatomic, readonly) NSString *menuTitle;
@property (strong, nonatomic, readonly) NSString *trackName;
@property (strong, nonatomic, readonly) NSString *artistName;
@property (strong, nonatomic, readonly) NSImage *art;
@property (strong, nonatomic, readonly) NSNumber *playbackState;
@property (strong, nonatomic, readonly) NSNumber *playbackHeadPosition;

- (void) populateMusicData;
- (void)pausePlayPlayback;
- (void)rewindPlayback;
- (void)fastForwardPlayback;
- (NSNumber *)playbackHeadPercentageFor:(MusicTrack *) track in:(MusicApplication *) application;
- (NSNumber *)playbackHeadPositionAt:(NSNumber *)percentage in:(MusicTrack *) track;
- (void) incrementPlayHeadPosition;
- (void)setPlaybackToPercentage:(NSNumber * _Nonnull)percentage;

@end

@interface PlaybackListener : NSObject <MediaWatching>

@end

NS_ASSUME_NONNULL_END
