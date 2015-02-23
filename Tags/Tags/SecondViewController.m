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
#import <NSDate+Escort.h>
#import "MZDayPicker.h"

#import "FirstViewController.h"

//#import "DBTableItem.h"
#import "DBTagItem.h"
#import "DBTreeCell.h"
#import "TypManager.h"
#import "Typ.h"
#import "Tag.h"

//#import "DBCellManager.h"
#import "DBItemManager.h"

#import "DBTimeRangeItem.h"	// TODO shouldn't know about concrete class

static NSString *const kCellNewButtonNibName = @"DBCellAddNew";
static NSString *const kCellNewButtonIdentifier = @"cellNewButton";

static const float kStatusBarHeight = 20.0f;

@interface SecondViewController () <SWTableViewCellDelegate, DBTagItemDelegate,
	MZDayPickerDataSource, MZDayPickerDelegate>
@property (strong, nonatomic) MZDayPicker* dayPicker;
@property (strong, nonatomic) NSDateFormatter* dayNameFormatter;
//@property (strong, nonatomic) NSMutableDictionary* dataForDays;
@property (strong, nonatomic) NSDate* displayedDay;
@end

@implementation SecondViewController

-(void) viewDidLoad {
	[super viewDidLoad];
	
	// all of these except the heights apparently get ignored, except that
	// they have to set to not be 0 initially or it'll freak out
	float dayPickerCellWidth = 50.0f;	// ignored
	float dayPickerCellHeight = 50.0f;
	float dayCellFooterHeight = 0.0f;	// ignored
	float dayPickerHeight = 40.0f;
	_dayPicker = [[MZDayPicker alloc] initWithFrame:CGRectMake(0, kStatusBarHeight,
															   self.view.bounds.size.width,
															   dayPickerHeight + kStatusBarHeight)
										dayCellSize:CGSizeMake(dayPickerCellWidth, dayPickerCellHeight)
								dayCellFooterHeight:dayCellFooterHeight];
	[self.view insertSubview:_dayPicker atIndex:0];	// magically makes frames work?
	_dayPicker.delegate = self;
	_dayPicker.dataSource = self;
	_dayPicker.dayNameLabelFontSize = 13.0f;
	_dayPicker.dayLabelFontSize = 18.0f;
//	[self.dayPicker setStartDate:[NSDate dateFromDay:28 month:9 year:2013] endDate:[NSDate dateFromDay:5 month:10 year:2013]];
//	[_dayPicker setCurrentDate:[NSDate date] animated:NO];
	
	_dayNameFormatter = [[NSDateFormatter alloc] init];
	[_dayNameFormatter setDateFormat:@"EE"];
//	[_dayNameFormatter setDateFormat:@"M"];
	
	
	// TODO put this in [self showDataForSelectedDay]
//	self.dataForDays = [getAllTagItems() mutableCopy];	// TODO uncomment
//	self.dataForDays = [@{} mutableCopy];
//	NSCalendar* cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
//	NSDate* selectedDay;
//	[cal rangeOfUnit:NSCalendarUnitDay startDate:&selectedDay interval:nil forDate:[NSDate date]];
//	NSDate* currentDay = [cal startOfDayForDate:[NSDate date]];

	
	// TODO start/end dates a week before/after first/last dates in history dict,
	// if these are earlier/later
//	NSDate* today = [[NSDate date] dateAtStartOfDay];
	NSDate* today = [NSDate date];
	[_dayPicker setStartDate:[today dateBySubtractingDays:7]];
	[_dayPicker setEndDate:[today dateByAddingMonths:1]];
	[_dayPicker setCurrentDate:today animated:NO];
	
	self.displayedDay = today;
	
//	[self showDataForDate:today];
//	self.data = [getAllTagItems() mutableCopy];
//	self.data = [defaultTagItems() mutableCopy];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notifiedTypSelected:)
												 name:kNotificationTypSelected
											   object:nil];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// no really, be below the status bar
	CGRect dayFrame = self.dayPicker.frame;
	dayFrame.origin.y = kStatusBarHeight;
//	dayFrame.size.height = 40;	// cells pick the height they want, so this
//								// just defines where the view below it can start;
//								// this is the correct height to not be hideous
	self.dayPicker.frame = dayFrame;
	
	// resize treeview to not be under day picker
	CGRect frame = self.treeView.frame;
	frame.origin.y = dayFrame.origin.y + dayFrame.size.height + 8;	//+5 for footer part
	frame.size.height = self.view.bounds.size.height - frame.origin.y;// dayFrame.size.height;
	self.treeView.frame = frame;
	
	// y this have gap between stuff!? None of these fix it:
//	self.dayPicker.backgroundColor = [UIColor redColor];
//	self.treeView.backgroundColor = [UIColor blueColor];
//	self.treeView.contentSize = frame.size;
//	self.treeView.contentInset = UIEdgeInsetsZero;
//	self.treeView.treeHeaderView = nil;
//	NSLog(@"subviews : %@", self.view.subviews);
	
	// hide navigation bar
	self.navigationController.navigationBarHidden = YES;
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.navigationController.navigationBarHidden = NO;
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
//	NSLog(@"dequed cell of class: %@\n\n", [cell class]);

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
			// TODO ideally deep copy with original tag's values
			DBTagItem* item = [self.treeView itemForCell:cell];
//			DBTagItem* dup = [[DBTagItem alloc] initWithTyp:item.tag.typ];
			DBTagItem* dup = createTagItemForTyp(item.tag.typ);
			dup.tagDelegate = self;
			[self.data addObject:dup];
//			[self.treeView reloadData];
			[self refreshData];
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
#pragma mark DBTagItem Delegate
// ================================================================

-(void) itemDidChange:(DBTagItem*)item {
//	DBTreeCell* cell = [self.treeView cellForItem:item];
//	if (cell.cellState == kCellStateCenter) return;	//private property of SWTableViewCell
	[self saveItems];	// TODO remove if performance hit
	[self.treeView reloadRowsForItems:@[item] withRowAnimation:RATreeViewRowAnimationNone];
}

// ================================================================
#pragma mark DBTreeCell Delegate
// ================================================================

//-(void) treeCell:(DBTreeCell *)cell didSetNameTo:(NSString *)name {
//	DBTableItem* item = [self.treeView itemForCell:cell];
//	item.name = name;
//}

// ================================================================
#pragma mark MZDayPicker Data Source
// ================================================================

-(NSString*) dayPicker:(MZDayPicker*) dayPicker titleForCellDayNameLabelInDay:(MZDay*)day {
	return [self.dayNameFormatter stringFromDate:day.date];
}

// ================================================================
#pragma mark MZDayPicker Delegate
// ================================================================

-(void) dayPicker:(MZDayPicker *)dayPicker didSelectDay:(MZDay *)day {
	self.displayedDay = day.date;
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
#pragma mark Item manipulation
// ================================================================

-(void) refreshData {
	self.data = [[DBTagItem sortedItems:self.data] mutableCopy];
	[self.treeView reloadData];
}

-(void) saveItems {
//	NSLog(@"------ about to save tag items for date");
	saveTagItemsForDate(self.data, self.displayedDay);
//	NSLog(@"------ saved tag items for date");
}

-(void)notifiedTypSelected:(NSNotification*)notification {
	[self.navigationController popToViewController:self animated:YES];
	Typ* typ = extractTypFromNotification(notification);
	[self addItemOfTyp:typ];
}

-(void) addItemOfTyp:(Typ*)typ {
	if (! typ) return;
//	NSLog(@"2ndVC: adding item of typ: %@", typ);
	DBTagItem* item = createTagItemForTyp(typ);
	if ([item isKindOfClass:[DBTimeRangeItem class]]) {	// TODO interface, not class
		[((DBTimeRangeItem*)item) setDay:_displayedDay];
	}
//	NSLog(@"2ndVC: created item %@ has typ: %@", item, item.tag.typ);
	item.tagDelegate = self;
	[self.data addObject:item];
//	[self.treeView reloadData];
	[self refreshData];
	
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
	cntrl.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:cntrl animated:YES];
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

	[self saveItems];
}

-(void) setDisplayedDay:(NSDate *)displayedDay {
	if ([_displayedDay isEqualToDate: displayedDay]) return;
	_displayedDay = displayedDay;
	NSArray* dataForDay = getTagItemsForDate(displayedDay);
	if (! [dataForDay count]) {
		dataForDay = [NSMutableArray array];
	}
	self.data = [dataForDay mutableCopy];
	for (DBTagItem* item in self.data) {
		item.tagDelegate = self;
	}
	[self refreshData];
}

@end
