//
//  DBTagCell.h
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTreeCell.h"

@class Tag;

@interface DBTagCell : DBTreeCell
@property(weak, nonatomic) Tag* tagObj;
@property(nonatomic) NSUInteger treeLvl;
@end
