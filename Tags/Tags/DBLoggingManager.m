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
#import "DBMicrosoftBandMonitor.h"
#import "DBSensorMonitor.h"
#import "DBBackgrounder.h"

#import "MiscUtils.h"

//===============================================================
#pragma mark Consts
//===============================================================

#define DEFAULT_VALUE_ACCEL DBINVALID_ACCEL

// how often to flush log
static const uint flushEveryMs = 30*1000;	//30s

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
NSArray* defaultValuesPebble(){
    NSDictionary* dict = pebbleDefaultValuesDict();
    NSMutableArray* vals = [NSMutableArray array];
    for (id key in [pebbleDefaultValuesDict() allKeys]){
        [vals addObject:[dict valueForKey:key]];
    }
    return vals;
}
NSString* loggingSubdir() {
	return [LOGGING_SUBDIR_PREFIX stringByAppendingString:getUniqueDeviceIdentifierAsString()];
}

//===============================================================
#pragma mark Properties
//===============================================================

@interface DBLoggingManager ()
@property (strong, nonatomic) DBDataLogger* loggerPebble;
@property (strong, nonatomic) DBDataLogger* loggerMotion;
@property (strong, nonatomic) DBDataLogger* loggerLocation;
@property (strong, nonatomic) DBDataLogger* loggerHeading;
@property (strong, nonatomic) DBDataLogger* loggerMSBand;
@property (strong, nonatomic) NSArray* allLoggers;

@property (strong, nonatomic) DBSensorMonitor* sensorMonitor;
@property (strong, nonatomic) DBPebbleMonitor* pebbleMonitor;
@property (strong, nonatomic) DBBackgrounder* backgrounder;
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
		
		// initialize data loggers for each data source
		_loggerPebble = [[DBDataLogger alloc]
						 initWithSignalDefaultsDict:pebbleDefaultValuesDict()
						 dataType:@"Pebble"];
//		[[DBDataLogger alloc] initWithSignalNames:[pebbleDefaultValuesDict() allKeys]
//												  defaultValues:defaultValuesPebble()
//												   samplePeriod:DATALOGGING_PERIOD_MS
//                                                       dataType:@"Pebble"];
		_loggerMotion = [[DBDataLogger alloc]
						 initWithSignalDefaultsDict:defaultsDictMotion()
						 dataType:@"Motion"];
//		[[DBDataLogger alloc] initWithSignalNames:[defaultsDictMotion() allKeys]
//                                                    defaultValues:defaultValuesMotion()
//                                                     samplePeriod:DATALOGGING_PERIOD_MS
//                                                         dataType:@"Motion"];
		_loggerLocation = [[DBDataLogger alloc]
						   initWithSignalDefaultsDict:defaultsDictLocation()
						   dataType:@"Loc"];
//		[[DBDataLogger alloc] initWithSignalNames:[defaultsDictLocation() allKeys]
//                                                    defaultValues:defaultValuesLocation()
//                                                     samplePeriod:DATALOGGING_PERIOD_MS
//                                                         dataType:@"Loc"];
        _loggerHeading = [[DBDataLogger alloc]
						  initWithSignalDefaultsDict:defaultsDictHeading()
						  dataType:@"Head"];
		_loggerMSBand = [[DBDataLogger alloc]
						 initWithSignalDefaultsDict:msBandDefaultValuesDict()
						 dataType:@"MSBand"];
		
        //NSMutableArray* loggers = [NSMutableArray arrayWithObjects:_dataLoggerPH, _dataLoggerPB, _dataLoggerPL, _dataLoggerPM, nil];
		
		_allLoggers = @[_loggerPebble, _loggerMotion, _loggerLocation,
						_loggerHeading, _loggerMSBand];
		NSString* subdir = loggingSubdir();
		for (DBDataLogger* logger in _allLoggers) {
			logger.autoFlushLagMs = flushEveryMs;
			logger.logSubdir = subdir;
		}
		
		_loggerPebble.autoFlushLagMs = flushEveryMs;	//write every 2s
		_loggerPebble.logSubdir = loggingSubdir();
        _loggerMotion.autoFlushLagMs = flushEveryMs;
        _loggerMotion.logSubdir = loggingSubdir();
        _loggerHeading.autoFlushLagMs = flushEveryMs;
        _loggerHeading.logSubdir = loggingSubdir();
        _loggerLocation.autoFlushLagMs = flushEveryMs;
        _loggerLocation.logSubdir = loggingSubdir();
		
		_sensorMonitor = [[DBSensorMonitor alloc] initWithDataReceivedHandler:^
			void(NSDictionary *data, timestamp_t timestamp, NSString *type) {
				dispatch_async(dispatch_get_main_queue(), ^{	//main thread
					if ([ type isEqualToString:@"motion"]) {
						[_loggerMotion logData:data withTimeStamp:timestamp];
					} else if ([type isEqualToString:@"location"]) {
						[_loggerLocation logData:data withTimeStamp:timestamp];
					} else if ([type isEqualToString:@"heading"]) {
						[_loggerHeading logData:data withTimeStamp:timestamp];
					}
			});
		}];
		_sensorMonitor.sendOnlyIfDifferent = YES;	//TODO want to still send it, but have datalogger ignore
		
//		_pebbleMonitor = [[DBPebbleMonitor alloc] init];
		_pebbleMonitor = [DBPebbleMonitor sharedInstance];
		
		// enable background execution by retaining an intance of this class
		_backgrounder = [[DBBackgrounder alloc] init];
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
    //Logs pebble data
	NSDictionary* kvPairs = @{kKeyPebbleX: @(x / 64.0),
							  kKeyPebbleY: @(y / 64.0),
							  kKeyPebbleZ: @(z / 64.0)};
	[_loggerPebble logData:kvPairs withTimeStamp:sampleTime];
}

-(void) notifiedPebbleData:(NSNotification*)notification {
    //When Pebble produces data, extract and log it
	if ([notification name] != kNotificationPebbleData) return;
	if (! _recording) return;
	
	int x, y, z;
	timestamp_t t;
	extractPebbleData(notification.userInfo, &x, &y, &z, &t);
	
	[self logAccelX:x Y:y Z:z timeStamp:t];
}

-(void) notifiedPebbleDisconnected:(NSNotification*)notification {
    //Notify user if peble is disconnected
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
		[_loggerPebble deleteLog];
	}
}

//===============================================================
#pragma mark Private funcs
//===============================================================

-(void) startRecording {
	_recording = YES;
	[_pebbleMonitor startWatchApp];
	[_loggerPebble startLog];
    [_loggerMotion startLog];
    [_loggerHeading startLog];
    [_loggerLocation startLog];
	[_sensorMonitor poll];
	[_backgrounder setBackgroundEnabled:YES];
}

-(void) stopRecording {
	_recording = NO;
	[_loggerPebble endLog];
    [_loggerMotion endLog];
    [_loggerHeading endLog];
    [_loggerLocation endLog];
	[_pebbleMonitor stopWatchApp];
	[_backgrounder setBackgroundEnabled:NO];
	// TODO stop sensor logging also, esp. GPS
}

@end
