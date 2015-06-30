//
//  Tag.h
//  Tags
//
//  Created by DB on 1/27/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSObject+RMArchivable.h"	// automatically does encode/decode

@class Typ;

@interface Tag : NSObject
@property(strong, nonatomic) NSString* name;
@property(nonatomic, readonly) Typ* typ;
@property(nonatomic, readonly) NSArray* childTags;
@property(strong, nonatomic) NSString* identifier;
// // exactly one of these two will be non-nil
//@property(strong, nonatomic, readonly) NSDictionary* dict;
@property(strong, nonatomic) id value;

-(instancetype) init NS_UNAVAILABLE;
-(instancetype) initWithTyp:(Typ*)typ;
-(instancetype) initWithTyp:(Typ*)typ value:(id)val NS_DESIGNATED_INITIALIZER;
-(void) forceValue:(id) value;
-(NSArray*) childTags;
-(id) toDictOrValue;

@end
