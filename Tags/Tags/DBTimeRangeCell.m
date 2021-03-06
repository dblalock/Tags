//
//  DBTimeRangeCell.m
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTimeRangeCell.h"

#import "DBTimeRangeItem.h"

@interface DBTimeRangeCell ()
@property(weak, nonatomic) IBOutlet UILabel* durationLbl;
@property(weak, nonatomic) IBOutlet UISwitch* recordingSwitch;
@property(weak, nonatomic) DBTimeRangeItem* itm;
@end

@implementation DBTimeRangeCell

-(void) setupWithItem:(DBTableItem*)item atLevel:(NSUInteger)lvl expanded:(BOOL)expanded {
	[super setupWithItem:item atLevel:lvl expanded:expanded];
	assert([item isKindOfClass:[DBTimeRangeItem class]]);
	self.itm = (DBTimeRangeItem*)item;

	// messes with ability to flip recording switch, and also looks worse
	self.accessoryType = UITableViewCellAccessoryNone;
	
	self.durationLbl.text = formatDuration([self.itm duration]);
	
	// ugh; so we somehow have to make it start/stop recording and update the
	// elapsed time once/minute; this is hard because this same instance will
	// get used for a whole bunch of different items, so really all the state
	// needs to live in the item; however, the item doesn't know anything
	// about different types of cells (or even any particular typs, aside from
	// its own...)
		//EDIT: nevermind--now we have our very own TableItem subclass that
		//knows things. Hooray!
	
	if ([self.itm inToday]) {
		self.recordingSwitch.hidden = NO;
		[self.recordingSwitch setOn:self.itm.recording animated:NO];
	} else {
		self.recordingSwitch.hidden = YES;
	}
}

-(IBAction) switchChanged:(id)sender {
	assert([sender isKindOfClass:[UISwitch class]]);
	UISwitch* swit = (UISwitch*)sender;
	self.itm.recording = [swit isOn];
}


NSString* formatDuration(NSDateComponents* components) {
	return [NSString stringWithFormat:@"%2d:%02d", (int)components.hour, (int) components.minute];
//	return [NSString stringWithFormat:@"%2ld:%02ld:%02ld",
//			(long)components.hour, (long)components.minute, (long)components.second];
}

@end
