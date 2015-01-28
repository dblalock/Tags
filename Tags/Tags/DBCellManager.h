//
//  DBCellManager.h
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Typ;
@class UINib;

@interface DBCellManager : NSObject

@end

NSString* reuseIdentifierForTyp(Typ* typ);
UINib* nibForReuseIdentifier(NSString* Id);
NSDictionary* reuseIdsToNibNames();
NSDictionary* reuseIdsToNibs();
