//
//  DBTimeRangeCell.m
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTimeRangeCell.h"

@interface DBTimeRangeCell ()
@property(weak, nonatomic) IBOutlet UILabel* durationLbl;
@property(weak, nonatomic) IBOutlet UISwitch* recordingBtn;
@end

@implementation DBTimeRangeCell

-(void) setupWithItem:(DBTableItem*)item atLevel:(NSUInteger)lvl expanded:(BOOL)expanded {
	[super setupWithItem:item atLevel:lvl expanded:expanded];

	// messes with ability to flip recording switch, and also looks worse
	self.accessoryType = UITableViewCellAccessoryNone;
	
	// ugh; so we somehow have to make it start/stop recording and update the
	// elapsed time once/minute; this is hard because this same instance will
	// get used for a whole bunch of different items, so really all the state
	// needs to live in the item; however, the item doesn't know anything
	// about different types of cells (or even any particular typs, aside from
	// its own...)
	
}

@end
