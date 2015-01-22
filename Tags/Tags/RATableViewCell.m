
//The MIT License (MIT)
//
//Copyright (c) 2014 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RATableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface RATableViewCell () <UITextFieldDelegate>

//@property (weak, nonatomic) IBOutlet UILabel *detailedLabel;
//@property (weak, nonatomic) IBOutlet UILabel *customTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *additionButton;

@property (weak, nonatomic) IBOutlet UITextField *titleText;

@end

@implementation RATableViewCell

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  self.selectedBackgroundView = [UIView new];
  self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
  
}

- (void)prepareForReuse
{
  [super prepareForReuse];
  
  self.additionButtonHidden = NO;
}


- (void)setupWithTitle:(NSString *)title detailText:(NSString *)detailText level:(NSInteger)level additionButtonHidden:(BOOL)additionButtonHidden
{
//  self.customTitleLabel.text = title;
//  self.detailedLabel.text = detailText;
	self.titleText.text = title;
  self.additionButtonHidden = additionButtonHidden;
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
//  if (level == 0) {
//    self.detailTextLabel.textColor = [UIColor blackColor];
//  }
	
  if (level == 0) {
    self.backgroundColor = UIColorFromRGB(0xF7F7F7);
  } else if (level == 1) {
    self.backgroundColor = UIColorFromRGB(0xD1EEFC);
  } else if (level >= 2) {
    self.backgroundColor = UIColorFromRGB(0xE0F8D8);
  }
  
	CGFloat left = 11 + 20 * level;

	CGRect titleFrame = self.titleText.frame;
	titleFrame.origin.x = left;
	self.titleText.frame = titleFrame;
	
	[self.titleText sizeToFit];
	
//  CGRect titleFrame = self.customTitleLabel.frame;
//  titleFrame.origin.x = left;
//  self.customTitleLabel.frame = titleFrame;
	
//  CGRect detailsFrame = self.detailedLabel.frame;
//  detailsFrame.origin.x = left;
//  self.detailedLabel.frame = detailsFrame;
}


#pragma mark - Properties

- (void)setAdditionButtonHidden:(BOOL)additionButtonHidden
{
  [self setAdditionButtonHidden:additionButtonHidden animated:NO];
}

- (void)setAdditionButtonHidden:(BOOL)additionButtonHidden animated:(BOOL)animated
{
  _additionButtonHidden = additionButtonHidden;
  [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
    self.additionButton.hidden = additionButtonHidden;
  }];
}


#pragma mark - Actions

- (IBAction)additionButtonTapped:(id)sender
{
  if (self.additionButtonTapAction) {
    self.additionButtonTapAction(sender);
  }
}

//===============================================================
#pragma mark UITextFieldDelegate
//===============================================================

// have "return" close the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

@end
