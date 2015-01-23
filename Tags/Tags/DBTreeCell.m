//
//  DBTreeCell.m
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTreeCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DBTreeCell ()

@property (weak, nonatomic) IBOutlet UITextField *titleText;

// TODO remove
//@property (weak, nonatomic) IBOutlet UIButton *additionButton;

@end

@implementation DBTreeCell

- (void)awakeFromNib {
	[super awakeFromNib];
    // Initialization code
	
	self.selectedBackgroundView = [UIView new];
	self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

//===============================================================
#pragma mark Custom stuff
//===============================================================

//+(NSString*) reuseIdentifier {
//	return NSStringFromClass([self class]);
//}

//- (void)layoutSubviews {
//	[super layoutSubviews];
//	
//	CGRect titleFrame = self.titleText.frame;
//	NSLog(@"titleFrame: %@", NSStringFromCGRect(titleFrame));
//	titleFrame.origin.x = 30;
//	titleFrame.size = [self.titleText sizeThatFits:titleFrame.size];
//	NSLog(@"titleFrame: %@", NSStringFromCGRect(titleFrame));
//	self.titleText.frame = titleFrame;
//	
////	self.selectedBackgroundView.frame = CGRectMake(10.0f, 0, 300, 80);
//	
//}

- (void)setupWithTitle:(NSString *)title
				 level:(NSInteger)level
		   numChildren:(NSUInteger)numChildren {
//	self.contentView.frame = self.bounds;	// sometimes magically fixes stuff
	
	self.titleText.text = title;
	if (numChildren) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		self.accessoryType = UITableViewCellAccessoryNone;
	}
	
	if (level == 0) {
		self.backgroundColor = UIColorFromRGB(0xF7F7F7);
	} else if (level == 1) {
		self.backgroundColor = UIColorFromRGB(0xD1EEFC);
	} else if (level >= 2) {
		self.backgroundColor = UIColorFromRGB(0xE0F8D8);
	}
	
//	id titl = self.titleText;
//	[self.titleText removeFromSuperview];
//	[self addSubview:titl];
//	
//	
	// NOTE: below only works if you disable autolayout in IB -> file tab
	CGFloat left = 11 + 20 * level;
	CGRect titleFrame = self.titleText.frame;
	titleFrame.origin.x = left;
	titleFrame.size = [self.titleText sizeThatFits:titleFrame.size];
	self.titleText.frame = titleFrame;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	[self.titleText endEditing:YES];
	//	[self.view endEditing:YES];		// no effect on cell text
	//	[self.treeView endEditing:YES]; // no effect on cell text
	//	[self.treeView setF]
//}

//===============================================================
#pragma mark UITextFieldDelegate
//===============================================================

// have "return" close the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	//TODO prolly send a notification here, or maybe in
	//shouldFinishEditing
	
	return NO;
}

@end
