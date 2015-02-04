//
//  DBTimeRangeItem.m
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTimeRangeItem.h"

#import <RMMapper.h>	// to exclude properties

#import "Tag.h"
#import "Typ.h"

static const int kIncrementDurationEverySecs = 5;	//TODO 1s, but don't kill swiped-over-ness
static const BOOL kStartRecordingWhenCreated = NO;

@interface DBTimeRangeItem ()
@property(strong, nonatomic) Tag* startTag;
@property(strong, nonatomic) Tag* endTag;
@property(strong, nonatomic) NSTimer* recordingTimer;
@end

@implementation DBTimeRangeItem

-(instancetype) initWithTag:(Tag*)tag parent:(DBTableItem*)parent {
	if (self = [super initWithTag:tag parent:parent]) {
		
		// get start and stop tags
		for (Tag* tag in self.tag.childTags) {
			if ([tag.name isEqualToString:kStartTimeFieldName]) {
				_startTag = tag;
			} else if ([tag.name isEqualToString:kEndTimeFieldName]) {
				_endTag = tag;
			}
		}
		NSAssert(_startTag, @"DBTimeRangeItem: no start tag!");
		NSAssert(_endTag,   @"DBTimeRangeItem: no end tag!");
		
		// initialize start and end time with right now, if
		// necessary (probably is)
		if (! [_startTag.value isKindOfClass:[NSDate class]]) {
			_startTag.value = [NSDate date];
		}
		if (! [_endTag.value isKindOfClass:[NSDate class]]) {
			_endTag.value = [NSDate date];
		}
		
		// recording only triggered by change
		_recording = NO;
		[self setRecording:kStartRecordingWhenCreated];
	}
	return self;
}

// ================================================================
#pragma mark Overrides
// ================================================================

//-(void) notifyChildChanged:(Tag*)tag {
//	if (tag == _st)
//	[super notifyChildChanged:tag];
//}

// ================================================================
#pragma mark Public methods
// ================================================================

-(NSDateComponents*) duration {
	id start = _startTag.value;
	id end = _endTag.value;
	if (! (start && end)) return nil;
	if (! [start isKindOfClass:[NSDate class]]) return nil;
	if (! [end isKindOfClass:[NSDate class]]) return nil;
	return diffBetweenDates(start, end);
}

-(void) setRecording:(BOOL)recording {
	if (_recording == recording) return;
	_recording = recording;
	if (recording) {
		// try incrementing stuff once/min
		_recordingTimer = [NSTimer scheduledTimerWithTimeInterval:kIncrementDurationEverySecs
														   target:self
														 selector:@selector(incrementRecordingTime:)
														 userInfo:nil
														  repeats:YES];
	} else if ([_recordingTimer isValid]) {
		[_recordingTimer invalidate];
	}
}

// ================================================================
#pragma mark Private methods
// ================================================================

-(void) incrementRecordingTime:(NSTimer *)timer {
	if (! [_endTag.value isKindOfClass:[NSDate class]]) return;
	_endTag.value = [_endTag.value dateByAddingTimeInterval:kIncrementDurationEverySecs];
	[self notifyChildChanged:_endTag];
}

NSDateComponents* diffBetweenDates(NSDate *start, NSDate* end) {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSCalendarUnit flags = NSCalendarUnitYear
//	| NSCalendarUnitMonth
//	| NSCalendarUnitDay
	| NSCalendarUnitHour
//	| NSCalendarUnitMinute;
	| NSCalendarUnitMinute
	| NSCalendarUnitSecond;
	return [calendar components:flags fromDate:start toDate:end options:0];
}

-(NSArray*) rm_excludedProperties {
	return @[@"recordingTimer"];
}

@end