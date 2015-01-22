//
//  DBTableItem.m
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTableItem.h"

@implementation DBTableItem

+ (id)itemWithName:(NSString *)name children:(NSArray *)children {
	return [[self alloc] initWithName:name children:children];
}

- (id)initWithName:(NSString *)name children:(NSArray *)children {
	self = [super init];
	if (self) {
		self.children = [NSArray arrayWithArray:children];
		self.name = name;
	}
	return self;
}

- (void)addChild:(DBTableItem*)child {
	NSMutableArray *children = [self.children mutableCopy];
	[children insertObject:child atIndex:0];
	self.children = [children copy];
}

- (void)removeChild:(DBTableItem*)child {
	NSMutableArray *children = [self.children mutableCopy];
	[children removeObject:child];
	self.children = [children copy];
}

@end
