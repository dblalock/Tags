//
//  DBTypItem.h
//  Tags
//
//  Created by DB on 1/23/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTableItem.h"

#import "Typ.h"

@interface DBTypItem : DBTableItem

@property(strong, nonatomic, readonly) Typ* typ;

-(instancetype) initWithName:(NSString *)name children:(NSArray *)array NS_UNAVAILABLE;
-(instancetype) initWithName:(NSString *)name children:(NSArray *)array typ:(Typ*)typ NS_DESIGNATED_INITIALIZER;

@end
