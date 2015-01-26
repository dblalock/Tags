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

@interface DBTreeCell : SWTableViewCell

@property(nonatomic) BOOL wantsUtilityButtons;
@property(nonatomic) NSUInteger preferredRowHeight;
//@property(nonatomic) BOOL requiresSetup;

//- (void)setupWithTitle:(NSString *)title
//				 level:(NSInteger)level;

//- (void)setupWithTitle:(NSString *)title
//				 level:(NSInteger)level
//		   numChildren:(NSUInteger)numChildren;

-(void) setupWithItem:(DBTableItem*)item
			  atLevel:(NSUInteger)lvl
			 expanded:(BOOL)expanded;

-(void) startEditingName;
-(void) stopEditingName;

@end
