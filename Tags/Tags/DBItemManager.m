//
//  DBItemManager.m
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBItemManager.h"

#import "Typ.h"
#import "DBTagItem.h"
#import "DBTimeRangeItem.h"

static NSString *const kKeyTypDefault = @"kTypDefault_Mgr";

@implementation DBItemManager

NSDictionary* typIdsToClasses() {
	static NSDictionary* dict = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dict =
		@{
		  kKeyTypDefault:								[DBTagItem class],
		  [Typ typDatetimeRange].uniqueIDString:	[DBTimeRangeItem class],
		  };
	});
	return dict;
}

Class rawClassForTyp(Typ* typ) {
	NSDictionary* dict = typIdsToClasses();
	NSString* identifier = typ.uniqueIDString;
	return dict[identifier];
}

Class classForTyp(Typ* typ) {
	Class cls = rawClassForTyp(typ);
	if (cls) return cls;
	
	for (Typ* p in [typ allParents]) {
		cls = rawClassForTyp(p);
		if (cls) return cls;
	}
	return typIdsToClasses()[kKeyTypDefault];
}

DBTagItem* createTagItemForTypWithParent(Typ* typ, DBTagItem* parent) {
	// in retrospect, it might have been simpler to just have a big if-else
	// block here; will probably change to this if any subclass ever needs
	// a different initializer
	Class cls = classForTyp(typ);
	NSLog(@"ItemManager: using class %@ for Typ %@", cls, typ);
	return [[cls alloc] initWithTyp:typ parent:parent];
}

DBTagItem* createTagItemForTyp(Typ* typ) {
	return createTagItemForTypWithParent(typ, nil);
}

@end
