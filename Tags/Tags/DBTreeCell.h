//
//  DBTreeCell.h
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface DBTreeCell : SWTableViewCell

//+(NSString*) reuseIdentifier;

//- (void)setupWithTitle:(NSString *)title
//				 level:(NSInteger)level;

- (void)setupWithTitle:(NSString *)title
				 level:(NSInteger)level
		   numChildren:(NSUInteger)numChildren;

@end
