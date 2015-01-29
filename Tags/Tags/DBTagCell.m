//
//  DBTagCell.m
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTagCell.h"

#import "Tag.h"
#import "DBTagItem.h"	// TODO would be better to just need something that conforms to a protocol

@implementation DBTagCell


BOOL itemHasTag(DBTableItem* item) {
//	return [item respondsToSelector:@selector(tag)];
//	return [item respondsToSelector:@selector(tag)] && [[item tag] isKindOfClass:[Tag class]];
	return [item isKindOfClass:[DBTagItem class]];
}

-(void) setupWithItem:(DBTableItem*)item atLevel:(NSUInteger)lvl expanded:(BOOL)expanded {
	[super setupWithItem:item atLevel:lvl expanded:expanded];
	NSAssert(itemHasTag(item), @"DBTagCell: setupWithItem: item must have a Tag");
	self.tagObj = ((DBTagItem*)item).tag;
}

-(BOOL) wantsUtilityButtons {
	return self.treeLvl == 0;	// TODO treeview delegate should prolly know this rule, not the cell
}

@end
