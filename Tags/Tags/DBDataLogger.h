//
//  DBDataLogger.h
//  DisplayAcc
//
//  Created by DB on 1/8/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TimeUtils.h"

// ================================================================
// DBLogger
// ================================================================

static const NSUInteger kDefaultLoggingSampleRateHz = 20;
static const NSUInteger kDefaultLoggingSamplePeriodMs = 50;

// nothing here is threadsafe, so need to access it only from main thread
@interface DBDataLogger : NSObject

@property(nonatomic) timestamp_t autoFlushLagMs;
@property(nonatomic) timestamp_t gapThresholdMs;
@property(strong, nonatomic) NSString* logName;
@property(strong, nonatomic) NSString* logSubdir;
@property(nonatomic) BOOL omitDuplicates;

-(id) initWithSignalDefaultsDict:(NSDictionary*)names2defaults
					samplePeriod:(NSUInteger)ms;
-(id) initWithSignalDefaultsDict:(NSDictionary*)names2defaults
						dataType:(NSString*)type;
-(id) initWithSignalDefaultsDict:(NSDictionary*)names2defaults
					samplePeriod:(NSUInteger)ms
						dataType:(NSString*)type;
-(id) initWithSignalNames:(NSArray*)names
			defaultValues:(NSArray*)defaults
			 samplePeriod:(NSUInteger)ms
                 dataType:(NSString*)type NS_DESIGNATED_INITIALIZER;

-(void) logData:(NSDictionary*)kvPairs withTimeStamp:(timestamp_t)ms;
-(void) logData:(NSDictionary*)kvPairs;
-(void) logDataBuff:(NSArray*)sampleDicts
  withSampleSpacing:(NSUInteger)periodMs
	 finalTimeStamp:(timestamp_t)ms;
-(void) logDataBuff:(NSArray*)sampleDicts
  withSampleSpacing:(NSUInteger)periodMs;

-(void) startLog;
-(void) pauseLog;
-(void) endLog;
-(void) cancelLog;
-(void) deleteLog; // no guarantee it hasn't already been uploaded, though

-(void) flushUpToTimeStamp:(timestamp_t)ms;
-(void) flush;

@end

// basically just for accelerometer x,y,z crammed into one array
NSArray* rawArrayToSampleBuff(id* array, int len, NSArray* keys);
