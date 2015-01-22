//
//  DBTreeCell.h
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBTreeCell : UITableViewCell

//+(NSString*) reuseIdentifier;

- (void)setupWithTitle:(NSString *)title
				 level:(NSInteger)level;

@end
