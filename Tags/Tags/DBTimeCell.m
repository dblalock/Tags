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

@interface DBTimeCell ()
@property(weak, nonatomic) IBOutlet UIDatePicker* datePicker;
@end


@implementation DBTimeCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) setupWithItem:(DBTableItem*)item atLevel:(NSUInteger)lvl expanded:(BOOL)expanded {
	[super setupWithItem:item atLevel:lvl expanded:expanded];
	assert([self.tagObj.typ isKindOfTyp:[Typ typDatetime]]);
	id date = self.tagObj.value;
//	NSLog(@"TimeCell::setupWithItem: date = %@", date);
	if (date == [[Typ typDatetime] defaultValue] || ![date isKindOfClass:[NSDate class]]) {
		date = [NSDate date];
		self.tagObj.value = date;
	}
//	assert([date isKindOfClass:[NSDate class]]);
	[self.datePicker setDate:date animated:NO];
}

-(IBAction)dateTimeUpdated:(id)sender {
	if (! [sender isKindOfClass:[UIDatePicker class]]) return;
	self.tagObj.value = [(UIDatePicker*)sender date];
}

//-(NSUInteger) preferredRowHeight {	//actually, skinny is good
//	return 180;
//}

@end
