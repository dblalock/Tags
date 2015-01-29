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
#import "Tag.h"
#import "DBTagItem.h"

#import "DBItemManager.h"

#import "FileUtils.h"
#import "TimeUtils.h"
#import "MiscUtils.h"
#import "DropboxUploader.h"

static NSString *const kKeyAllTypItems = @"allTypItems";
static NSString *const kKeyAllTagItems = @"allTagItems";

@implementation TypManager
@end

// ================================================================
#pragma mark List of typs
// ================================================================

// so ideally this would be recursive and we'd deal with {strings, arrays, dicts}
// as {keys, array elements}, but not gonna code that unless I need it
NSArray* typItemsFromDict(NSDictionary* dict) {
	NSMutableArray* items = [NSMutableArray array];
	
	// the default typs are things we can record, so make them subtypes of datetime
	Typ* defaultParentTyp = [Typ typDatetimeRange];
	
	for (NSString* name in [dict allKeys]) {
		// create the Typs
		MutableTyp* parentTyp = [MutableTyp typWithName:name parents:@[defaultParentTyp]];
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
		// still be accessible as the parent's children
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

void saveTypItems(NSArray* items) {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults rm_setCustomObject:items forKey:kKeyAllTypItems];
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

// ================================================================
#pragma mark List of tags
// ================================================================

NSArray* defaultTagItems() {
	DBTagItem* item = createTagItemForTyp([Typ typDatetimeRange]);
	item.name = NSLocalizedString(@"Example Entry", 0);
	return @[item];
}
NSArray* getAllTagItems() {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSArray* typItems = [defaults rm_customObjectForKey:kKeyAllTagItems];
	if (! typItems) {
		typItems = defaultTagItems();
	}
	return typItems;
}
void saveTagItems(NSArray* items) {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults rm_setCustomObject:items forKey:kKeyAllTagItems];
	
	logTagItems(items);		//TODO maybe don't do this automatically here
}

// ================================================================
#pragma mark List of tags
// ================================================================

NSString* tagItemsToJSONString(NSArray* items) {
	NSMutableArray* tagVals = [NSMutableArray array];
	for (DBTagItem* item in items) {
		[tagVals addObject:[item.tag toDictOrValue]];
	}
	BOOL pretty = YES;
	return toJSONString(tagVals, pretty);
}

void logTagItems(NSArray* items) {
	NSString* jsonStr = tagItemsToJSONString(items);
	NSLog(@"saving items as JSON str: %@", jsonStr);
	NSString* baseFileName = @"tagItems";
	NSString* dateStr = currentTimeStrForFileName();
	NSString* fileName = [baseFileName stringByAppendingFormat:@"__%@.json", dateStr];
	NSString* dir = @"users";
	NSString* user = getUniqueDeviceIdentifierAsString();
	
	NSString* localPath = [FileUtils getFullFileName:fileName];
	NSString* destPath = [NSString pathWithComponents:@[dir, user, fileName]];
	NSLog(@"saving local file %@", localPath);
	NSLog(@"uploading file to %@", destPath);
	
	[FileUtils writeString:jsonStr toFile:localPath];
	[[DropboxUploader sharedUploader] addFileToUpload:localPath toPath:destPath];
}
