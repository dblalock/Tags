//
//  DBTreeCellAddNew.m
//  Tags
//
//  Created by DB on 1/23/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTreeCellAddNew.h"

@implementation DBTreeCellAddNew

-(void) setupWithItem:(DBTableItem*)item atLevel:(NSUInteger)lvl {
	NSLog(@"called treeCellAddNew#setupWithItem");
}

-(BOOL) wantsUtilityButtons {
	return NO;
}
//-(BOOL) requiresSetup {
//	return NO;
//}

@end
