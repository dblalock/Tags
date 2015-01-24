//
//  DBAddNewItem.m
//  Tags
//
//  Created by DB on 1/23/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "DBTreeItemAddNew.h"

@implementation DBTreeItemAddNew

+(instancetype) item {
	return [[self alloc] initWithName:nil children:nil];
}

-(instancetype)initWithName:(NSString *)name children:(NSArray *)array {
	return [super initWithName:nil children:nil];
}

@end
