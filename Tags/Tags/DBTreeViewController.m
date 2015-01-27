//
//  DBTreeViewController.m
//  Tags
//
//  Created by DB on 1/26/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTreeViewController.h"

#import <RATreeView.h>

@interface DBTreeViewController ()
@end

@implementation DBTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// we create a temporary treeview object so that we don't assign
	// directly to a weak property until it's been retained by self.view...I think
	RATreeView* treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
	[self.view insertSubview:treeView atIndex:0];
	self.treeView = treeView;
	
	self.treeView.delegate = self;
	self.treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLineEtched;
	self.treeView.allowsSelection = NO;		// will only get every other collapse cmd otherwise
	
	// dealing with keyboard covering crap
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardWillShow:)
												 name: UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardWillDisappear:)
												 name: UIKeyboardWillHideNotification object:nil];
}

// this just makes it not be behind the status bar + tab bar
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
	float statusBarHeight = statusBarViewRect.size.height;
	float tabBarHeight = self.tabBarController.tabBar.frame.size.height;
	CGRect viewBounds = self.view.bounds;
	viewBounds.origin.y = statusBarHeight;
	viewBounds.size.height -= tabBarHeight + statusBarHeight;
	self.treeView.frame = viewBounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIKeyboardWillShowNotification object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIKeyboardWillHideNotification object: nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// ================================================================
#pragma mark Keyboard not covering tableview
// ================================================================

// -------------------------------- Helpers

NSTimeInterval keyboardAnimationDuration(NSNotification* notification) {
	NSDictionary* info = [notification userInfo];
	NSValue* value = [info objectForKey: UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval duration = 0;
	[value getValue: &duration];
	return duration;
}

CGSize keyboardSize(NSNotification* notification) {
	return [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
}

// -------------------------------- Notification callbacks

- (void) keyboardWillShow:(NSNotification*)aNotification {
	CGSize kbSize = keyboardSize(aNotification);
	id item = [_treeView itemForCell:_cellInQuestion];
	
	CGRect treeFrame = _treeView.frame;
	treeFrame.size.height -= kbSize.height - self.tabBarController.tabBar.frame.size.height;
	[_treeView setFrame:treeFrame];
	[_treeView scrollToRowForItem:item
				 atScrollPosition:RATreeViewScrollPositionBottom animated:NO];
}

- (void) keyboardWillDisappear:(NSNotification*)aNotification {
	NSTimeInterval duration = keyboardAnimationDuration(aNotification);
	CGSize kbSize = keyboardSize(aNotification);	// 320 x 216
	[UIView animateWithDuration:duration animations:^{
		CGRect treeFrame = _treeView.frame;
		treeFrame.size.height += kbSize.height - self.tabBarController.tabBar.frame.size.height;
		[_treeView setFrame:treeFrame];
	} completion:^(BOOL finished) {
	}];
}

@end
