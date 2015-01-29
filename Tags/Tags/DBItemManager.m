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
		  [[Typ typDatetimeRange] uniqueIDString]:	[DBTimeRangeItem class],
		  };
	});
	return dict;
}

Class classForTyp(Typ* typ) {
	NSDictionary* dict = typIdsToClasses();
	NSString* identifier = typ.uniqueIDString;
	Class cls = dict[identifier];
	
	return cls ? cls : dict[kKeyTypDefault];
}

DBTagItem* createTagItemForTypWithParent(Typ* typ, DBTagItem* parent) {
	// in retrospect, it might have been simpler to just have a big if-else
	// block here; will probably change to this if any subclass ever needs
	// a different initializer
	Class cls = classForTyp(typ);
	return [[cls alloc] initWithTyp:typ parent:parent];
}

DBTagItem* createTagItemForTyp(Typ* typ) {
	return createTagItemForTypWithParent(typ, nil);
}

@end
