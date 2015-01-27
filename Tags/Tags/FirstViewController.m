//
//  FirstViewController.m
//  Tags
//
//  Created by DB on 1/21/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "FirstViewController.h"

#import <RATreeView.h>
#import <SWTableViewCell.h>

#import "DBTableItem.h"
#import "DBTypItem.h"
#import "DBTreeCell.h"
#import "TypManager.h"

static NSString *const kDefaultChildName = @"";
static const int kActionSheetTagDelete = 1;

@interface FirstViewController () <SWTableViewCellDelegate, UIActionSheetDelegate, DBTreeCellDelegate>

@end

@implementation FirstViewController

CGRect fullScreenFrame() {
	return CGRectMake(0, 0,
					  [[UIScreen mainScreen] applicationFrame].size.width,
					  [[UIScreen mainScreen] applicationFrame].size.height);
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// this just adds a background behind the status bar, because the treeview
	// hasn't been resized to start below it yet; it seems to stick around even
	// after the treeview is resized
//	[_treeView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:.6]];

	[self.treeView registerNib:[DBTreeCell standardNib] forCellReuseIdentifier:[DBTypItem reuseIdentifier]];		// typItem

	self.data = [getAllTypItems() mutableCopy];
	[self.treeView reloadData];
}

- (void)didReceiveMemoryWarning {
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

// ================================================================
#pragma mark SWTableViewCellDelegate
// ================================================================

-(void) clickedEditCell:(DBTreeCell*)cell {
	NSLog(@"clickedEditCell");
	[self stopEditingCell];		// if currently editing one, stop
	self.cellInQuestion = cell;
	[(DBTreeCell*)cell startEditingName];
}

-(void) clickedAddChildToCell:(UITableViewCell*)cell {
	[self addChildTo:[self.treeView itemForCell:cell]];
}

-(void) clickedDeleteCell:(DBTreeCell*)cell {
	UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Permanently delete tag?" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete", nil];
	sheet.tag = kActionSheetTagDelete;
	sheet.delegate = self;
	self.cellInQuestion = cell;
	[sheet showInView:self.view];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
	switch (index) {
		case 0:			// edit button
		{
			[self clickedEditCell:(DBTreeCell*)cell];
		}
		default:
			break;
	}
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
	switch (index) {
		case 0:		// Sub-Tag Button
		{
			[self clickedAddChildToCell:cell];
			break;
		}
		case 1:		// Delete button
		{
			[self clickedDeleteCell:(DBTreeCell*)cell];
			break;
		}
		default:
			break;
	}
}

// ================================================================
#pragma mark UIActionSheetDelegate
// ================================================================

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (actionSheet.tag) {
		case kActionSheetTagDelete:
			if (self.cellInQuestion && buttonIndex == 0) {	// cancel = 1, do it = 0
				[self deleteItem:[self.treeView itemForCell:self.cellInQuestion]];
			} else {
				[(DBTreeCell*)self.cellInQuestion hideUtilityButtonsAnimated:YES];
			}
			self.cellInQuestion = nil;
			break;
		default:
			break;
	}
}

// ================================================================
#pragma mark DBTreeCell Delegate
// ================================================================

-(void) treeCell:(DBTreeCell *)cell didSetNameTo:(NSString *)name {
	DBTableItem* item = [self.treeView itemForCell:cell];
	item.name = name;
}

// ================================================================
#pragma mark Helper Funcs
// ================================================================

-(void) editNameForItem:(id)item {
	DBTreeCell* cell = (DBTreeCell*)[self.treeView cellForItem:item];
	self.cellInQuestion = cell;
	[cell startEditingNameWithSelectAll:YES];
}

-(void) addRootItem {
	DBTableItem *newChild = [[DBTableItem alloc] initWithName:kDefaultChildName children:nil];
	NSLog(@"data: %@", self.data);
	[self.data addObject:newChild];
	[self.treeView reloadData];

	[self editNameForItem:newChild];
	saveTypItems(self.data);
}

-(void) addChildTo:(DBTableItem*)parent {
	// This seems to look slightly better than no animation when
	// there are a lot of children already
	[self.treeView expandRowForItem:parent withRowAnimation:RATreeViewRowAnimationMiddle];

	// TODO this class probably shouldn't know about DBTypItem
	DBTypItem *newChild = [[DBTypItem alloc] initWithName:kDefaultChildName parent:parent];
	[self.treeView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0] inParent:parent withAnimation:RATreeViewRowAnimationLeft];
	[self.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];

	// assume user doesn't want to keep the name "New Tag"
	[self editNameForItem:newChild];
	saveTypItems(self.data);
}

-(void) deleteItem:(DBTableItem*)item {
	DBTableItem *parent = [self.treeView parentForItem:item];
	NSInteger index = 0;

	if (parent == nil) {
		index = [self.data indexOfObject:item];
		[self.data removeObjectAtIndex:index];
	} else {
		index = [parent.children indexOfObject:item];
		[parent removeChild:item];
	}

	[self.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parent withAnimation:RATreeViewRowAnimationRight];
	if (parent) {
		[self.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];
	}

	saveTypItems(self.data);
}

@end
