//
//  DBLoggingManager.m
//  Tags
//
//  Created by DB on 1/29/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBLoggingManager.h"

#import <UIKit/UIKit.h>

#import "DBDataLogger.h"
#import "DBPebbleMonitor.h"
#import "DBSensorMonitor.h"

#import "MiscUtils.h"

//===============================================================
#pragma mark Consts
//===============================================================

#define DEFAULT_VALUE_ACCEL DBINVALID_ACCEL

//===============================================================
#pragma mark Configuration funcs
//===============================================================

NSDictionary* combinedDefaultsDict() {
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict addEntriesFromDictionary:allSensorDefaultsDict()];
	[dict addEntriesFromDictionary:pebbleDefaultValuesDict()];
	return dict;
}

NSArray* allDataKeys() {
	// sort stuff for consistency across runs
	return [[combinedDefaultsDict() allKeys] sortedArrayUsingSelector: @selector(compare:)];
}

NSArray* allDataDefaultValues() {
	NSDictionary* dict = combinedDefaultsDict();
	NSMutableArray* values = [NSMutableArray array];
	for (id key in allDataKeys()) {
		[values addObject:[dict valueForKey:key]];
	}
	return values;
}

NSString* loggingSubdir() {
	return [LOGGING_SUBDIR_PREFIX stringByAppendingString:getUniqueDeviceIdentifierAsString()];
}

//===============================================================
#pragma mark Properties
//===============================================================

@interface DBLoggingManager ()
@property (strong, nonatomic) DBDataLogger* dataLogger;
@property (strong, nonatomic) DBSensorMonitor* sensorMonitor;
@property (strong, nonatomic) DBPebbleMonitor* pebbleMonitor;

@end


@implementation DBLoggingManager

//===============================================================
#pragma mark Initialization
//===============================================================

-(instancetype)init {
	if (self = [super init]) {
		// state flags
		_recording = NO;
		
		// pebble
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(notifiedPebbleData:)
													 name:kNotificationPebbleData
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(notifiedPebbleDisconnected:)
													 name:kNotificationPebbleDisconnected
												   object:nil];
		
		// data logging
		_dataLogger = [[DBDataLogger alloc] initWithSignalNames:allDataKeys()
												  defaultValues:allDataDefaultValues()
												   samplePeriod:DATALOGGING_PERIOD_MS];
		_dataLogger.autoFlushLagMs = 2000;	//write every 2s
		_dataLogger.logSubdir = loggingSubdir();
		_sensorMonitor = [[DBSensorMonitor alloc] initWithDataReceivedHandler:^
						  void(NSDictionary *data, timestamp_t timestamp) {
							  dispatch_async(dispatch_get_main_queue(), ^{	//main thread
								  [_dataLogger logData:data withTimeStamp:timestamp];
							  });
						  }
						  ];
		_sensorMonitor.sendOnlyIfDifferent = YES;	//TODO want to still send it, but have datalogger ignore
		
		_pebbleMonitor = [[DBPebbleMonitor alloc] init];
	}
	return self;
}


-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


//===============================================================
#pragma mark Pebble
//===============================================================

-(void) logAccelX:(double)x Y:(double)y Z:(double)z timeStamp:(timestamp_t)sampleTime {
	NSDictionary* kvPairs = @{kKeyPebbleX: @(x / 64.0),
							  kKeyPebbleY: @(y / 64.0),
							  kKeyPebbleZ: @(z / 64.0)};
	[_dataLogger logData:kvPairs withTimeStamp:sampleTime];
}

-(void) notifiedPebbleData:(NSNotification*)notification {
	if ([notification name] != kNotificationPebbleData) return;
	if (! _recording) return;
	
	int x, y, z;
	timestamp_t t;
	extractPebbleData(notification.userInfo, &x, &y, &z, &t);
	
	[self logAccelX:x Y:y Z:z timeStamp:t];
}

-(void) notifiedPebbleDisconnected:(NSNotification*)notification {
	if ([notification name] != kNotificationPebbleDisconnected) return;
	[self logAccelX:NONSENSICAL_DOUBLE
				  Y:NONSENSICAL_DOUBLE
				  Z:NONSENSICAL_DOUBLE
		  timeStamp:currentTimeStampMs()];
	
	[[[UIAlertView alloc] initWithTitle:@"Pebble Disconnected!"
								message:[notification.userInfo[kKeyPebbleWatch] name]
							   delegate:nil
					  cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

//===============================================================
#pragma mark Public funcs
//===============================================================

+(instancetype) sharedInstance {
	static DBLoggingManager* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

-(void) setRecording:(BOOL)recording {
	if (recording == _recording) return;
	_recording = recording;
	if (recording) {
		[self startRecording];
	} else {
		[self stopRecording];
	}
}

-(void) deleteLastLogFile {
	if (!_recording) {
		[_dataLogger deleteLog];
	}
}

//===============================================================
#pragma mark Private funcs
//===============================================================

-(void) startRecording {
	_recording = YES;
	[_pebbleMonitor startWatchApp];
	[_dataLogger startLog];
	[_sensorMonitor poll];
}

-(void) stopRecording {
	_recording = NO;
	[_dataLogger endLog];
	[_pebbleMonitor stopWatchApp];
	// TODO stop sensor logging also, esp. GPS
}

@end
