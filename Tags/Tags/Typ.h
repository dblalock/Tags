//
//  Typ.h
//  Tags
//
//  Created by DB on 1/21/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSObject+RMArchivable.h"	// automatically does encode/decode

// ================================================================
// Typedefs
// ================================================================

typedef NSString* field_name_t;
//typedef NSMutableDictionary* TypInstance;
typedef id TypInstance;
typedef NSString* typ_id_t;

// ================================================================
// Constants
// ================================================================

static NSString *const kKeyTyp = @"__typ__";

static NSString *const kStartTimeFieldName = @"Start";
static NSString *const kEndTimeFieldName = @"End";

// ================================================================
#pragma mark Typ
// ================================================================

@interface Typ : NSObject

@property(strong, nonatomic) NSString* name;
//@property(nonatomic, readonly, getter=isMutable) BOOL mutable;

// ------------------------------------------------
#pragma mark Basic typs
// ------------------------------------------------
// default types not needed cuz we can just init our own wherever

//+(Typ*) typDefault;		// |2|, but acts as a label
+(Typ*) typBool;		// |2|
+(Typ*) typRating;		// |6|
+(Typ*) typCount;		// Z
+(Typ*) typAmount;		// R
+(Typ*) typTime;		// 24h
+(Typ*) typDatetime;	// whenever
+(Typ*) typString;		// Alphabet
+(NSArray*) getBasicTyps;

//+(Typ*) typDefaultMutable;	// actually used for labeling stuff

// ------------------------------------------------
#pragma mark Other built-in typs
// ------------------------------------------------

+(Typ*) typDatetimeRange;	//whenever to whenever

// ------------------------------------------------
#pragma mark Initialization
// ------------------------------------------------

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

// ------------------------------------------------
#pragma mark Other methods
// ------------------------------------------------

-(id) newInstance;

-(BOOL) isMemberOfTyp:(Typ*)typ;
-(BOOL) isKindOfTyp:(Typ*)typ;

-(typ_id_t) uniqueID;
-(NSString*) uniqueIDString;
-(id) defaultValue;
-(NSArray*) allParents;
-(NSDictionary*) allFields;
-(NSString*) fullName;

-(NSString*) toLabelStr;

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
