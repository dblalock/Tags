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
#import "DBTreeItemAddNew.h"
#import "DBTreeCell.h"
#import "TypManager.h"

static NSString *const kCellNewButtonNibName = @"DBCellAddNew";
static NSString *const kCellNewButtonIdentifier = @"cellNewButton";
static const int kActionSheetTagDelete = 1;

@interface FirstViewController () <RATreeViewDataSource, RATreeViewDelegate,
	SWTableViewCellDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *data;
@property (weak, nonatomic) RATreeView *treeView;
@property (weak, nonatomic) DBTreeCell *cellInQuestion; //for action sheets

//@property (weak, nonatomic) id<RATreeViewDataSource> dataSource;
//@property (weak, nonatomic) id<RATreeViewDelegate> delegate;

@end

@implementation FirstViewController

CGRect fullScreenFrame() {
	return CGRectMake(0, 0,
					  [[UIScreen mainScreen] applicationFrame].size.width,
					  [[UIScreen mainScreen] applicationFrame].size.height);
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// we create a temporary treeview object so that we don't assign
	// directly to a weak property until it's been retained by self.view...I think
	RATreeView* treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
	[self.view insertSubview:treeView atIndex:0];
	_treeView = treeView;

	_treeView.delegate = self;
	_treeView.dataSource = self;
	_treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLineEtched;

	// this just adds a background behind the status bar, because the treeview
	// hasn't been resized to start below it yet; it seems to stick around even
	// after the treeview is resized
//	[_treeView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:.6]];

	// my tableviewcell nib
	NSString* treeCellNibName = NSStringFromClass([DBTreeCell class]);
	UINib* treeCellNib = [UINib nibWithNibName:treeCellNibName bundle:nil];
	UINib* addNewNib = [UINib nibWithNibName:kCellNewButtonNibName bundle:nil];
	[self.treeView registerNib:treeCellNib forCellReuseIdentifier:[DBTableItem reuseIdentifier]];	// tableItem
	[self.treeView registerNib:treeCellNib forCellReuseIdentifier:[DBTypItem reuseIdentifier]];		// typItem
	[self.treeView registerNib:addNewNib forCellReuseIdentifier:[DBTreeItemAddNew reuseIdentifier]];// add new button
	
	// dealing with keyboard covering crap
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardWillShow:)
												 name: UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardWillDisappear:)
												 name: UIKeyboardWillHideNotification object:nil];
	
//	_data = defaultData();
	_data = [defaultTypItems() mutableCopy];
	[_treeView reloadData];
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

// hide keyboard on touch outside
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	NSLog(@"view controller touches began");	// never runs
//	[_cellInQuestion stopEditingName];	// no effect
//	[self.view endEditing:YES];		// no effect on cell text
//	[self.treeView endEditing:YES]; // no effect on cell text
//}

// ================================================================
#pragma mark TreeView Delegate methods
// ================================================================

//--------------------------------
// row attributes
//--------------------------------
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
	DBTreeCell* cell = (DBTreeCell*)[treeView cellForItem:item];
	return cell.preferredRowHeight ? cell.preferredRowHeight : 44;
}

//--------------------------------
// expanding/collapsing rows
//--------------------------------
- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
	if ([item isKindOfClass:[DBTreeItemAddNew class]]) {
		[self addRootItem];
	}
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
	DBTreeCell* cell = (DBTreeCell*) [treeView cellForItem:item];
	[cell stopEditingName];
}

//--------------------------------
// tree / cell modification
//--------------------------------
-(BOOL) treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
//	return YES;
	return NO;
}

// returns yes if it stopped something, and no if it wasn't editing anyway;
// this is just a hack to close keyboard on touch outside
-(BOOL) stopEditingCell {
	if (_cellInQuestion) {
		[_cellInQuestion stopEditingName];
		_cellInQuestion = nil;
		return YES;
	}
	return NO;
}

// these two methods are basically a hack to get it to close the keyboard
// when you click outside of the text view
-(BOOL)treeView:(RATreeView *)treeView shouldCollapaseRowForItem:(id)item {
	return ! [self stopEditingCell];
}
-(BOOL)treeView:(RATreeView *)treeView shouldExpandRowForItem:(id)item {
	return ! [self stopEditingCell];
}

//- (BOOL)treeView:(RATreeView *)treeView shouldShowMenuForRowForItem:(id)item {
//	return YES;	// no effect
//}

//- (void) treeView:(RATreeView *)treeView
//commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//	forRowForItem:(id)item {
//	// all we allow is deleting rows
//	if (editingStyle != UITableViewCellEditingStyleDelete) {
//		return;
//	}
//	// TODO there's probably a way to add the option to insert rows using
//	// the "edit" button at the top (in the original example), which would
//	// be way better than having the plus button, since you only want to
//	// edit pretty rarely; would prolly make this also do stuff in response
//	// to editing style UITableViewCellEditingStyleInsert
//
//	[self deleteItem:item];
//}

// can't tell if this does anything or not...
//-(NSInteger) treeView:(RATreeView*)treeView indentationLevelForRowForItem:(id)item {
//	return [treeView levelForCellForItem:item];
//}

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
//												icon:[UIImage imageNamed:@"like.png"]];
//	[leftUtilityButtons sw_addUtilityButtonWithColor:
//	 [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.7]
//												icon:[UIImage imageNamed:@"message.png"]];
//	[leftUtilityButtons sw_addUtilityButtonWithColor:
//	 [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.7]
//												icon:[UIImage imageNamed:@"facebook.png"]];
//	[leftUtilityButtons sw_addUtilityButtonWithColor:
//	 [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.7]
//												icon:[UIImage imageNamed:@"twitter.png"]];
	
	[rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor]
//	 [UIColor colorWithRed:0.1f green:1.0f blue:0.0f alpha:1.0]
												title:@"New"];
	[rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor]
//	 [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
												title:@"Delete"];
	
	cell.leftUtilityButtons = leftUtilityButtons;
	cell.rightUtilityButtons = rightUtilityButtons;
	cell.delegate = self;
	
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

-(void) clickedEditCell:(DBTreeCell*)cell {
//	[cell hideUtilityButtonsAnimated:YES];	// YES apparently doesn't work if we have it actually edit
	_cellInQuestion = cell;
	[(DBTreeCell*)cell startEditingName];
}

-(void) clickedAddChildToCell:(UITableViewCell*)cell {
	[self addChildTo:[self.treeView itemForCell:cell]];
}

-(void) clickedDeleteCell:(DBTreeCell*)cell {
	UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Permanently delete tag?" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete", nil];
	sheet.tag = kActionSheetTagDelete;
	sheet.delegate = self;
	_cellInQuestion = cell;
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
			if (_cellInQuestion && buttonIndex == 0) {	// cancel = 1, do it = 0
				[self deleteItem:[self.treeView itemForCell:_cellInQuestion]];
			} else {
				[_cellInQuestion hideUtilityButtonsAnimated:YES];
			}
			_cellInQuestion = nil;
			break;
		default:
			break;
	}
}

// ================================================================
#pragma mark Keyboard not covering tableview
// ================================================================

- (void) keyboardWillShow: (NSNotification*) aNotification {
	[UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
		[_cellInQuestion hideUtilityButtonsAnimated:YES];
		
		CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
		//		NSLog(@"%@", NSStringFromCGSize(kbSize));	// 320 x 216
		CGRect treeFrame = _treeView.frame;
		treeFrame.size.height -= kbSize.height - self.tabBarController.tabBar.frame.size.height;
		[_treeView setFrame:treeFrame];
		
		SWTableViewCell *cell = _cellInQuestion;
		[_treeView scrollToRowForItem:[_treeView itemForCell:cell] atScrollPosition:RATreeViewScrollPositionBottom animated:YES];

	} completion:^(BOOL finished) {

	}];
}

- (void) keyboardWillDisappear: (NSNotification*) aNotification {
	[UIView animateWithDuration: [self keyboardAnimationDurationForNotification: aNotification] animations:^{
		//restore your tableview
		CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
		
		CGRect treeFrame = _treeView.frame;
		treeFrame.size.height += kbSize.height - self.tabBarController.tabBar.frame.size.height;
		[_treeView setFrame:treeFrame];
	} completion:^(BOOL finished) {
	}];
}

- (NSTimeInterval) keyboardAnimationDurationForNotification:(NSNotification*)notification {
	NSDictionary* info = [notification userInfo];
	NSValue* value = [info objectForKey: UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval duration = 0;
	[value getValue: &duration];
	return duration;
}

// ================================================================
#pragma mark Helper Funcs
// ================================================================

static NSString *const kDefaultChildName = @"New Tag";


-(void) addRootItem {
	DBTableItem *newChild = [[DBTableItem alloc] initWithName:kDefaultChildName children:nil];
	[self.data addObject:newChild];
//	int idx = [self.data count] - 1;
//	[self.treeView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:idx] inParent:nil withAnimation:RATreeViewRowAnimationLeft];
//	[self.treeView reloadRowsForItems:nil withRowAnimation:RATreeViewRowAnimationNone];
	[self.treeView reloadData];
}


-(void) addChildTo:(DBTableItem*)parent {
	// This seems to look slightly better than no animation when
	// there are a lot of children already
	[self.treeView expandRowForItem:parent withRowAnimation:RATreeViewRowAnimationMiddle];
	
	// TODO make this be a DBTypItem, or even something else
	
	DBTableItem *newChild = [[DBTableItem alloc] initWithName:kDefaultChildName children:nil];
	[DBTableItem joinParent:parent toChild:newChild];
	[self.treeView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0] inParent:parent withAnimation:RATreeViewRowAnimationLeft];
	[self.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];
	
	// assume user doesn't want to keep the name "New Tag"
	DBTreeCell* cell = (DBTreeCell*)[self.treeView cellForItem:newChild];
	[cell startEditingName];
	// TODO make this be a thing
//	[[self.treeView cellForItem:newDataObject] editName];
}

-(void) deleteItem:(DBTableItem*)item {
	DBTableItem *parent = [self.treeView parentForItem:item];
	NSInteger index = 0;
	
	if (parent == nil) {
		index = [self.data indexOfObject:item];
		NSMutableArray *children = [self.data mutableCopy];
		[children removeObject:item];
		self.data = [children copy];
		
	} else {
		index = [parent.children indexOfObject:item];
		[parent removeChild:item];
	}
	
	[self.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parent withAnimation:RATreeViewRowAnimationRight];
	if (parent) {
		[self.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];
	}
}

//NSArray* defaultData() {
//	DBTableItem *phone1 = [DBTableItem itemWithName:@"Phone 1" children:nil];
//	DBTableItem *phone2 = [DBTableItem itemWithName:@"Phone 2" children:nil];
//	DBTableItem *phone3 = [DBTableItem itemWithName:@"Phone 3" children:nil];
//	DBTableItem *phone4 = [DBTableItem itemWithName:@"Phone 4" children:nil];
//
//	DBTableItem *phone = [DBTableItem itemWithName:@"Phones"
//												  children:[NSArray arrayWithObjects:phone1, phone2, phone3, phone4, nil]];
//
//	DBTableItem *notebook1 = [DBTableItem itemWithName:@"Notebook 1" children:nil];
//	DBTableItem *notebook2 = [DBTableItem itemWithName:@"Notebook 2" children:nil];
//
//	DBTableItem *computer1 = [DBTableItem itemWithName:@"Computer 1"
//													  children:[NSArray arrayWithObjects:notebook1, notebook2, nil]];
//	DBTableItem *computer2 = [DBTableItem itemWithName:@"Computer 2" children:nil];
//	DBTableItem *computer3 = [DBTableItem itemWithName:@"Computer 3" children:nil];
//
//	DBTableItem *computer = [DBTableItem itemWithName:@"Computers"
//													 children:[NSArray arrayWithObjects:computer1, computer2, computer3, nil]];
//	DBTableItem *car = [DBTableItem itemWithName:@"Cars" children:nil];
//	DBTableItem *bike = [DBTableItem itemWithName:@"Bikes" children:nil];
//	DBTableItem *house = [DBTableItem itemWithName:@"Houses" children:nil];
//	DBTableItem *flats = [DBTableItem itemWithName:@"Flats" children:nil];
//	DBTableItem *motorbike = [DBTableItem itemWithName:@"Motorbikes" children:nil];
//	DBTableItem *drinks = [DBTableItem itemWithName:@"Drinks" children:nil];
//	DBTableItem *food = [DBTableItem itemWithName:@"Food" children:nil];
//	DBTableItem *sweets = [DBTableItem itemWithName:@"Sweets" children:nil];
//	DBTableItem *watches = [DBTableItem itemWithName:@"Watches" children:nil];
//	DBTableItem *walls = [DBTableItem itemWithName:@"Walls" children:nil];
//
//	return @[phone, computer, car, bike, house, flats, motorbike, drinks, food, sweets, watches, walls];
//}

@end
