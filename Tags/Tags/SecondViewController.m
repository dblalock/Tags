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

#import "FirstViewController.h"

//#import "DBTableItem.h"
#import "DBTagItem.h"
#import "DBTreeCell.h"
#import "DBCellManager.h"
#import "TypManager.h"
#import "Typ.h"
#import "Tag.h"

static NSString *const kCellNewButtonNibName = @"DBCellAddNew";
static NSString *const kCellNewButtonIdentifier = @"cellNewButton";

@interface SecondViewController () <SWTableViewCellDelegate>
@end

@implementation SecondViewController

-(void) viewDidLoad {
	[super viewDidLoad];
	
	NSLog(@"called secondVC viewDidLoad");
	// register all the nibs we might use
	NSDictionary* ids2nibs = reuseIdsToNibs();
	for (NSString* Id in [ids2nibs allKeys]) {
		NSLog(@"secondVC: actually registering a nib");
		[self.treeView registerNib:ids2nibs[Id] forCellReuseIdentifier:Id];
	}
	
	// TEST: now that these are in the manager dict, will it work?
		// apparently not...
		// ah, that makes sense because this is using [DBTagItem reuseIdentifier], which is != [DBTableItem reuseIdenitfier]
			// the question is why this identifier is needed...
//	[self.treeView registerNib:[DBTreeCell standardNib] forCellReuseIdentifier:[DBTagItem reuseIdentifier]];		// tagItem

//	self.data = [getAllTagItems() mutableCopy];
	self.data = [defaultTagItems() mutableCopy];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(notifiedTypSelected:)
												 name: kNotificationTypSelected
											   object:nil];
}

-(void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

// ================================================================
#pragma mark TreeView Data Source methods
// ================================================================

-(UITableViewCell*) treeView:(RATreeView *)treeView cellForItem:(id)item {
	DBTreeCell* cell = dequeCellForTreeViewItem(treeView, item);

	// rest is just adding utility buttons
	if (! cell.wantsUtilityButtons) return cell;

//	NSMutableArray *leftUtilityButtons = [NSMutableArray new];
	NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//
//	[leftUtilityButtons sw_addUtilityButtonWithColor:
//	 [UIColor colorWithRed:0.1f green:0.0f blue:1.0f alpha:0.7]
//											   title:@"Edit"];
//
	[rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor]
												title:@"Duplicate"];
	[rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor]
												title:@"Delete"];
//
//	cell.leftUtilityButtons = leftUtilityButtons;
	cell.rightUtilityButtons = rightUtilityButtons;
	cell.delegate = self;
//	cell.treeDelegate = self;

	return cell;
}

// ================================================================
#pragma mark SWTableViewCellDelegate
// ================================================================

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
	switch (index) {
		case 0:		// Duplicate Button
		{
			// TODO ideally deep copy with original tags values
			DBTagItem* item = [self.treeView itemForCell:cell];
			DBTagItem* dup = [[DBTagItem alloc] initWithTyp:item.tag.typ];
			[self.data addObject:dup];
			[self.treeView reloadData];
			[self.treeView scrollToRowForItem:dup
						 atScrollPosition:RATreeViewScrollPositionBottom animated:NO];
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
#pragma mark DBTreeCell Delegate
// ================================================================

//-(void) treeCell:(DBTreeCell *)cell didSetNameTo:(NSString *)name {
//	DBTableItem* item = [self.treeView itemForCell:cell];
//	item.name = name;
//}

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
#pragma mark Item manipulation
// ================================================================

-(void) saveItems {
	saveTagItems(self.data);
}

-(void)notifiedTypSelected:(NSNotification*)notification {
	if (! self.presentedViewController) return;		//TODO slightly more robust check
	[self dismissViewControllerAnimated:YES completion:nil];
	Typ* typ = extractTypFromNotification(notification);
	[self addItemOfTyp:typ];
}

-(void) addItemOfTyp:(Typ*)typ {
	if (! typ) return;
	DBTagItem *item = [[DBTagItem alloc] initWithTyp:typ];
	[self.data addObject:item];
	[self.treeView reloadData];
	
	[self.treeView scrollToRowForItem:item
				 atScrollPosition:RATreeViewScrollPositionBottom animated:NO];
	
	[self saveItems];
}

-(void) selectAndAddTag {
	// to get this working, have to add the file's owner's "view"
	// outlet as a referencing outlet and set the file's owner
	// to be a member of this viewcontroller class; see:
	// http://stackoverflow.com/a/6395750/1153180
	UIViewController* cntrl = [[FirstViewController alloc] initWithNibName:@"EmptyView" bundle:nil];
	[self presentViewController:cntrl animated:YES completion:nil];
}

-(void) addRootItem {
	[self selectAndAddTag];
}

-(void) deleteItem:(DBTableItem*)item {
	DBTagItem *parent = [self.treeView parentForItem:item];
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
