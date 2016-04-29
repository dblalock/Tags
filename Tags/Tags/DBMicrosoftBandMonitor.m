//
//  DBMicrosoftBandMonitor.m
//  Tags
//
//  Created by DB on 4/28/16.
//  Copyright © 2016 D Blalock. All rights reserved.
//

#import "DBMicrosoftBandMonitor.h"

#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>


const NSUInteger kMSBandAccelHz = 31;
const NSUInteger kMSBandAccelPeriodMs = 1000 / kMSBandAccelHz;

const float kTrySubscribeAccelEverySecs = 2.0f;

NSString *const kKeyMSBandX = @"MSBandX";
NSString *const kKeyMSBandY = @"MSBandY";
NSString *const kKeyMSBandZ = @"MSBandZ";
NSString *const kKeyMSBandTimestamp = @"MSBandTimestamp";
NSString *const kKeyMSBand = @"MSBand";
NSString *const kKeyMSBandError = @"MSBandError";

NSString *const kNotificationMSBandData = @"MSBandMonitorNotifyData";
NSString *const kNotificationMSBandConnected = @"MSBandMonitorNotifyConnected";
NSString *const kNotificationMSBandDisconnected = @"MSBandMonitorNotifyDisconnected";
NSString *const kNotificationMSBandConnectionFailed = @"MSBandMonitorNotifyConnectionFailed";

#define DEFAULT_ACCEL_VALUE @(NAN)

NSDictionary* msBandDefaultValuesDict() {
	return @{kKeyMSBandX: DEFAULT_ACCEL_VALUE,
			 kKeyMSBandY: DEFAULT_ACCEL_VALUE,
			 kKeyMSBandZ: DEFAULT_ACCEL_VALUE};
}

//===============================================================
#pragma mark Interface
//===============================================================

@interface DBMicrosoftBandMonitor () <MSBClientManagerDelegate>
@property (nonatomic, weak) MSBClient *client;
@property (atomic) BOOL subscribedToAccel;

-(BOOL) tryStartAccelerometerUpdates;

@end

//===============================================================
#pragma mark Implementation
//===============================================================

@implementation DBMicrosoftBandMonitor

+(instancetype) sharedInstance {
	static DBMicrosoftBandMonitor* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

-(instancetype) init {
	if (self = [super init]) {
		// Setup Band
		[MSBClientManager sharedManager].delegate = self;

		_subscribedToAccel = NO;
		[self startTryToSubscribetoDataLoop];
	}
	return self;
}

-(BOOL) tryConnect {
	if (self.client) {
		return YES;
	}
	NSArray	*clients = [[MSBClientManager sharedManager] attachedClients];
	self.client = [clients firstObject];
	if (self.client == nil) {
		NSLog(@"MSBandMonitor: init failed! No bands attached.");
		return NO;
	}
	[[MSBClientManager sharedManager] connectClient:self.client];
	return YES;
}

void logAccelUpdate(MSBSensorAccelerometerData* data) {
	timestamp_t time = currentTimeStampMs();
	NSDictionary* dict = @{kKeyMSBandX: @(data.x),
						   kKeyMSBandY: @(data.y),
						   kKeyMSBandZ: @(data.z),
						   kKeyMSBandTimestamp: @(time)};
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMSBandData
														object:nil
													  userInfo:dict];
}

-(BOOL) tryStartAccelerometerUpdates {
	if (![self tryConnect]) { return NO; }
	if (_subscribedToAccel) { return YES; }
	
	void (^handler)(MSBSensorAccelerometerData *, NSError *) =
		^(MSBSensorAccelerometerData *data, NSError *error) {
			logAccelUpdate(data);
		};

	NSError *err;
	if (![self.client.sensorManager startAccelerometerUpdatesToQueue:nil
															errorRef:&err
														 withHandler:handler])
	{
		NSLog(@"MSBand: couldn't subscribe to accelerometer: %@", err.description);
		_subscribedToAccel = NO;
		return NO;
	}
	_subscribedToAccel = YES;
	return YES;
}

-(void) startTryToSubscribetoDataLoop {
	[NSTimer scheduledTimerWithTimeInterval:kTrySubscribeAccelEverySecs
									 target:self
								   selector:@selector(tryStartAccelerometerUpdates)
								   userInfo:nil repeats:YES];
}

void extractMSBandData(NSDictionary* data, double*x, double*y, double*z, timestamp_t* t) {
	*x = [data[kKeyMSBandX] doubleValue];
	*y = [data[kKeyMSBandY] doubleValue];
	*z = [data[kKeyMSBandZ] doubleValue];
	*t = [data[kKeyMSBandTimestamp] longLongValue];
}

//--------------------------------
#pragma mark - MSBClientManagerDelegate
//--------------------------------

- (void)clientManager:(MSBClientManager *)clientManager clientDidConnect:(MSBClient *)client
{
	[[[UIAlertView alloc] initWithTitle:@"Connected!"
								message:client.name
							   delegate:nil cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
	NSLog(@"%@", [NSString stringWithFormat:@"Band %@ connected", client.name]);
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMSBandConnected
														object:self
													  userInfo:@{kKeyMSBand: client}];
}

- (void)clientManager:(MSBClientManager *)clientManager clientDidDisconnect:(MSBClient *)client
{
	NSLog(@"%@", [NSString stringWithFormat:@"Band %@ disconnected", client.name]);
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMSBandDisconnected
														object:self
													  userInfo:@{kKeyMSBand: client}];
}

- (void)clientManager:(MSBClientManager *)clientManager client:(MSBClient *)client didFailToConnectWithError:(NSError *)error
{
	NSLog(@"%@", [NSString stringWithFormat:@"Failed to connect to band %@", client.name]);
	NSLog(@"%@", [NSString stringWithFormat:@"Error: %@", error.description]);
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMSBandConnectionFailed
														object:self
													  userInfo:@{kKeyMSBand: client,
																 kKeyMSBandError: error}];
}

@end
