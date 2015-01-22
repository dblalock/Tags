//
//  FirstViewController.m
//  Tags
//
//  Created by DB on 1/21/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "FirstViewController.h"

#import <RATreeView.h>

#import "RADataObject.h"
#import "RATableViewCell.h"

@interface FirstViewController () <RATreeViewDataSource, RATreeViewDelegate>

@property (strong, nonatomic) NSArray *data;

//@property (weak, nonatomic) IBOutlet RATreeView *treeView;
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
	
	// this gets the treeview to use our custom layout + cell class
	[self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RATableViewCell class])];
	
	_data = defaultData();
	[_treeView reloadData];
	
//	self.edgesForExtendedLayout = UIRectEdgeNone;
//	[self setEdgesForExtendedLayout:UIRectEdgeNone];
}

// this just makes it not be behind the status bar
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// so this is the code block we actually want
	CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
	float statusBarHeight = statusBarViewRect.size.height;
	float tabBarHeight = self.tabBarController.tabBar.frame.size.height;
	CGRect viewBounds = self.view.bounds;
	viewBounds.origin.y = statusBarHeight;
	viewBounds.size.height -= tabBarHeight + statusBarHeight;
	self.treeView.frame = viewBounds;
	
	// make crap no be hidden behind the tab bar
//	[self.tabBarController setEdgesForExtendedLayout:UIRectEdgeNone];	//doesn't work
//	self.tabBarController.tabBar.translucent = NO;	// also doens't works
	
//	if([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
//	CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
//	float statusBarHeight = statusBarViewRect.size.height;
//	float tabBarHeight = self.tabBarController.view.frame.size.height; //like full screen height
//	float tabBarHeight = self.tabBarController.tabBar.frame.size.height; //correct
//		NSLog(@"tab bar height: %f", tabBarHeight);
//		self.treeView.contentInset = UIEdgeInsetsMake(statusBarHeight, 0.0, 0.0, 0.0);
//		self.treeView.contentInset = UIEdgeInsetsMake(statusBarHeight, 0.0, tabBarHeight, 0.0);	// bottom is insanely low cuz tabBarHeight=480.0
//		self.treeView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length], 0, [self.bottomLayoutGuide length], 0);	// behind status bar still
//	self.treeView.contentInset = UIEdgeInsetsMake(statusBarHeight, 0, [self.bottomLayoutGuide length], 0);	//works, but still scrolls under status bar
//	self.treeView.contentInset = UIEdgeInsetsMake(0, 0, -[self.bottomLayoutGuide length], 0);	//only moves bottom up
//		self.treeView.contentOffset = CGPointMake(0.0, -statusBarHeight);
//	}

//	NSLog(@"status bar height: %f", statusBarHeight);
//	NSLog(@"tab bar height: %f", tabBarHeight);
//	NSLog(@"bottom layout guide length: %g", self.bottomLayoutGuide.length); //0
//	NSLog(@"bottom layout guide length: %g", self.topLayoutGuide.length);	 //0
	
	// has no effect
//	CGRect viewBounds = self.view.bounds;
//	CGFloat topBarOffset = self.topLayoutGuide.length;	// 0 for no reason
//	viewBounds.origin.y = statusBarHeight;
//	viewBounds.size.height -= self.bottomLayoutGuide.length;	//not tall enough
////	viewBounds.size.height -= tabBarHeight;		// too tall
//	viewBounds.size.height -= tabBarHeight + statusBarHeight; //this is right
////	self.view.bounds = viewBounds;		//has no effect
//	self.treeView.frame = viewBounds;

//	self.treeView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

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
- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
	RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
	[cell setAdditionButtonHidden:NO animated:YES];
}
- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
{
	RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
	[cell setAdditionButtonHidden:YES animated:YES];
}

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
	
	RADataObject *parent = [self.treeView parentForItem:item];
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
	// so this hands us the actual object at the index; there are then utility
	// methods (apparently designed to be called just from this delegate method)
	// that tell us what level in the tree it is and whether the cell is expanded
	//
	// we get the number of children from the item itself, which is an instance
	// of a custom class
	//
	// at the end of this block, we have the:
	// -item object
	// -how many children it has
	// -whether it's expanded
	// -its level in the tree
	RADataObject *dataObject = item;
	NSInteger level = [self.treeView levelForCellForItem:item];
	NSInteger numberOfChildren = [dataObject.children count];
	BOOL expanded = [self.treeView isCellForItemExpanded:item];
	
	// create part of the text to show in the cell
	NSString *detailText = [NSString localizedStringWithFormat:@"# of children %@", [@(numberOfChildren) stringValue]];
	
	// get the actual cell object (of our own custom class) by calling a handy
	// treeview method
	RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];
	
	// set the cell's content using a method of our cell class; the class is
	// linked to the actual UI elements via cocoa bindings in IB
	[cell setupWithTitle:dataObject.name detailText:detailText level:level additionButtonHidden:!expanded];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	// set the callback for when the "+" button is clicked
	__weak typeof(self) weakSelf = self;
	cell.additionButtonTapAction = ^(id sender) {
		// if not expanded or in the middle of editing, ignore button click
		if (![weakSelf.treeView isCellForItemExpanded:dataObject] || weakSelf.treeView.isEditing) {
			return;
		}
		
		// otherwise, add a new value below this cell using cool treview methods
		RADataObject *newDataObject = [[RADataObject alloc] initWithName:@"Added value" children:@[]];
		[dataObject addChild:newDataObject];
		[weakSelf.treeView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0] inParent:dataObject withAnimation:RATreeViewRowAnimationLeft];
		[weakSelf.treeView reloadRowsForItems:@[dataObject] withRowAnimation:RATreeViewRowAnimationNone];
	};
	
	return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
	if (item == nil) {
		return [self.data count];
	}
	
	RADataObject *data = item;
	return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
	RADataObject *data = item;
	if (item == nil) {
		return [self.data objectAtIndex:index];
	}
	return data.children[index];
}

// ================================================================
#pragma mark Other funcs
// ================================================================

NSArray* defaultData() {
	RADataObject *phone1 = [RADataObject dataObjectWithName:@"Phone 1" children:nil];
	RADataObject *phone2 = [RADataObject dataObjectWithName:@"Phone 2" children:nil];
	RADataObject *phone3 = [RADataObject dataObjectWithName:@"Phone 3" children:nil];
	RADataObject *phone4 = [RADataObject dataObjectWithName:@"Phone 4" children:nil];
	
	RADataObject *phone = [RADataObject dataObjectWithName:@"Phones"
												  children:[NSArray arrayWithObjects:phone1, phone2, phone3, phone4, nil]];
	
	RADataObject *notebook1 = [RADataObject dataObjectWithName:@"Notebook 1" children:nil];
	RADataObject *notebook2 = [RADataObject dataObjectWithName:@"Notebook 2" children:nil];
	
	RADataObject *computer1 = [RADataObject dataObjectWithName:@"Computer 1"
													  children:[NSArray arrayWithObjects:notebook1, notebook2, nil]];
	RADataObject *computer2 = [RADataObject dataObjectWithName:@"Computer 2" children:nil];
	RADataObject *computer3 = [RADataObject dataObjectWithName:@"Computer 3" children:nil];
	
	RADataObject *computer = [RADataObject dataObjectWithName:@"Computers"
													 children:[NSArray arrayWithObjects:computer1, computer2, computer3, nil]];
	RADataObject *car = [RADataObject dataObjectWithName:@"Cars" children:nil];
	RADataObject *bike = [RADataObject dataObjectWithName:@"Bikes" children:nil];
	RADataObject *house = [RADataObject dataObjectWithName:@"Houses" children:nil];
	RADataObject *flats = [RADataObject dataObjectWithName:@"Flats" children:nil];
	RADataObject *motorbike = [RADataObject dataObjectWithName:@"Motorbikes" children:nil];
	RADataObject *drinks = [RADataObject dataObjectWithName:@"Drinks" children:nil];
	RADataObject *food = [RADataObject dataObjectWithName:@"Food" children:nil];
	RADataObject *sweets = [RADataObject dataObjectWithName:@"Sweets" children:nil];
	RADataObject *watches = [RADataObject dataObjectWithName:@"Watches" children:nil];
	RADataObject *walls = [RADataObject dataObjectWithName:@"Walls" children:nil];
	
	return @[phone, computer, car, bike, house, flats, motorbike, drinks, food, sweets, watches, walls];
}

@end
