//
//  DBTimeCell.m
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTimeCell.h"

#import "Tag.h"
#import "Typ.h"
#import "DBTagItem.h"

@interface DBTimeCell ()
@property(weak, nonatomic) IBOutlet UIDatePicker* datePicker;
@end


@implementation DBTimeCell

-(void) setupWithItem:(DBTableItem*)item atLevel:(NSUInteger)lvl expanded:(BOOL)expanded {
	[super setupWithItem:item atLevel:lvl expanded:expanded];
	assert([self.tagObj.typ isKindOfTyp:[Typ typDatetime]]);
	id date = self.tagObj.value;
	if (date == [[Typ typDatetime] defaultValue] || ![date isKindOfClass:[NSDate class]]) {
		date = [NSDate date];
		self.tagObj.value = date;
	}
	[self.datePicker setDate:date animated:NO];
}

-(IBAction) dateTimeUpdated:(id)sender {
	if (! [sender isKindOfClass:[UIDatePicker class]]) return;
	self.tagObj.value = [(UIDatePicker*)sender date];
	[self.tagItm notifyChildChanged:self.tagObj];
}

@end
