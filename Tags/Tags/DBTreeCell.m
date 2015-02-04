//
//  DBTreeCell.m
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTreeCell.h"

static const NSUInteger kPreferredRowHeight = 44;
//static const float kLongPressSecs = 2.0;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DBTreeCell () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UIButton *mainButton;
@end

@implementation DBTreeCell

- (void)awakeFromNib {
	[super awakeFromNib];
    // Initialization code
	
	self.titleText.delegate = self;
	self.selectedBackgroundView = [UIView new];
	self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
	self.titleText.autocapitalizationType = UITextAutocapitalizationTypeSentences;	// init cap
	self.titleText.clearButtonMode = UITextFieldViewModeNever;	// no x button on right side
	
	// this never actually gets events, apparently
//	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
//										  initWithTarget:self action:@selector(handleLongPress:)];
//	lpgr.minimumPressDuration = kLongPressSecs;
//	lpgr.delegate = self;
//	[self addGestureRecognizer:lpgr];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
//}

-(void) layoutSubviews {
	[super layoutSubviews];
	// ensure the gradient layers occupies the full bounds
	if (! _gradientLayer) return;
	_gradientLayer.frame = self.bounds;
//	self.backgroundColor = [UIColor clearColor];
//	self.backgroundView = nil;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.gradientLayer = [self createGradientLayer];
	}
	return self;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.gradientLayer = [self createGradientLayer];
	}
	return self;
}

-(CAGradientLayer*) createGradientLayer {
	// add a layer that overlays the cell adding a subtle gradient effect
//	CAGradientLayer* gradientLayer = [CAGradientLayer layer];
//	gradientLayer.frame = self.bounds;
//	gradientLayer.colors = @[(id)[[UIColor colorWithWhite:1.0f alpha:0.9f] CGColor],
//							  (id)[[UIColor colorWithWhite:1.0f alpha:0.95f] CGColor],
////							  (id)[[UIColor clearColor] CGColor],
//							  (id)[[UIColor whiteColor] CGColor],
//							  (id)[[UIColor colorWithWhite:0.0f alpha:0.9f] CGColor]];
//	gradientLayer.locations = @[@0.00f, @0.01f, @0.95f, @1.00f];
//	return gradientLayer;
	return nil;
}

-(void) setGradientLayer:(CAGradientLayer*)gradientLayer {
	if (_gradientLayer) {
		[_gradientLayer removeFromSuperlayer];
	}
	_gradientLayer = gradientLayer;
	[self.layer insertSublayer:_gradientLayer atIndex:0];
}

//===============================================================
#pragma mark IBActions
//===============================================================

-(IBAction)tappedMainButton:(id)sender {
	if ([_treeDelegate respondsToSelector:@selector(treeCelldidTapMainButton:)]) {
		[_treeDelegate treeCelldidTapMainButton:self];
	}
}

//===============================================================
#pragma mark Custom stuff
//===============================================================

+(UINib*) standardNib {
	return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

void shrinkTextFieldToFit(UITextField* field) {
	CGRect titleFrame = field.frame;
	titleFrame.size = [field sizeThatFits:titleFrame.size];
	field.frame = titleFrame;
}

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

-(void) setupWithItem:(DBTableItem*)item atLevel:(NSUInteger)lvl expanded:(BOOL)expanded {
	self.treeLvl = lvl;
	[self setupWithTitle:item.name level:lvl numChildren:item.children.count];
}

-(void) startEditingNameWithSelectAll:(BOOL)selectAll {
	if (_titleText.enabled) return;	//already editing
	_titleText.enabled = YES;
	
	CGRect titleFrame = self.titleText.frame;
	titleFrame.size.width += 100;		// TODO prolly let subclasses override
	self.titleText.frame = titleFrame;
	
	[_titleText becomeFirstResponder];
	if (selectAll) {
		[_titleText setSelectedTextRange:
		 [_titleText textRangeFromPosition:_titleText.beginningOfDocument
								toPosition:_titleText.endOfDocument]];
	}
	[self hideUtilityButtonsAnimated:YES];
}
-(void) startEditingName {
	[self startEditingNameWithSelectAll:NO];
}


-(void) startEditing {
	[self startEditingName];
}

-(void) stopEditing {
	[self stopEditingName];
}

-(void) stopEditingName {
	[_titleText resignFirstResponder];
	_titleText.enabled = NO;
	shrinkTextFieldToFit(self.titleText);
}

-(BOOL) wantsUtilityButtons {
	return YES;
}
-(NSUInteger) preferredRowHeight {
	return kPreferredRowHeight;
}

//-(void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
//	NSLog(@"tree cell got long press");
//	// only fire when long press first detected
//	if (gestureRecognizer.state != UIGestureRecognizerStateBegan) return;
//	[self startEditingName];
//}

//-(BOOL) requiresSetup {
//	return YES;
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	[self stopEditingName];
//	[self.titleText endEditing:YES];
//		[self.view endEditing:YES];		// no effect on cell text
//		[self.treeView endEditing:YES]; // no effect on cell text
//		[self.treeView setF]
//}

//===============================================================
#pragma mark UITextFieldDelegate
//===============================================================

// have "return" close the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	[textField resignFirstResponder];
	[self stopEditingName];
	return NO;
}

// if the user changed our name, tell the delegate
-(void) textFieldDidEndEditing:(UITextField *)textField {
	if ([_treeDelegate respondsToSelector:@selector(treeCell:didSetNameTo:)]) {
		[_treeDelegate treeCell:self didSetNameTo:textField.text];
	}
}

@end
