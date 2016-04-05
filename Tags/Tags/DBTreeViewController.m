//
//  DBTreeViewController.m
//  Tags
//
//  Created by DB on 1/26/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTreeViewController.h"

#import "RATreeView.h"

#import "DBCellManager.h"
#import "DBTreeCell.h"
#import "DBTreeCellAddNew.h"
#import "DBTableItem.h"
#import "DBTreeItemAddNew.h"

@interface DBTreeViewController ()
@end

@implementation DBTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
//	self.edgesForExtendedLayout = UIRe;

	// we create a temporary treeview object so that we don't assign
	// directly to a weak property until it's been retained by self.view...I think
	RATreeView* treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
//	[self.view insertSubview:treeView atIndex:0];
	[self.view addSubview:treeView];
	self.treeView = treeView;

	self.treeView.delegate = self;
	self.treeView.dataSource = self;
	self.treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLineEtched;
	self.treeView.allowsSelection = NO;		// will only get every other collapse cmd otherwise

	// register all the nibs we might use
	NSDictionary* ids2nibs = reuseIdsToNibs();
	for (NSString* Id in [ids2nibs allKeys]) {
		[self.treeView registerNib:ids2nibs[Id] forCellReuseIdentifier:Id];
	}
	
	// my tableviewcell nib
//	[self.treeView registerNib:[DBTreeCell standardNib] forCellReuseIdentifier:[DBTableItem reuseIdentifier]];	// tableItem
//	[self.treeView registerNib:[DBTreeCellAddNew standardNib] forCellReuseIdentifier:[DBTreeItemAddNew reuseIdentifier]];// add new button

	// dealing with keyboard covering crap
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardWillShow:)
												 name: UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardWillDisappear:)
												 name: UIKeyboardWillHideNotification object:nil];
}

// this just makes it not be behind the status bar + tab bar
//EDIT: whatever I put here only makes things worse...
//- (void)viewWillAppear:(BOOL)animated {
//	[super viewWillAppear:animated];
//	self.treeView.bounds = self.view.bounds;	// makes everything magically work
		//except that it still scrolls under the status bar, dangit
	
//	CGRect bounds = self.treeView.frame;
//	if (bounds.origin.y == 0) {
//		CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
//		float statusBarHeight = statusBarViewRect.size.height;
//		bounds.origin.y = statusBarHeight;
//		bounds.size.height -= statusBarHeight;
//	}
//	self.treeView.frame = bounds;
	
//	NSLog(@"treeview frame: %@", NSStringFromCGRect(self.treeView.frame));
//}
//
//	// both of these are just 0...
////	NSLog(@"top layout guide height: %g", self.topLayoutGuide.length);
////	NSLog(@"btm layout guide height: %g", self.bottomLayoutGuide.length);
//	
//	CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
//	float statusBarHeight = statusBarViewRect.size.height;
//	float tabBarHeight = self.tabBarController.tabBar.frame.size.height;
////	NSLog(@"tabBarHeight = %g", tabBarHeight);
//	CGRect viewBounds = self.view.bounds;
//	if ([self.navigationController isNavigationBarHidden]) {
//		viewBounds.origin.y += statusBarHeight;
//		viewBounds.size.height -= tabBarHeight + statusBarHeight;
//	} else {
//		viewBounds.size.height -= tabBarHeight;
//	}
//	self.treeView.frame = viewBounds;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) unsubNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIKeyboardWillShowNotification
												  object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIKeyboardWillHideNotification
												  object: nil];
}

-(void) viewWillDisappear:(BOOL)animated {
	[self unsubNotifications];
}

-(void) dealloc {
	[self unsubNotifications];
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
#pragma mark Accessors
// ================================================================

-(void) setData:(NSMutableArray*)data {
	_data = data;
	[_treeView reloadData];
}

// ================================================================
#pragma mark Other public methods
// ================================================================

-(void) addRootItem {
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

// returns yes if it stopped something, and no if it wasn't editing anyway;
// this is just a hack to close keyboard on touch outside
-(BOOL) stopEditingCell {
	if (self.cellInQuestion) {
		[(DBTreeCell*)self.cellInQuestion stopEditing];
		self.cellInQuestion = nil;
		return YES;
	}
	return NO;
}

DBTreeCell* dequeCellForTreeViewItem(RATreeView* treeView, id item) {
	DBTableItem *tableItem = item;
	NSInteger lvl = [treeView levelForCellForItem:item];
	BOOL expanded = [treeView isCellForItemExpanded:item];

//	NSLog(@"dequing cell for item of class %@ with identifier: %@", [item class], [item reuseIdentifier]);
	DBTreeCell* cell = [treeView dequeueReusableCellWithIdentifier:[item reuseIdentifier]];

	[cell setupWithItem:tableItem atLevel:lvl expanded:expanded];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}

// ================================================================
#pragma mark RATreeViewDelegate
// ================================================================

//------------------------------------------------
// row attributes
//------------------------------------------------

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
	DBTreeCell* cell = (DBTreeCell*)[treeView cellForItem:item];
	return cell.preferredRowHeight ? cell.preferredRowHeight : 44;
}

//------------------------------------------------
// expanding/collapsing rows
//------------------------------------------------

//------------------------ should

// these two methods are basically a hack to get it to close the keyboard
// when you click outside of the text view
-(BOOL)treeView:(RATreeView *)treeView shouldCollapaseRowForItem:(id)item {
//	NSLog(@"shouldCollapseRow");
	//	return YES;
	return ! [self stopEditingCell];
}
-(BOOL)treeView:(RATreeView *)treeView shouldExpandRowForItem:(id)item {
//	NSLog(@"shouldExpandRow");
	//	return YES;
	return ! [self stopEditingCell];
}

//------------------------ will

// call our method to add a new item at the root level
- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
//	NSLog(@"willExpandRow");
	if ([item isKindOfClass:[DBTreeItemAddNew class]]) {
		[self addRootItem];
	}
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
//	NSLog(@"willCollapseRow");
	DBTreeCell* cell = (DBTreeCell*) [treeView cellForItem:item];
	[cell stopEditing];
}

//------------------------------------------------
// tree / cell modification
//------------------------------------------------

-(BOOL) treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
	return NO;
}

// ================================================================
#pragma mark RATreeViewDatasource
// ================================================================

-(UITableViewCell*) treeView:(RATreeView *)treeView cellForItem:(id)item {
	return dequeCellForTreeViewItem(treeView, item);
}

-(NSInteger) treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
	if (item == nil) {
		return [self.data count] + 1;	// extra row for "add new"
	}

	DBTableItem *data = item;
	return [data.children count];
}

-(id) treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
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
#pragma mark Keyboard not covering tableview
// ================================================================

// ------------------------ Helpers

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

// ------------------------ Notification callbacks

- (void) keyboardWillShow:(NSNotification*)aNotification {
	CGSize kbSize = keyboardSize(aNotification);
	id item = [_treeView itemForCell:_cellInQuestion];

	CGRect treeFrame = _treeView.frame;
	treeFrame.size.height -= kbSize.height;
//	treeFrame.size.height -= self.tabBarController.tabBar.frame.size.height;

//	NSLog(@"kb hidden treeView origin.y, end.y = %g, %g", treeFrame.origin.y, treeFrame.size.height + treeFrame.origin.y);
	[_treeView setFrame:treeFrame];
//	NSLog(@"keyboard height = %g", kbSize.height);
//	NSLog(@"kb showing treeView origin.y, end.y = %g, %g", treeFrame.origin.y, treeFrame.size.height + treeFrame.origin.y);
	[_treeView scrollToRowForItem:item
				 atScrollPosition:RATreeViewScrollPositionBottom animated:NO];
}

- (void) keyboardWillDisappear:(NSNotification*)aNotification {
	NSTimeInterval duration = keyboardAnimationDuration(aNotification);
	CGSize kbSize = keyboardSize(aNotification);	// 320 x 216
	[UIView animateWithDuration:duration animations:^{
		CGRect treeFrame = _treeView.frame;
		treeFrame.size.height += kbSize.height;
//		treeFrame.size.height += self.tabBarController.tabBar.frame.size.height;
		[_treeView setFrame:treeFrame];
	} completion:^(BOOL finished) {
	}];
}

// ================================================================
#pragma mark Item manipulations
// ================================================================

-(void) saveItems {
//	NSLog(@"TreeViewController: saveItems: override this to persist data");
}

-(void) clickedDeleteCell:(DBTreeCell*)cell {
	UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Permanently delete item?" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete", nil];
	sheet.tag = kActionSheetTagDelete;
	sheet.delegate = self;
	self.cellInQuestion = cell;
	[sheet showInView:self.view];
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
	
	[self saveItems];
}

@end
