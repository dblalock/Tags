//
//  DBTableItem.h
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBTableItem : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *children;

+(id) itemWithName:(NSString *)name children:(NSArray *)children;

-(instancetype) init NS_UNAVAILABLE;
-(instancetype) initWithName:(NSString *)name children:(NSArray *)array NS_DESIGNATED_INITIALIZER;

-(void) addChild:(DBTableItem*)child;
-(void) removeChild:(DBTableItem*)child;

@end
