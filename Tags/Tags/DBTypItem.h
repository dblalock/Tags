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

-(instancetype) initWithName:(NSString *)name
					children:(NSArray *)children NS_UNAVAILABLE;

-(instancetype) initWithName:(NSString *)name
					children:(NSArray *)children
					  parent:(DBTableItem *)parent
						 typ:(Typ*)typ NS_DESIGNATED_INITIALIZER;

-(instancetype) initWithName:(NSString *)name
					  parent:(DBTableItem*)parent;

-(instancetype) initWithName:(NSString *)name typ:(Typ*)typ;

@end
