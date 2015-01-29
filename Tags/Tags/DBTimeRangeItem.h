//
//  DBTimeRangeItem.h
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTagItem.h"

@interface DBTimeRangeItem : DBTagItem
@property(nonatomic) BOOL recording;

-(NSDateComponents*) duration;

@end
