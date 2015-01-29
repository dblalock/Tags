//
//  MiscUtils.h
//  iOSense
//
//  Created by DB on 1/11/15.
//  Copyright (c) 2015 DB. All rights reserved.
//

#ifndef iOSense_MiscUtils_h
#define iOSense_MiscUtils_h

#import <Foundation/Foundation.h>

@class UIViewController;

NSString* getAppName();

NSUInteger getUniqueDeviceIdentifierUInt();
NSUUID* getUniqueDeviceIdentifierUUID();
NSString * getUniqueDeviceIdentifierAsString();
uint64_t getUniqueDeviceIdentifier64bits();

UIViewController* getRootViewController();

BOOL isFloatingPointNumber(id x);
BOOL objsDifferent(id x, id y);

#endif
