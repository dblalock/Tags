//
//  DBTagItem.m
//  Tags
//
//  Created by DB on 1/27/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTagItem.h"

#import "Typ.h"
#import "Tag.h"

// ================================================================
#pragma mark Interface
// ================================================================

@interface DBTagItem ()
@property(strong, nonatomic) Tag* tag;
@end

// ================================================================
#pragma mark Initialization
// ================================================================

@implementation DBTagItem

-(instancetype) initWithTag:(Tag*)tag parent:(DBTableItem*)parent {
	if (self = [super init]) {
		self.tag = tag;
		self.name = tag.typ.name;
		self.parent = parent;
		
		if (! [tag.childTags count]) {
			self.children = nil;
		} else {
			for (Tag* t in tag.childTags) {
				DBTagItem* item = [[DBTagItem alloc] initWithTag:t parent:self];
				[self addChild:item];
			}
		}
	}
	return self;
}

-(instancetype) initWithTyp:(Typ*)typ parent:(DBTableItem*)parent {
	Tag* tag = [[Tag alloc] initWithTyp:typ];
	return [self initWithTag:tag];
}

-(instancetype) initWithTag:(Tag*)tag {
	return [self initWithTag:tag parent:nil];
}

-(instancetype) initWithTyp:(Typ*)typ {
	return [self initWithTyp:typ parent:nil];
}

@end
