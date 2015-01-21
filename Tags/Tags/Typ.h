//
//  Typ.h
//  Tags
//
//  Created by DB on 1/21/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* field_name_t;
typedef NSMutableDictionary* instance_t;

@interface Typ : NSObject

@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) id defaultVal;

// ================================================================
#pragma mark Initialization
// ================================================================

+ (instancetype) typWithName:(NSString*)name
					 parents:(NSArray*)parents
					 default:(id)defaultVal;

+ (instancetype) typWithName:(NSString*)name
					 parents:(NSArray*)parents;

+ (instancetype) typWithName:(NSString*)name;

- (instancetype)initWithName:(NSString*)name
					 parents:(NSArray*)parents
					 default:(id)defaultVal NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithName:(NSString*)name
					 parents:(NSArray*)parents;

- (instancetype)initWithName:(NSString*)name;

// ================================================================
#pragma mark Other methods
// ================================================================

-(id) getDefaultValue;
-(NSDictionary*) getAllFields;
-(NSString*) getFullName;

-(void) addFields:(NSDictionary*)names2types;
-(void) addField:(field_name_t)name typ:(Typ*)typ;

@end

void testTyp();
