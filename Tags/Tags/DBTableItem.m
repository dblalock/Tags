//
//  DBTableItem.m
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTableItem.h"

@implementation DBTableItem

-(instancetype) init {
	if (self = [super init]) {
		_children = [NSMutableArray array];
	}
	return self;
}

- (void)addChild:(DBTableItem*)child {
	if ([_children containsObject:child]) return;
	[_children insertObject:child atIndex:0];
}

- (void)removeChild:(DBTableItem*)child {
	[_children removeObject:child];
}

-(void) setChildren:(NSMutableArray *)children {
	if ([children count]) {
		_children = [NSMutableArray arrayWithArray:children];
	} else {
		_children = [NSMutableArray array];
	}
}

-(void) setName:(NSString *)name {
	if ([name isEqualToString:self.name]) return;
	_name = name;
}

+(NSString*) reuseIdentifier {
	return NSStringFromClass([self class]);
}
-(NSString*) reuseIdentifier {
	return [[self class] reuseIdentifier];
}

@end
