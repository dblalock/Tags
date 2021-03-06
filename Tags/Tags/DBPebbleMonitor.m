//
//  DBPebbleMonitor.m
//  iOSense
//
//  Created by DB on 1/18/15.
//  Copyright (c) 2015 Rafael Aguayo. All rights reserved.
//

#import "DBPebbleMonitor.h"

#import <UIKit/UIAlertView.h>
#import <PebbleKit/PebbleKit.h>

const NSUInteger kPebbleAccelHz = 20;
const NSUInteger kPebbleAccelPeriodMs = 1000 / kPebbleAccelHz;

static NSString *const kPebbleAppUUID = @"00674CB5-AFEE-464D-B791-5CDBA233EA93";

// keys in dict the pebble app sends
//static const uint8_t KEY_TRANSACTION_ID = 0x1;	//unused
static const uint8_t kKeyNumBytes		= 0x2;
static const uint8_t kKeyData           = 0x3;

NSString *const kKeyPebbleX = @"PebX";
NSString *const kKeyPebbleY = @"PebY";
NSString *const kKeyPebbleZ = @"PebZ";
NSString *const kKeyPebbleTimestamp = @"PebT";
NSString *const kKeyPebbleWatch = @"PebWatch";

NSString *const kNotificationPebbleData = @"PebbleMonitorNotifyData";
NSString *const kNotificationPebbleConnected = @"PebbleMonitorNotifyConnected";
NSString *const kNotificationPebbleDisconnected = @"PebbleMonitorNotifyDisconnected";

#define DEFAULT_ACCEL_VALUE @(NAN)

NSDictionary* pebbleDefaultValuesDict() {
	return @{kKeyPebbleX: DEFAULT_ACCEL_VALUE,
			 kKeyPebbleY: DEFAULT_ACCEL_VALUE,
			 kKeyPebbleZ: DEFAULT_ACCEL_VALUE};
}

//===============================================================
#pragma mark Properties
//===============================================================

@interface DBPebbleMonitor () <PBPebbleCentralDelegate>
@property (nonatomic, readonly) BOOL pebbleConnected;
@property (strong, nonatomic) PBWatch *myWatch;
@property (nonatomic) BOOL launchedApp;

@end

//===============================================================
#pragma mark Implementation
//===============================================================

@implementation DBPebbleMonitor

+(instancetype) sharedInstance {
	static DBPebbleMonitor* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

//--------------------------------
// initialization
//--------------------------------

-(instancetype) init {
	if (self = [super init]) {
		_launchedApp = NO;
		
		// pebble connection + callbacks
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self setupPebble];
		});
	}
	return self;
}

//--------------------------------
// utility funcs
//--------------------------------

- (void)setPebbleUUID:(NSString*)uuidStr {
	NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:uuidStr];
//	NSLog(@"Setting app uuid to %@", kPebbleAppUUID);
	[[PBPebbleCentral defaultCentral] setAppUUID:myAppUUID];
}

- (void)setupPebble {
	[PBPebbleCentral setLogLevel:PBPebbleKitLogLevelDebug];
//	[PBPebbleCentral setLogLevel:PBPebbleKitLogLevelError];
	[self setPebbleUUID:kPebbleAppUUID];
	[[PBPebbleCentral defaultCentral] setDelegate:self];
	[[PBPebbleCentral defaultCentral] run];
	
	self.myWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
	_connectedPebbleName = self.myWatch.name;
	NSLog(@"Last connected watch: %@", self.myWatch);
	
	NSArray* connectedWatches = [[PBPebbleCentral defaultCentral] connectedWatches];
	for (NSString* watch in connectedWatches) {
		NSLog(@"%@", watch);
	}
	if ([connectedWatches count] == 0) {
		NSLog(@"No connected watches...");
	}
}

- (void)startWatchApp {
	
	[self.myWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
		if (!error) {
			NSLog(@"Successfully launched app.");
		} else {
			NSLog(@"Error launching app: %@", error);
		}
	}];
	
//	__block int counter = 0;
	NSLog(@"PebbleMonitor: subscribing to updates");
	
	// subscribe to updates once; subscribing will fail if there aren't
	// any connected watches, so don't store that we've subscribed until
	// it will actually work
	if (_launchedApp) return;
	if ([[[PBPebbleCentral defaultCentral] connectedWatches] count]) {
		_launchedApp = YES;
	}
	NSLog(@"PebbleMonitor: actually subscribing to updates because we hadn't before");
	[self.myWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
		[self logUpdate:update fromWatch:watch];
		return YES;
	}];
}

- (void)stopWatchApp {
	[self.myWatch appMessagesKill:^(PBWatch *watch, NSError *error) {
		if(error) {
			NSLog(@"Error closing watchapp: %@", error);
		}
	}];
	
	_launchedApp = NO;
}

//--------------------------------
// PBPebbleCentralDelegate
//--------------------------------

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
	[[[UIAlertView alloc] initWithTitle:@"Connected!"
								message:[watch name]
							   delegate:nil cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
	_pebbleConnected = YES;
	NSLog(@"Pebble connected: %@", [watch name]);
	self.myWatch = watch;
	_connectedPebbleName = [watch name];
	[self startWatchApp];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPebbleConnected
														object:self
													  userInfo:@{kKeyPebbleWatch: watch}];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
	_pebbleConnected = NO;
//	[self logAccelX:NONSENSICAL_DOUBLE
//				  Y:NONSENSICAL_DOUBLE
//				  Z:NONSENSICAL_DOUBLE
//		  timeStamp:currentTimeStampMs()];
	NSLog(@"Pebble disconnected: %@", [watch name]);
	
	if (self.myWatch == watch || [watch isEqual:self.myWatch]) {
		self.myWatch = nil;
		_connectedPebbleName = nil;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPebbleDisconnected
														object:self
													  userInfo:@{kKeyPebbleWatch: watch}];
}

//--------------------------------
// Data processing
//--------------------------------

float convertPebbleAccelToGs(int accelVal) {
	return accelVal / 64.f;
}

void extractPebbleData(NSDictionary* data, int*x, int*y, int*z, timestamp_t* t) {
	*x = [data[kKeyPebbleX] intValue];
	*y = [data[kKeyPebbleY] intValue];
	*z = [data[kKeyPebbleZ] intValue];
	*t = [data[kKeyPebbleTimestamp] longLongValue];
}

- (BOOL)logUpdate:(NSDictionary*)update fromWatch:(PBWatch*)watch {
	
	//	int transactionId = (int) [[update objectForKey:@(KEY_TRANSACTION_ID)] integerValue];
	int numBytes = (int) [[update objectForKey:@(kKeyNumBytes)] integerValue];
	NSData* accelData = [update objectForKey:@(kKeyData)];
	const int8_t* dataAr = (const int8_t*) [accelData bytes];
	
//	NSLog(@"PebbleMonitor: received %d bytes\n", numBytes);
	
	// compute start time of this buffer
	uint numSamples = numBytes / 3;
	uint bufferDuration = numSamples * kPebbleAccelPeriodMs;
	timestamp_t startTime = currentTimeStampMs() - bufferDuration;
	
	int8_t x, y, z;
	timestamp_t sampleTime;
	for (int i = 0; i < numBytes; i += 3) {
		x = dataAr[i];
		y = dataAr[i+1];
		z = dataAr[i+2];
		
		// logging
		sampleTime = startTime + (i/3) * kPebbleAccelPeriodMs;
		NSDictionary* data = @{kKeyPebbleX: @(x),
							   kKeyPebbleY: @(y),
							   kKeyPebbleZ: @(z),
							   kKeyPebbleTimestamp: @(sampleTime),
							   kKeyPebbleWatch:watch};
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPebbleData
															object:self userInfo:data];
	}
	return YES;
}

@end
