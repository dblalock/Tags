//
//  Typ.m
//  Tags
//
//  Created by DB on 1/21/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import "Typ.h"

static NSString *const kKeyType = @"__type__";
static NSString *const kReservedPrefixAndSuffixChar = @"_";
static NSString *const kSubtypeSeparator = @".";
static NSString *const kSubtypeSeparatorReplacement = @";";

//static Typ * kStr = [[Typ alloc] initWithName:@"String"];

#define DEFAULT_DEFAULT @(-1)
#define TYP_BOOL   ([Typ typWithName:@"TypBool"])
#define TYP_STRING ([Typ typWithName:@"TypString" parents:nil default:@""])
#define TYP_RATING ([Typ typWithName:@"TypRating"])
#define TYP_COUNT  ([Typ typWithName:@"TypCount"])

// no, this is crappy cuz we want default values, and maybe
// other attributes later
//static NSString *const kTypNameString = @"TypString";
//static NSString *const kTypNameNumber = @"TypNumber";
//static NSString *const kTypNameBool = @"TypBool";

// ================================================================
#pragma mark Properties
// ================================================================
@interface Typ ()
@property(strong, nonatomic) NSSet* parents;
//@property(strong, nonatomic) NSUUID* ID;
@property(strong, nonatomic) NSMutableDictionary* fields;
@end

@implementation Typ

// ================================================================
#pragma mark Initialization
// ================================================================

// -------------------------------
// static
// -------------------------------

+ (instancetype) typWithName:(NSString*)name
					 parents:(NSArray*)parents
					 default:(id)defaultVal {
	return [[Typ alloc] initWithName:name parents:parents default:defaultVal];
}

+ (instancetype) typWithName:(NSString*)name
					 parents:(NSArray*)parents {
	return [[Typ alloc] initWithName:name parents:parents];
}

+ (instancetype) typWithName:(NSString*)name {
		return [[Typ alloc] initWithName:name];
}

// -------------------------------
// instance
// -------------------------------

- (instancetype)initWithName:(NSString*)name
					 parents:(NSSet*)parents
					 default:(id)defaultVal {
	self = [super init];
	if (self) {
		_name = name;
		_defaultVal = defaultVal;
//		_ID = [[NSUUID alloc] init];
		_fields = [NSMutableDictionary dictionary];
		
		// freak out if parents aren't also types
		for (id p in parents) {
			assert([p isMemberOfClass:[Typ class]]);
		}
		_parents = parents;
		
		// make sure default value isn't nil, cuz that can't
		// go in an nsdictionary
		if (_defaultVal == nil) {
			_defaultVal = DEFAULT_DEFAULT;
		}
	}
	return self;
}

- (instancetype)initWithName:(NSString*)name
					 parents:(NSArray*)parents {
	return [self initWithName:name parents:parents default:nil];
}

- (instancetype)initWithName:(NSString*)name {
	return [self initWithName:name parents:nil];
}

// ================================================================
#pragma mark Built-ins
// ================================================================

-(BOOL) isEqual:(id)object {
	if (! [object isMemberOfClass:[self class]]) return NO;
	return [object getFullName] == [self getFullName];
}

-(NSUInteger) hash {
	return [[self getFullName] hash];
}

-(NSString*) description {
	NSMutableString* s = [[self getFullName] mutableCopy];
	//	NSMutableString* s = [self.name mutableCopy];
	//	if ([self.parents count]) {
	//		[s appendFormat:@"%@", [[self.parents allObjects] componentsJoinedByString:@", "]];
	//	}
	NSDictionary* allFields = [self getAllFields];
	if ([allFields count]) {
		NSString* fieldsStr = [[allFields allKeys] componentsJoinedByString:@", "];
		[s appendFormat:@" [%@]", fieldsStr];
	}
	return s;
}

// ================================================================
#pragma mark Public funcs
// ================================================================

//-(NSSet*) getAllParents {
//	NSMutableSet* allParents = [NSMutableSet set];
//	if ([self.parents count]) {
//		for (Typ* p in self.parents) {
//			[allParents unionSet:[p getAllParents]];
//		}
//	}
//	[allParents unionSet:self.parents];
//	return allParents;
//}

-(NSString*) getFullName {
	if (! [self.parents count]) return self.name;
	
	NSMutableArray* parentNames = [NSMutableArray array];
	for (Typ* p in self.parents) {
		[parentNames addObject:[p getFullName]];
	}
	NSArray* sortedNames = [parentNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSString* sortedStr = [sortedNames componentsJoinedByString:@", "];
	if ([sortedNames count] > 1) {
		return [NSString stringWithFormat:@"{%@}%@%@",
				sortedStr, kSubtypeSeparator, self.name];
	}
	return [NSString stringWithFormat:@"%@%@%@",
			sortedStr, kSubtypeSeparator, self.name];
}

-(NSDictionary*) getAllFields {
	NSMutableDictionary* allFields = [NSMutableDictionary dictionary];
	if ([self.parents count]) {
		for (Typ* p in self.parents) {
			[allFields addEntriesFromDictionary:[p getAllFields]];
		}
	}
	[allFields addEntriesFromDictionary:self.fields];
	return allFields;
}

-(id) getDefaultValue {
	NSMutableDictionary* fields = [[self getAllFields] mutableCopy];
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	if ([fields count]) {
		for (field_name_t name in [fields allKeys]) {
			Typ* typ = fields[name];
			defaults[name] = [typ getDefaultValue];
		}
		return defaults;
	}
	return self.defaultVal;
}

-(void) addField:(field_name_t)name typ:(Typ*)typ {
	if ([typ isEqual:self]) return;		//recursion bad
	if ([name hasPrefix:kReservedPrefixAndSuffixChar]) {
		NSLog(@"Field names cannot begin with %@. Removing them.",
			  kReservedPrefixAndSuffixChar);
		name = [name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:kReservedPrefixAndSuffixChar]];
	}
	if ([name containsString:kSubtypeSeparator]) {
		NSLog(@"Field names cannot begin with %@. Removing them.", kSubtypeSeparator);
		name = [name stringByReplacingOccurrencesOfString:kSubtypeSeparator withString:kSubtypeSeparatorReplacement];
	}
	self.fields[name] = typ;
}

-(void) addFields:(NSDictionary*)names2types {
	for (field_name_t name in [names2types allKeys]) {
		[self addField:name typ:names2types[name]];
	}
}

// -------------------------------
// instantiation
// -------------------------------

-(instance_t) new {
	id obj = [self getDefaultValue];
	if ([obj isKindOfClass:[NSMutableDictionary class]]) {
		obj[@"__typ__"] = self;
	}
	return obj;
}

@end

//TYP_NUMBER = Typ*

// ================================================================
#pragma mark Testing
// ================================================================

void testTyp() {
	Typ* exer = [Typ typWithName:@"exercise"];
	instance_t emptyExer = [exer new];
	NSLog(@"exer with no fields: %@", exer);
	[exer addField:@"name" typ:TYP_STRING];
	NSLog(@"exer with name field: %@", exer);
	
	NSLog(@"emptyExer: %@", emptyExer);
	
	instance_t genericExer = [exer new];
	NSLog(@"genericExer, no name: %@", genericExer);
	genericExer[@"name"] = @"generic exercise";
	NSLog(@"genericExer, no name: %@", genericExer);
	
	Typ* male = [Typ typWithName:@"male"];
	Typ* bro = [Typ typWithName:@"bro" parents:@[male]];
	Typ* lift = [Typ typWithName:@"lift" parents:@[bro, exer]];
	
	NSLog(@"%@", lift);
	
	[lift addFields:@{@"reps": TYP_COUNT, @"failure": TYP_BOOL}];
	instance_t squats = [lift new];
	squats[@"name"] = @"squats";
	squats[@"reps"] = @(2);
	
	NSLog(@"%@", squats);
	
	NSLog(@"new, unset rating: %@", [TYP_RATING new]);
}
