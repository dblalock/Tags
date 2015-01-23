//
//  DBTypItem.m
//  Tags
//
//  Created by DB on 1/23/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTypItem.h"

@implementation DBTypItem

-(instancetype) initWithName:(NSString *)name children:(NSArray *)array {
	[NSException raise:@"Cannot initialize TypItem without Typ"
				format:@"In TypItem with name %@", name];
	return nil;
}

-(instancetype) initWithName:(NSString *)name children:(NSArray *)array typ:(Typ*)typ {
	if (self = [super initWithName:name children:array]) {
		_typ = typ;
	}
	return self;
}

@end
