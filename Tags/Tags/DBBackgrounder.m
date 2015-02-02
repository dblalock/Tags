//
//  DBBackgrounder.m
//  Tags
//
//  Created by DB on 2/2/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBBackgrounder.h"

#import <AVFoundation/AVFoundation.h>

static NSString *const kBackgroundSoundFileName = @"bg_sound";
static NSString *const kBackgroundSoundFileExt = @"mp3";

@interface DBBackgrounder ()
@property (nonatomic, strong) AVPlayer* player;
@end

@implementation DBBackgrounder

-(instancetype) init {
	// our only task is to start dummy audio so the app remains executing
	// in the background constantly
	if (self = [super init]) {
		_backgroundEnabled = NO;
		
		NSError *sessionError = nil;
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
										 withOptions:AVAudioSessionCategoryOptionMixWithOthers
											   error:&sessionError];
		
		// you should typically check return on setCategory and sessionError at this point
		AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle]
															  URLForResource:kBackgroundSoundFileName
															  withExtension:kBackgroundSoundFileExt]];
		[self setPlayer:[[AVPlayer alloc] initWithPlayerItem:item]];
		
		// this makes sure our player keeps working after the silence ends
		[[self player] setActionAtItemEnd:AVPlayerActionAtItemEndNone];
	}
	return self;
}

-(void) setBackgroundEnabled:(BOOL)backgroundEnabled {
	if (_backgroundEnabled == backgroundEnabled) return;
	_backgroundEnabled = backgroundEnabled;
	if (backgroundEnabled) {
		[_player play];
	} else {
		[_player pause];
	}
}

@end
