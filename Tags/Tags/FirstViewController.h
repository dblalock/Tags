//
//  FirstViewController.h
//  Tags
//
//  Created by DB on 1/21/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DBTreeViewController.h"

static NSString *const kNotificationTypSelected = @"TypSelected";
static NSString *const kKeyNotificationTyp = @"keyTyp";

@class Typ;

@interface FirstViewController : DBTreeViewController
@end

Typ* extractTypFromNotification(NSNotification* notification);