//
//  Tag.m
//  Tags
//
//  Created by DB on 1/27/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

// So the basic idea here is that a tag has a Typ instance, and insulates the
// outside world from the fact that such instances are really just dicts or NANs
// Ideally Tag wouldn't know these details of Typ, but at present it does

#import "Tag.h"

#import "Typ.h"

// ================================================================
#pragma mark Interface
// ================================================================

@interface Tag ()
@property(strong, nonatomic) id attrs;
@end

@implementation Tag

// ================================================================
#pragma mark Initialization
// ================================================================

// needs to not freak out cuz used by RMMapper to deserialize...I think
//-(instancetype) init {
//	[NSException raise:@"Tag init: this method unavailable."
//				format:@"Cannot initialize Tag without Typ"];
//	return nil;
//}

-(instancetype) initWithTyp:(Typ*)typ {
	return [self initWithTyp:typ value:[typ defaultValue]];
}

-(instancetype) initWithTyp:(Typ*)typ value:(id)val {
	if (self = [super init]) {
		NSAssert(typ, @"typ must not be nil!");
		_name = typ.name;
		_typ = typ;
		_attrs = val;
		_childTags = computeChildTags(_attrs, typ);
	}
	return self;
}

//------------------------------------------------
// Attribute parsing
//------------------------------------------------
// these two methods basically implement the rule that this tag is
// *either* a whole bunch of child values, or just one value with
// no children; eg, it can't be boolean-valued *and* have children;
// this corresponds to the whole tag being a k-v pair, where the pointer
// is the key and the value is either a dict or a scalar/array
//	-we treat dicts one way, and scalars/arrays the other; it would
//	probably be better to do something sensible with arrays, but at
//	present no typ takes on an array value, so it doesn't matter

-(NSDictionary*) dict {
	if (! [_attrs isKindOfClass:[NSDictionary class]]) return nil;
	return _attrs;
}

-(id) value {
	// this is based on the somewhat hack-ish (but true) assumption that
	// if our attributes are a dictionary, our value is expressed as a
	// collection of children (the dict's keys), rather than a single entity
	if ([self dict]) return nil;
	return _attrs;
}

//------------------------------------------------
// Tag creation
//------------------------------------------------

NSArray* computeChildTags(NSDictionary* attrsDict, Typ* myTyp) {
	// no child attributes -> no child tags
	if (! [attrsDict respondsToSelector:@selector(count)]) return nil;
	if (! [attrsDict count]) return nil;
	
	NSMutableArray* tags = [NSMutableArray array];
	
	// for each field in our typ, create a tag with
	// that field's typ and our value for that field
	NSDictionary* fields = [myTyp allFields];
	for (NSString* key in [fields allKeys]) {
		Typ* typ = fields[key];
		id val = attrsDict[key];
		Tag* tag = [[Tag alloc] initWithTyp:typ value:val];
		tag.name = key;
		[tags addObject:tag];
	}
	return tags;
}

@end
