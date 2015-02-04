//
//  DBTreeCellAddNew.m
//  Tags
//
//  Created by DB on 1/23/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTreeCellAddNew.h"

@implementation DBTreeCellAddNew

-(void) layoutSubviews {
	[super layoutSubviews];
	self.backgroundColor = [UIColor greenColor];
}

-(CAGradientLayer*) createGradientLayer {
	CAGradientLayer* gradientLayer = [CAGradientLayer layer];
	gradientLayer.frame = self.bounds;
	gradientLayer.colors = @[(id)[[UIColor colorWithWhite:1.0f alpha:0.3f] CGColor],
							(id)[[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor],
							(id)[[UIColor clearColor] CGColor],
							(id)[[UIColor colorWithWhite:0.0f alpha:0.2f] CGColor]];
	gradientLayer.locations = @[@0.00f, @0.01f, @0.95f, @1.00f];
	return gradientLayer;
}

-(void) setupWithItem:(DBTableItem*)item atLevel:(NSUInteger)lvl {
	NSLog(@"Uh oh...called treeCellAddNew#setupWithItem");
}

-(BOOL) wantsUtilityButtons {
	return NO;
}
//-(BOOL) requiresSetup {
//	return NO;
//}

@end
