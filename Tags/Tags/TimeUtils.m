//
//  Utils.m
//  DisplayAcc
//
//  Created by DB on 1/7/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "TimeUtils.h"

#import <Foundation/Foundation.h>
#import <NSDate+Escort.h>

// ================================================================
// timestamp_t funcs
// ================================================================

timestamp_t currentTimeStampMs() {
	return [@(floor([[NSDate date] timeIntervalSince1970] * 1000)) longLongValue];
}

timestamp_t maxTimeStampMs() {
	// 2^63 - 1, avoiding overflow from actually doing 2^63
	return (((int64_t) 1) << 62) + ((((int64_t) 1) << 62) - 1);
}

timestamp_t minTimeStampMs() {
	return (-maxTimeStampMs()) - 1;
}

timestamp_t timeStampfromTimeInterval(NSTimeInterval interval) {
	return floor(interval * 1000);	// NSTimeInterval == double
}

timestamp_t timeStampFromDate(NSDate* date) {
	return timeStampfromTimeInterval([date timeIntervalSince1970]);
}

// time since 1970 that coremotion considers to be 0
timestamp_t coreMotionStartTimeMs() {
	static timestamp_t offset = 0;
	if (! offset) {
		NSTimeInterval uptime = [NSProcessInfo processInfo].systemUptime;
		NSTimeInterval nowTimeIntervalSince1970 = [[NSDate date] timeIntervalSince1970];
		offset = nowTimeIntervalSince1970 - uptime;
	}
	return offset * 1000;
}

// core motion gives timestamps from system boot, not unix timestamps,
// so we need to add the time at which the system booted; note that this
// seems to be like a second off
timestamp_t timeStampFromCoreMotionTimeStamp(NSTimeInterval timestamp) {
	return coreMotionStartTimeMs() + timeStampfromTimeInterval(timestamp);
}

// ================================================================
// date funcs
// ================================================================

NSDate* currentDay() {
	return [[NSDate date] dateAtStartOfDay];
}

BOOL datesOnSameDay(NSDate* date1, NSDate* date2) {
	if (! date1 || ! date2 ) return false;
	return [[date1 dateAtStartOfDay] isEqualToDate:[date2 dateAtStartOfDay]];
}

BOOL dateInToday(NSDate* date) {
	return datesOnSameDay(date, [NSDate date]);
}

// ================================================================
// other funcs
// ================================================================

int64_t currentTimeMs() {
	return [@(floor([[NSDate date] timeIntervalSince1970] * 1000)) longLongValue];
}

NSDateFormatter* isoDateFormatter() {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	//	NSString* localId = [[NSLocale currentLocale] localeIdentifier];
	//	NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:];
//	[dateFormatter setLocale:[NSLocale currentLocale]];
	NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	[dateFormatter setLocale:enUSPOSIXLocale];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
	return dateFormatter;
}

// like the above, but underscores instead of colons; however, the ZZZZZ
// will end up having a colon in it, so this isn't safe for other funcs to
// use (only used in currentTimeStrForFileName(), below, which deals with
// this behavior)
NSDateFormatter* isoDateFormatterForFileName() {
	NSDateFormatter *dateFormatter = isoDateFormatter();
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH_mm_ssZZZZZ"];
	return dateFormatter;
}

NSString* timeStrForDate(NSDate* date) {
	return [isoDateFormatter() stringFromDate:date];
}

NSString* timeStrForDateForFileName(NSDate* date) {
	NSString* str = [isoDateFormatterForFileName() stringFromDate:date];
	return [str stringByReplacingOccurrencesOfString:@":" withString:@"_"];
}

NSString* currentTimeStr() {
	return timeStrForDate([NSDate date]);
}

NSString* currentTimeStrForFileName() {
	return timeStrForDateForFileName([NSDate date]);
}


