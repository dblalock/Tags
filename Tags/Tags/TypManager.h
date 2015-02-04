//
//  TypManager.h
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

// TODO rename this to PersistManager, since that's what it's actually doing

#import <Foundation/Foundation.h>

@interface TypManager : NSObject

@end

NSArray* defaultTypItems();
NSArray* getAllTypItems();
void saveTypItems(NSArray* items);

NSArray* defaultTagItems();
//NSArray* getAllTagItems();
NSArray* getTagItemsForDate(NSDate* date);
void saveTagItems(NSArray* items);
void saveTagItemsForDate(NSArray* items, NSDate* date);

void logTagItems(NSArray* items);
void logTagItemsForDate(NSArray* items, NSDate* date);

NSString* dayKeyForDate(NSDate* date);
