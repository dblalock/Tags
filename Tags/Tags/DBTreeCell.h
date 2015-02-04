//
//  DBTreeCell.h
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

#import "DBTableItem.h"	//ugh...somewhat tight coupling


// ================================================================
#pragma mark DBTreeCell Delegate
// ================================================================

@class DBTreeCell;

@protocol DBTreeCellDelegate <NSObject>

@optional
-(void) treeCell:(DBTreeCell*)cell didSetNameTo:(NSString*)name;
-(void) treeCelldidTapMainButton:(DBTreeCell*)cell;
-(void) treeCell:(DBTreeCell*)cell didSetDateTo:(NSDate*)date;
-(void) treeCell:(DBTreeCell*)cell didSetNumTo:(NSNumber*)date;
@end

// ================================================================
#pragma mark DBTreeCell
// ================================================================

@interface DBTreeCell : SWTableViewCell

@property(nonatomic) BOOL wantsUtilityButtons;
@property(nonatomic) NSUInteger preferredRowHeight;
@property(nonatomic) NSUInteger treeLvl;
@property(weak, nonatomic) id<DBTreeCellDelegate> treeDelegate;
@property(strong, nonatomic) CAGradientLayer* gradientLayer;

//@property(nonatomic) BOOL requiresSetup;

//- (void)setupWithTitle:(NSString *)title
//				 level:(NSInteger)level;

//- (void)setupWithTitle:(NSString *)title
//				 level:(NSInteger)level
//		   numChildren:(NSUInteger)numChildren;

+(UINib*) standardNib;

-(void) setupWithItem:(DBTableItem*)item
			  atLevel:(NSUInteger)lvl
			 expanded:(BOOL)expanded;


-(void) startEditing;
-(void) stopEditing;

-(void) startEditingNameWithSelectAll:(BOOL)selectAll;
-(void) startEditingName;
-(void) stopEditingName;

@end