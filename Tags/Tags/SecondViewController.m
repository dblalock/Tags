//
//  SecondViewController.m
//  Tags
//
//  Created by DB on 1/21/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "SecondViewController.h"

#import <RATreeView.h>
#import <SWTableViewCell.h>

#import "DBTableItem.h"
#import "DBTreeCell.h"
#import "TypManager.h"

static NSString *const kCellNewButtonNibName = @"DBCellAddNew";
static NSString *const kCellNewButtonIdentifier = @"cellNewButton";

@interface SecondViewController () <RATreeViewDataSource, SWTableViewCellDelegate, DBTreeCellDelegate>
@end


@implementation SecondViewController

-(void) viewDidLoad {
	[super viewDidLoad];

//	self.data = [getAllTypItems() mutableCopy];
//	[self.treeView reloadData];
}

-(void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// ================================================================
#pragma mark TreeView Data Source methods
// ================================================================

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
	DBTreeCell* cell = dequeCellForTreeViewItem(treeView, item);

	// rest is just adding utility buttons
	if (! cell.wantsUtilityButtons) return cell;

	NSMutableArray *leftUtilityButtons = [NSMutableArray new];
	NSMutableArray *rightUtilityButtons = [NSMutableArray new];

	[leftUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:0.1f green:0.0f blue:1.0f alpha:0.7]
											   title:@"Edit"];

	[rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor]
												title:@"New"];
	[rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor]
												title:@"Delete"];

	cell.leftUtilityButtons = leftUtilityButtons;
	cell.rightUtilityButtons = rightUtilityButtons;
	cell.delegate = self;
	cell.treeDelegate = self;

	return cell;
}

// ================================================================
#pragma mark SWTableViewCellDelegate
// ================================================================

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {}


@end
