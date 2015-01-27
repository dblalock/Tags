//
//  TypManager.m
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "TypManager.h"

#import "NSUserDefaults+RMSaveCustomObject.h"
#import "Underscore.h"
#define _ Underscore

#import "Typ.h"
#import "DBTypItem.h"

static NSString *const kKeyAllTypItems = @"allTypItems";

@implementation TypManager
@end

// so ideally this would be recursive and we'd deal with {strings, arrays, dicts}
// as {keys, array elements}, but not gonna code that unless I need it
NSArray* typItemsFromDict(NSDictionary* dict) {
	NSMutableArray* items = [NSMutableArray array];
	
	for (NSString* name in [dict allKeys]) {
		// create the Typs
		MutableTyp* parentTyp = [MutableTyp typWithName:name];
		NSArray* childTyps = _.arrayMap(dict[name], ^MutableTyp *(NSString *subtypName) {
			return [MutableTyp typWithName:subtypName parents:@[parentTyp]];
		});
		
		// create the TypItems
		DBTypItem* parentItem = [[DBTypItem alloc] initWithName:name typ:parentTyp];
		for (Typ* childTyp in childTyps) {
			DBTypItem* childItem = [[DBTypItem alloc] initWithName:childTyp.name typ:childTyp];
			[parentItem addChild:childItem];
		}
		
		// only add the parent--we just want the top level, and the rest will
		// still be accessible as the parents' children
		[items addObject:parentItem];
	}
	return items;
}

NSDictionary* defaultTypsDict() {
	return @{
			 @"Working": @[@"Coding", @"Papers", @"Thinking", @"Meeting"],
			 @"Lifting": @[@"Squat", @"Deadlift", @"Bench Press"],
			 @"Moving": @[@"Sitting", @"Standing", @"Walking", @"Jogging", @"Bus", @"Train", @"Car"],
			 @"Health": @[@"Washing Hands", @"Taking Pills", @"Bathroom"],
			 @"Eating": @[@"Pizza", @"Candy", @"Ice Cream", @"Hamburger", @"Hot Dog", @"Meat", @"Vegetables", @"Soup", @"Orange", @"Banana", @"Apple", @"Roll"],
			 @"Drinking": @[@"Can", @"Bottle", @"Cup"]
			 };
}

NSArray* defaultTypItems() {
	return typItemsFromDict(defaultTypsDict());
}

void saveTypItems(NSArray* typItems) {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults rm_setCustomObject:typItems forKey:kKeyAllTypItems];
//	[defaults synchronize];
}

NSArray* getAllTypItems() {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSArray* typItems = [defaults rm_customObjectForKey:kKeyAllTypItems];
	if (! typItems) {
		typItems = defaultTypItems();
	}
	return typItems;
}






