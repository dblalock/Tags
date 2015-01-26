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

// this creates a new typ if the typ isn't provided
-(instancetype) initWithName:(NSString *)name
					children:(NSArray *)children
					  parent:(DBTableItem *)parent
						 typ:(Typ*)typ {
	if (self = [super initWithName:name children:children]) {
		
		// ensure that we have a valid type
		if (! typ) {
			if ([parent isKindOfClass:[DBTypItem class]]) {
				Typ* parentTyp = ((DBTypItem*)parent).typ;
				typ = [Typ typWithName:name parents:@[parentTyp]];
			} else {
				typ = [Typ typWithName:name];
			}
		}
		_typ = typ;
		
		// hook up parent
		[parent addChild:self];
		self.parent = parent;
		
		NSLog(@"created typItem with typ: %@", self.typ);
	}
	return self;
}

-(instancetype) initWithName:(NSString *)name
					  parent:(DBTableItem *)parent {
	return [self initWithName:name children:nil parent:parent typ:nil];
}

-(instancetype) initWithName:(NSString *)name typ:(Typ*)typ {
	return [self initWithName:name children:nil parent:nil typ:typ];
}

-(void) setName:(NSString *)name {
	NSLog(@"TypItem: setting name to %@", name);
	if ([name isEqualToString:self.name]) return;
	self.typ.name = name;
	[super setName:name];
}

@end
