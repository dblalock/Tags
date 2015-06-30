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
static NSString *const kTimeChanged = @"TimeUpdated";
@interface DBTimeCell ()
@property(weak, nonatomic) IBOutlet UIDatePicker* datePicker;
@end


@implementation DBTimeCell

-(void) setupWithItem:(DBTableItem*)item atLevel:(NSUInteger)lvl expanded:(BOOL)expanded {
	[super setupWithItem:item atLevel:lvl expanded:expanded];
	assert([self.tagObj.typ isKindOfTyp:[Typ typDatetime]]);
    _identifier = [NSString stringWithFormat:@"%u", arc4random_uniform(1000000)];
    self.tagObj.identifier = _identifier;
	id date = self.tagObj.value;
	if (date == [[Typ typDatetime] defaultValue] || ![date isKindOfClass:[NSDate class]]) {
		date = [NSDate date];
		self.tagObj.value = date;
	}
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTime:) name:_identifier object:nil];
	[self.datePicker setDate:date animated:NO];
}
-(void) changeTime:(NSNotification *)notification{
    id newTime = notification.userInfo[@"time"];
    if([newTime isKindOfClass:[NSDate class]]){
        [self.datePicker setDate:newTime animated:NO];
    }
}
-(IBAction) dateTimeUpdated:(id)sender {
	if (! [sender isKindOfClass:[UIDatePicker class]]) return;
	self.tagObj.value = [(UIDatePicker*)sender date];
	[self.tagItm notifyChildChanged:self.tagObj];
}

//-(NSUInteger) preferredRowHeight {
//	return 50;
//}

@end
