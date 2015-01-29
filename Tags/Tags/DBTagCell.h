//
//  DBTagCell.h
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTreeCell.h"

@class Tag;
@class DBTagItem;

@interface DBTagCell : DBTreeCell
@property(weak, nonatomic) Tag* tagObj;
@property(weak, nonatomic) DBTagItem* tagItm;
	// TODO replace model ptr with protocol or delegate
@end
