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
//#import "DBTypItem.h"
#import "DBTreeItemAddNew.h"
#import "DBTreeCell.h"
#import "TypManager.h"

static NSString *const kCellNewButtonNibName = @"DBCellAddNew";
static NSString *const kCellNewButtonIdentifier = @"cellNewButton";

@interface SecondViewController () <RATreeViewDataSource, SWTableViewCellDelegate, DBTreeCellDelegate>
@end


@implementation SecondViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.treeView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// ================================================================
#pragma mark TreeView Data Source methods
// ================================================================

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
	DBTableItem *tableItem = item;
	NSInteger lvl = [self.treeView levelForCellForItem:item];
	//	NSInteger numberOfChildren = [dataObject.children count];
	BOOL expanded = [self.treeView isCellForItemExpanded:item];
	
	DBTreeCell* cell = [treeView dequeueReusableCellWithIdentifier:[item reuseIdentifier]];
	
	[cell setupWithItem:tableItem atLevel:lvl expanded:expanded];
	//	[cell setupWithTitle:tableItem.name level:lvl numChildren:[tableItem.children count]];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	// rest is just adding utility buttons
	if (! cell.wantsUtilityButtons) {
		return cell;
	}
	
	// SWTableViewCell wonderfulness
	// from: www.appcoda.com/swipeable-uitableviewcell-tutorial/
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

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
	if (item == nil) {
		//		return [self.data count];
		return [self.data count] + 1;	// extra row for "add new"
	}
	
	DBTableItem *data = item;
	return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
	DBTableItem *data = item;
	if (item == nil) {
		if (index < [self.data count]) {
			return [self.data objectAtIndex:index];
		}
		return [DBTreeItemAddNew item];
	}
	return data.children[index];
}

// ================================================================
#pragma mark SWTableViewCellDelegate
// ================================================================



@end
