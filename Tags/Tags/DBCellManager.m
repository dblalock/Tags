//
//  DBCellManager.m
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBCellManager.h"

#import <UIKit/UIKit.h>		// for UINib
#import "Typ.h"

#import "DBTreeCell.h"
#import "DBTableItem.h"
//#import "DBTagItem.h"		// ideally, never create this generic cell

static NSString *const kReuseIdentifierDefault = @"reuseIdDefault";

@implementation DBCellManager

@end

// uh oh...if we create a new typ (which happens all the time), it will
// have some random thing as the identifier
//	-so really we need to use either its ID, or search thru its parents
//	and try each of theirs
//	-and if no recognized ID for any parent, just a default DBTreeCell
//
// so we'll have a func that returns the mapping from known typs to known
// nibs, then another function f: Typ* -> nibName that does the search thing
//
//
// wait, new plan; we basically need a DBTreeCell subclass for each Typ
// so that we can give it custom views and have it do things with them,
// so it's way more direct to just let each class automatically override
// standardNib(); this means we really just need to map Typs to cell
// classes.

NSString* rawReuseIdentifierForTyp(Typ* typ) {
	return [typ uniqueIDString];
}

// all we really need are (reuseId, nib) pairs to register at the top of the
// file; the nib will set what class the cell is, so dequeReusable...() will
// return an instance thereof and no other code will even have to know what
// class it is
NSDictionary* reuseIdsToNibNames() {
	static NSDictionary* dict = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dict = 	@{
				  //TODO add in stuff for TreeCell, DBTableItem, etc, not just stuff for typs
				  kReuseIdentifierDefault:							@"DBTagCell",
				  [DBTableItem reuseIdentifier]:					@"DBTreeCell",
//				  [DBTagItem reuseIdentifier]:						@"DBTagCell",
//				  reuseIdentifierForTyp([Typ typString]):		@"DBTextCell",
				  rawReuseIdentifierForTyp([Typ typDatetime]):		@"DBTimeCell",
				  rawReuseIdentifierForTyp([Typ typDatetimeRange]):	@"DBTimeRangeCell",
				  //TODO others
				  };
	});
	return dict;
}

NSDictionary* reuseIdsToNibs() {
	NSDictionary* ids2names = reuseIdsToNibNames();
	NSMutableDictionary* ids2nibs = [NSMutableDictionary dictionary];
	for (NSString* Id in [ids2names allKeys]) {
		ids2nibs[Id] = [UINib nibWithNibName:ids2names[Id] bundle:nil];
		assert(ids2nibs[Id]);
	}
	
	return ids2nibs;
}

// search through typ + its parents to return a recognized identifier;
// if none found, return a default one
NSString* reuseIdentifierForTyp(Typ* typ) {
	NSString* Id = rawReuseIdentifierForTyp(typ);
	NSDictionary* ids2names = reuseIdsToNibNames();
	
	if (ids2names[Id]) return Id;
	
	for (Typ* p in [typ allParents]) {
		Id = rawReuseIdentifierForTyp(p);
		if (ids2names[Id]) return Id;
	}
	
	return kReuseIdentifierDefault;
}

UINib* nibForReuseIdentifier(NSString* Id) {
	NSString* name = reuseIdsToNibNames()[Id];
	if (! [name length]) return nil;
	return [UINib nibWithNibName:name bundle:nil];
}
