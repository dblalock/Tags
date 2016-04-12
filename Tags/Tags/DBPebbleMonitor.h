//
//  DBPebbleMonitor.h
//  iOSense
//
//  Created by DB on 1/18/15.
//  Copyright (c) 2015 Davis Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TimeUtils.h"	// just for timestamp_t--could just say int64_t

extern const NSUInteger kPebbleAccelHz;
extern const NSUInteger kPebbleAccelPeriodMs;

extern NSString *const kKeyPebbleX;
extern NSString *const kKeyPebbleY;
extern NSString *const kKeyPebbleZ;
extern NSString *const kKeyPebbleTimestamp;
extern NSString *const kKeyPebbleWatch;

extern NSString *const kNotificationPebbleData;
extern NSString *const kNotificationPebbleConnected;
extern NSString *const kNotificationPebbleDisconnected;

@interface DBPebbleMonitor : NSObject
@property (strong, nonatomic, readonly) NSString* connectedPebbleName;

+(instancetype) sharedInstance;

-(void) stopWatchApp;
-(void) startWatchApp;

@end

NSDictionary* pebbleDefaultValuesDict();

float convertPebbleAccelToGs(int accelVal);

// utility func for stuff receiving notification data as a userinfo dict
void extractPebbleData(NSDictionary* userinfo, int* x, int* y, int* z, timestamp_t* t);