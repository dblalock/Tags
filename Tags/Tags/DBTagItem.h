//
//  DBTagItem.h
//  Tags
//
//  Created by DB on 1/27/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTableItem.h"

#import "NSObject+RMArchivable.h"	// automatically does encode/decode

@class Tag;
@class Typ;

@interface DBTagItem : DBTableItem
@property(strong, nonatomic) Tag* tag;

//-(instancetype)initWithName:(NSString *)name children:(NSArray *)array NS_UNAVAILABLE;
-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithTag:(Tag*)tag parent:(DBTableItem*)parent NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithTyp:(Typ*)typ parent:(DBTableItem*)parent;
-(instancetype) initWithTag:(Tag*)tag;
-(instancetype) initWithTyp:(Typ*)typ;

@end
