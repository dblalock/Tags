//
//  DBLoggingManager.h
//  Tags
//
//  Created by DB on 1/29/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const LOGGING_SUBDIR_PREFIX = @"users/";

static const NSUInteger DATALOGGING_HZ = 20;
static const NSUInteger DATALOGGING_PERIOD_MS = 1000 / DATALOGGING_HZ;

@interface DBLoggingManager : NSObject
@property (nonatomic) BOOL recording;

+(instancetype) sharedInstance;

-(void) deleteLastLogFile;

@end

NSString* loggingSubdir();
