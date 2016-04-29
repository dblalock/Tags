//
//  DBMicrosoftBandMonitor.h
//  Tags
//
//  Created by DB on 4/28/16.
//  Copyright © 2016 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TimeUtils.h"	// just for timestamp_t--could just say int64_t

extern NSString *const kKeyMSBandX;
extern NSString *const kKeyMSBandY;
extern NSString *const kKeyMSBandZ;
extern NSString *const kKeyMSBandTimestamp;
extern NSString *const kKeyMSBand;
extern NSString *const kKeyMSBandError;

extern NSString *const kNotificationMSBandData;
extern NSString *const kNotificationMSBandConnected;
extern NSString *const kNotificationMSBandDisconnected;
extern NSString *const kNotificationMSBandConnectionFailed;

@interface DBMicrosoftBandMonitor : NSObject

+(instancetype) sharedInstance;
-(BOOL) tryStartAccelerometerUpdates;
@end

void extractMSBandData(NSDictionary* data, double*x, double*y, double*z, timestamp_t* t);
NSDictionary* msBandDefaultValuesDict();
