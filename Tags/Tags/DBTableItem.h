//
//  DBTableItem.h
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

// TODO I keep having to disallow the designated initializer within subclasses,
// so this really needs to get split into a DBTableItem protocol and a
// DBBasicTableItem class; violating liskov substition principle bad.
//	-actually, I really just need

#import <Foundation/Foundation.h>

#import "NSObject+RMArchivable.h"	// automatically does encode/decode

@interface DBTableItem : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) DBTableItem *parent;
@property (strong, nonatomic) NSMutableArray *children;	// protected--use accessors!

//+(id) itemWithName:(NSString *)name children:(NSArray *)children;
//+(void) joinParent:(DBTableItem*)parent toChild:(DBTableItem*)child;

//-(instancetype) init;
//-(instancetype) initWithName:(NSString *)name children:(NSArray *)array NS_DESIGNATED_INITIALIZER;

-(void) addChild:(DBTableItem*)child;
-(void) removeChild:(DBTableItem*)child;

+(NSString*) reuseIdentifier;
-(NSString*) reuseIdentifier; // for polymorphism with heterogenous subclasses

@end
