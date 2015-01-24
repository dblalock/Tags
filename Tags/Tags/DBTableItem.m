//
//  DBTableItem.m
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTableItem.h"

@implementation DBTableItem

+(void) joinParent:(DBTableItem*)parent toChild:(DBTableItem*)child {
	child.parent = parent;
	[parent addChild:child];
}

+ (id)itemWithName:(NSString *)name children:(NSArray *)children {
	return [[self alloc] initWithName:name children:children];
}

- (id)initWithName:(NSString *)name children:(NSArray *)children {
	self = [super init];
	if (self) {
		_name = name;
		_parent = nil;
		if ([children count]) {
			_children = [NSMutableArray arrayWithArray:children];
		} else {
			_children = [NSMutableArray array];
		}
	}
	return self;
}

- (void)addChild:(DBTableItem*)child {
//	NSMutableArray *children = [self.children mutableCopy];
	[_children insertObject:child atIndex:0];
//	_children = [children copy];
}

- (void)removeChild:(DBTableItem*)child {
//	NSMutableArray *children = [self.children mutableCopy];
	[_children removeObject:child];
//	_children = [children copy];
}

+(NSString*) reuseIdentifier {
	return NSStringFromClass([self class]);
}
-(NSString*) reuseIdentifier {
	return [[self class] reuseIdentifier];
}

@end