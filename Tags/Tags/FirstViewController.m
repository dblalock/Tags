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


//#import "RATableViewCell.h"

NSString* reuseIdentifier(Class cls) {
	return NSStringFromClass(cls);
}


@interface FirstViewController () <RATreeViewDataSource, RATreeViewDelegate,
	SWTableViewCellDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *data;
@property (weak, nonatomic) RATreeView *treeView;
@property (weak, nonatomic) SWTableViewCell *cellInQuestion; //for action sheets

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
	[self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([DBTreeCell class]) bundle:nil] forCellReuseIdentifier:reuseIdentifier([DBTreeCell class])];
	// example tableviewcell nib
//	[self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:reuseIdentifier([DBTreeCell class])];

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

// hide keyboard on touch outside
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
////	[self.view endEditing:YES];		// no effect on cell text
////	[self.treeView endEditing:YES]; // no effect on cell text
//}

// ================================================================
#pragma mark TreeView Delegate methods
// ================================================================

//--------------------------------
// row attributes
//--------------------------------
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
	return 44;
}

//--------------------------------
// expanding/collapsing rows
//--------------------------------
//- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
//	RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
//	[cell setAdditionButtonHidden:NO animated:YES];
//}
//- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
//{
//	RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
//	[cell setAdditionButtonHidden:YES animated:YES];
//}

//--------------------------------
// tree modification (deleting cells)
//--------------------------------
-(BOOL) treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
//	return YES;
	return NO;
}

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
//	BOOL expanded = [self.treeView isCellForItemExpanded:item];
	
	DBTreeCell* cell = [treeView dequeueReusableCellWithIdentifier:reuseIdentifier([DBTreeCell class])];
	
	[cell setupWithTitle:tableItem.name level:lvl numChildren:[tableItem.children count]];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	
	// SWTableViewCell wonderfulness
	// from: www.appcoda.com/swipeable-uitableviewcell-tutorial/
//	NSMutableArray *leftUtilityButtons = [NSMutableArray new];
	NSMutableArray *rightUtilityButtons = [NSMutableArray new];
	
//	[leftUtilityButtons sw_addUtilityButtonWithColor:
//	 [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:0.7]
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
	
	[rightUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:0.1f green:1.0f blue:0.0f alpha:1.0]
												title:@"SubTag"];
	[rightUtilityButtons sw_addUtilityButtonWithColor:
	 [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
												title:@"Delete"];
	
//	cell.leftUtilityButtons = leftUtilityButtons;
	cell.rightUtilityButtons = rightUtilityButtons;
	cell.delegate = self;
	
	return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
	if (item == nil) {
		return [self.data count];
	}

	DBTableItem *data = item;
	return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
	DBTableItem *data = item;
	if (item == nil) {
		return [self.data objectAtIndex:index];
	}
	return data.children[index];
}

// ================================================================
#pragma mark SWTableViewCellDelegate
// ================================================================

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
	
	switch (index) {
		case 0:
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bookmark" message:@"Save to favorites successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alertView show];
			break;
		}
		case 1:
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email sent" message:@"Just sent the image to your INBOX" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alertView show];
			break;
		}
		case 2:
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Sharing" message:@"Just shared the pattern image on Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alertView show];
			break;
		}
		case 3:
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Sharing" message:@"Just shared the pattern image on Twitter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alertView show];
		}
		default:
			break;
	}
}

static const int kTagDelete = 1;
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
	switch (index) {
		case 0:		// Sub-Tag Button
		{
			// More button is pressed

			
//			[cell hideUtilityButtonsAnimated:YES];
			break;
		}
		case 1:		// Delete button
		{
			UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Permanently delete tag?" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete", nil];
			[sheet showInView:self.view];
			sheet.tag = kTagDelete;
			sheet.delegate = self;
			_cellInQuestion = cell;
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
	NSLog(@"action sheet: button idx = %d", buttonIndex);
	switch (actionSheet.tag) {
		case kTagDelete:
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
#pragma mark Helper Funcs
// ================================================================

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
