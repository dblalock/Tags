//
//  FirstViewController.m
//  Tags
//
//  Created by DB on 1/21/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "FirstViewController.h"

#import <RATreeView.h>

#import "DBTableItem.h"
#import "DBTreeCell.h"
#import "RATableViewCell.h"

NSString* reuseIdentifier(Class cls) {
	return NSStringFromClass(cls);
}


@interface FirstViewController () <RATreeViewDataSource, RATreeViewDelegate>

@property (strong, nonatomic) NSArray *data;

@property (weak, nonatomic) RATreeView *treeView;

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

	_data = defaultData();
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
- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
	return YES;
}

- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item {
	// all we allow is deleting rows
	if (editingStyle != UITableViewCellEditingStyleDelete) {
		return;
	}
	// TODO there's probably a way to add the option to insert rows using
	// the "edit" button at the top (in the original example), which would
	// be way better than having the plus button, since you only want to
	// edit pretty rarely; would prolly make this also do stuff in response
	// to editing style UITableViewCellEditingStyleInsert

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

// ================================================================
#pragma mark TreeView Data Source methods
// ================================================================

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
	DBTableItem *dataObject = item;
	NSInteger lvl = [self.treeView levelForCellForItem:item];
//	NSInteger numberOfChildren = [dataObject.children count];
//	BOOL expanded = [self.treeView isCellForItemExpanded:item];
	
	DBTreeCell* cell = [treeView dequeueReusableCellWithIdentifier:reuseIdentifier([DBTreeCell class])];
	
	if (lvl) {
		NSLog(@"lvl = %d", lvl);
	}
	
	[cell setupWithTitle:dataObject.name level:lvl];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
//	NSLog(@"setup: titleTextFrame: %@", NSStringFromCGRect(cell.titleText.frame));
//	cell.titleText.textColor = [UIColor blueColor];
//	cell.autoresizesSubviews = YES;//NO; // neither helps
	
	return cell;
}

//- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
//	// so this hands us the actual object at the index; there are then utility
//	// methods (apparently designed to be called just from this delegate method)
//	// that tell us what level in the tree it is and whether the cell is expanded
//	//
//	// we get the number of children from the item itself, which is an instance
//	// of a custom class
//	//
//	// at the end of this block, we have the:
//	// -item object
//	// -how many children it has
//	// -whether it's expanded
//	// -its level in the tree
//	DBTableItem *dataObject = item;
//	NSInteger level = [self.treeView levelForCellForItem:item];
//	NSInteger numberOfChildren = [dataObject.children count];
//	BOOL expanded = [self.treeView isCellForItemExpanded:item];
//
//	// create part of the text to show in the cell
//	NSString *detailText = [NSString localizedStringWithFormat:@"# of children %@", [@(numberOfChildren) stringValue]];
//
//	// get the actual cell object (of our own custom class) by calling a handy
//	// treeview method
//	RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];
//
//	// set the cell's content using a method of our cell class; the class is
//	// linked to the actual UI elements via cocoa bindings in IB
//	[cell setupWithTitle:dataObject.name detailText:detailText level:level additionButtonHidden:!expanded];
//	cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//	// set the callback for when the "+" button is clicked
//	__weak typeof(self) weakSelf = self;
//	cell.additionButtonTapAction = ^(id sender) {
//		// if not expanded or in the middle of editing, ignore button click
//		if (![weakSelf.treeView isCellForItemExpanded:dataObject] || weakSelf.treeView.isEditing) {
//			return;
//		}
//
//		// otherwise, add a new value below this cell using cool treview methods
//		DBTableItem *newDataObject = [[DBTableItem alloc] initWithName:@"Added value" children:@[]];
//		[dataObject addChild:newDataObject];
//		[weakSelf.treeView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0] inParent:dataObject withAnimation:RATreeViewRowAnimationLeft];
//		[weakSelf.treeView reloadRowsForItems:@[dataObject] withRowAnimation:RATreeViewRowAnimationNone];
//	};
//
//	return cell;
//}

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
#pragma mark Other funcs
// ================================================================

NSArray* defaultData() {
	DBTableItem *phone1 = [DBTableItem itemWithName:@"Phone 1" children:nil];
	DBTableItem *phone2 = [DBTableItem itemWithName:@"Phone 2" children:nil];
	DBTableItem *phone3 = [DBTableItem itemWithName:@"Phone 3" children:nil];
	DBTableItem *phone4 = [DBTableItem itemWithName:@"Phone 4" children:nil];

	DBTableItem *phone = [DBTableItem itemWithName:@"Phones"
												  children:[NSArray arrayWithObjects:phone1, phone2, phone3, phone4, nil]];

	DBTableItem *notebook1 = [DBTableItem itemWithName:@"Notebook 1" children:nil];
	DBTableItem *notebook2 = [DBTableItem itemWithName:@"Notebook 2" children:nil];

	DBTableItem *computer1 = [DBTableItem itemWithName:@"Computer 1"
													  children:[NSArray arrayWithObjects:notebook1, notebook2, nil]];
	DBTableItem *computer2 = [DBTableItem itemWithName:@"Computer 2" children:nil];
	DBTableItem *computer3 = [DBTableItem itemWithName:@"Computer 3" children:nil];

	DBTableItem *computer = [DBTableItem itemWithName:@"Computers"
													 children:[NSArray arrayWithObjects:computer1, computer2, computer3, nil]];
	DBTableItem *car = [DBTableItem itemWithName:@"Cars" children:nil];
	DBTableItem *bike = [DBTableItem itemWithName:@"Bikes" children:nil];
	DBTableItem *house = [DBTableItem itemWithName:@"Houses" children:nil];
	DBTableItem *flats = [DBTableItem itemWithName:@"Flats" children:nil];
	DBTableItem *motorbike = [DBTableItem itemWithName:@"Motorbikes" children:nil];
	DBTableItem *drinks = [DBTableItem itemWithName:@"Drinks" children:nil];
	DBTableItem *food = [DBTableItem itemWithName:@"Food" children:nil];
	DBTableItem *sweets = [DBTableItem itemWithName:@"Sweets" children:nil];
	DBTableItem *watches = [DBTableItem itemWithName:@"Watches" children:nil];
	DBTableItem *walls = [DBTableItem itemWithName:@"Walls" children:nil];

	return @[phone, computer, car, bike, house, flats, motorbike, drinks, food, sweets, watches, walls];
}

@end
