//
//  Typ.h
//  Tags
//
//  Created by DB on 1/21/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* field_name_t;
typedef NSMutableDictionary* TypInstance;
typedef NSString* typ_id_t;

@interface Typ : NSObject

@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic, readonly) id defaultVal;
@property(nonatomic, readonly, getter=isMutable) BOOL mutable;

// ================================================================
#pragma mark Basic types
// ================================================================

+(Typ*) typDefault;		// |2|, but acts as a label
+(Typ*) typBool;		// |2|
+(Typ*) typRating;		// |6|
+(Typ*) typCount;		// Z
+(Typ*) typAmount;		// R
+(Typ*) typString;		// Alphabet
+(NSArray*) getBasicTyps;

+(Typ*) typDefaultMutable;	// actually used for labeling stuff

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

- (instancetype) init NS_UNAVAILABLE;

// ================================================================
#pragma mark Other methods
// ================================================================

-(BOOL) isMutable;
-(typ_id_t) getUniqueID;
-(id) getDefaultValue;
-(NSDictionary*) getAllFields;
-(NSString*) getFullName;

@end

// ================================================================
#pragma mark MutableTyp
// ================================================================

@interface MutableTyp : Typ

-(void) addField:(field_name_t)name typ:(Typ*)typ;
-(void) addFields:(NSDictionary*)names2types;
-(void) removeField:(field_name_t)name;
-(void) removeFields:(NSSet *)names;

@end

void testTyp();
