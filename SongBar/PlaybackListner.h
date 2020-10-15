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

@interface PlaybackListner : NSObject

@property (strong, readonly) NSString *menuTitle;
@property (strong, readonly) NSString *trackName;
@property (strong, readonly) NSString *artistName;
@property (strong, readonly) NSImage *iTunesArt;
@property (strong, readonly) NSString *spotifyArtworkURL;

@property( class, copy ) NSString* musicBundleIdentifier;
@property( class, copy ) NSString* spotifyBundleIdentifier;

- (void) refreshWithNotification:(nullable NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
