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

#define DEFAULT_DEFAULT @(NAN)	// it is *really* important that this != nil
#define TYP_DEFAULT_MUTABLE	([MutableTyp typWithName:@"TypDefaultMutable" parents:nil default:@""])
#define TYP_DEFAULT	([Typ typWithName:@"TypDefault" parents:nil default:@""])
#define TYP_BOOL	([Typ typWithName:@"TypBool"])
#define TYP_RATING	([Typ typWithName:@"TypRating"])
#define TYP_COUNT	([Typ typWithName:@"TypCount"])
#define TYP_AMOUNT	([Typ typWithName:@"TypAmount"])
#define TYP_TIME	([Typ typWithName:@"TypTime"])
#define TYP_DATETIME ([Typ typWithName:@"TypDatetime"])
#define TYP_STRING	([Typ typWithName:@"TypString" parents:nil default:@""])


// no, this is crappy cuz we want default values, and maybe
// other attributes later
//static NSString *const kTypNameString = @"TypString";
//static NSString *const kTypNameNumber = @"TypNumber";
//static NSString *const kTypNameBool = @"TypBool";

// ================================================================
#pragma mark Utility funcs
// ================================================================

NSArray* sortTyps(NSArray* typs) {
	return [typs sortedArrayUsingComparator:^NSComparisonResult(Typ* p1, Typ* p2) {
		return [p1.name compare:p2.name];
	}];
}

// ================================================================
#pragma mark Properties
// ================================================================
@interface Typ ()
@property(strong, nonatomic) NSArray* parents;
@property(strong, nonatomic) NSUUID* ID;
@property(strong, nonatomic) NSMutableDictionary* fields;
@property(strong, nonatomic, readonly) id defaultVal;
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
	// using self instead of the class name makes this automatically
	// work for subclasses
	return [[self alloc] initWithName:name parents:parents default:defaultVal];
}

+ (instancetype) typWithName:(NSString*)name
					 parents:(NSArray*)parents {
	return [[self alloc] initWithName:name parents:parents];
}

+ (instancetype) typWithName:(NSString*)name {
		return [[self alloc] initWithName:name];
}

// -------------------------------
// instance
// -------------------------------

- (instancetype)initWithName:(NSString*)name
					 parents:(NSArray*)parents
					 default:(id)defaultVal {
	self = [super init];
	if (self) {
		_name = name;
		_defaultVal = defaultVal;
		_ID = [[NSUUID alloc] init];
		_fields = [NSMutableDictionary dictionary];

		// freak out if parents aren't also types
		for (id p in parents) {
			assert([p isKindOfClass:[Typ class]]);
		}
		_parents = sortTyps([[NSSet setWithArray:parents] allObjects]);

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
	return [self.ID.UUIDString isEqualToString: ((Typ*)object).ID.UUIDString];
}

-(NSUInteger) hash {
	return [self.ID.UUIDString hash];
}

-(NSString*) description {
	NSMutableString* s = [[self fullName] mutableCopy];
	NSDictionary* allFields = [self allFields];
	if ([allFields count]) {
		NSString* fieldsStr = [[allFields allKeys] componentsJoinedByString:@", "];
		[s appendFormat:@" [%@]", fieldsStr];
	}
	return s;
}

// ================================================================
#pragma mark Public funcs
// ================================================================

-(NSArray*) allParents {
	NSMutableArray* allParents = [NSMutableArray array];
	if ([self.parents count]) {
		for (Typ* p in self.parents) {
			for (Typ* grandP in [p allParents]) {
				if (! [allParents containsObject:grandP]) {
					[allParents addObject:grandP];
				}
			}
		}
	}
	for (Typ* p in self.parents) {
		if (![allParents containsObject:p]) {
			[allParents addObject:p];
		}
	}
	return sortTyps(allParents);
}

-(typ_id_t) uniqueID {
	return self.ID.UUIDString;
}

-(NSString*) uniqueIDString {
	return self.ID.UUIDString;
}

-(NSString*) fullName {
	if (! [self.parents count]) return self.name;

	NSMutableArray* parentNames = [NSMutableArray array];
	for (Typ* p in self.parents) {
		[parentNames addObject:[p fullName]];
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

-(NSDictionary*) allFields {
	NSMutableDictionary* allFields = [NSMutableDictionary dictionary];
	if ([self.parents count]) {
		for (Typ* p in self.parents) {
			[allFields addEntriesFromDictionary:[p allFields]];
		}
	}
	[allFields addEntriesFromDictionary:self.fields];
	return allFields;
}

-(id) defaultValue {
	NSMutableDictionary* fields = [[self allFields] mutableCopy];
	NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
	if ([fields count]) {
		for (field_name_t name in [fields allKeys]) {
			Typ* typ = fields[name];
			defaults[name] = [typ defaultValue];
		}
		return defaults;
	}
	return self.defaultVal;
}

-(NSArray*) allParentNames {
	NSMutableArray* names = [NSMutableArray array];
	for (Typ* p in [self allParents]) {
		[names addObject:p.name];
	}
	return names;
}

-(NSString*) toLabelStr {
	NSArray* allNames = [[self allParentNames] arrayByAddingObject:self.name];
	return [allNames componentsJoinedByString:@" | "];
}

-(BOOL) isMutable {
	return NO;
}

-(BOOL) isMemberOfTyp:(Typ*)typ {
	return [self isEqual:typ];
}

-(BOOL) isKindOfTyp:(Typ*)typ {
	if ([self isMemberOfTyp:typ]) return YES;
	
	for (Typ* p in [self allParents]) {
		if ([p isEqual:typ]) {
			return YES;
		}
	}
	return NO;
}

// -------------------------------
// instantiation
// -------------------------------

// so what makes this tricky is that some typs have values that
// are other complex typs, and others have values that are just
// constants. This makes life bad.

-(id) newInstance {
	id obj = [self defaultValue];
	if ([obj isKindOfClass:[NSMutableDictionary class]]) {
		obj[kKeyTyp] = self;
	}
	return obj;
}

// ================================================================
#pragma mark Basic typs
// ================================================================

+(Typ*) typDefaultMutable {
	static Typ* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = TYP_DEFAULT_MUTABLE;
	});
	return sharedInstance;
}

+(Typ*) typDefault {
	static Typ* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = TYP_DEFAULT;
	});
	return sharedInstance;
}

+(Typ*) typBool {
	static Typ* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = TYP_BOOL;
	});
	return sharedInstance;
}
+(Typ*) typRating {
	static Typ* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = TYP_RATING;
	});
	return sharedInstance;
}
+(Typ*) typCount {
	static Typ* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = TYP_COUNT;
	});
	return sharedInstance;
}
+(Typ*) typAmount {
	static Typ* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = TYP_AMOUNT;
	});
	return sharedInstance;
}
+(Typ*) typTime {
	static Typ* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = TYP_TIME;
	});
	return sharedInstance;
}
+(Typ*) typDatetime {
	static Typ* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = TYP_DATETIME;
	});
	return sharedInstance;
}
+(Typ*) typString {
	static Typ* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = TYP_STRING;
	});
	return sharedInstance;
}

+(NSArray*) getBasicTyps {
	return @[[self typDefault],
			 [self typBool],
			 [self typRating],
			 [self typCount],
			 [self typAmount],
			 [self typString],
			 ];
}

// ================================================================
#pragma mark Other typs
// ================================================================

//+(Typ*) typStartDateTime {
//	static Typ* sharedInstance = nil;
//	static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
//		sharedInstance = [[Typ alloc] initWithName:@"Start" parents:@[[Typ typDatetime]]];
//	});
//	return sharedInstance;
//}
+(Typ*) typDatetimeRange {
	static MutableTyp* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [MutableTyp typWithName:@"Time Range"];
		[sharedInstance addField:kStartTimeFieldName typ:[Typ typDatetime]];
		[sharedInstance addField:kEndTimeFieldName typ:[Typ typDatetime]];
	});
	return sharedInstance;
}

@end

// ================================================================
#pragma mark MutableTyp
// ================================================================

@implementation MutableTyp

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

-(void) removeField:(field_name_t)name {
	[self.fields removeObjectForKey:name];
}

-(void) removeFields:(NSSet *)names {
	for (field_name_t name in names) {
		[self removeField:name];
	}
}

-(BOOL) isMutable {
	return YES;
}

@end

// ================================================================
#pragma mark Testing
// ================================================================

void testTyp() {
	MutableTyp* exer = [MutableTyp typWithName:@"exercise"];
	TypInstance emptyExer = [exer newInstance];
	NSLog(@"exer with no fields: %@", exer);
	NSLog(@"exer class: %@", NSStringFromClass([exer class]));
	[exer addField:@"name" typ:TYP_STRING];
	NSLog(@"exer with name field: %@", exer);

	NSLog(@"emptyExer: %@", emptyExer);

	TypInstance genericExer = [exer newInstance];
	NSLog(@"genericExer, no name: %@", genericExer);
	genericExer[@"name"] = @"generic exercise";
	NSLog(@"genericExer, no name: %@", genericExer);

	Typ* male = [Typ typWithName:@"male"];
	Typ* bro = [Typ typWithName:@"bro" parents:@[male]];
	MutableTyp* lift = [MutableTyp typWithName:@"lift" parents:@[bro, exer]];

	NSLog(@"%@", lift);

	[lift addFields:@{@"reps": TYP_COUNT, @"failure": TYP_BOOL}];
	TypInstance squats = [lift newInstance];
	squats[@"name"] = @"squats";
	squats[@"reps"] = @(2);

	NSLog(@"%@", squats);

	NSLog(@"new, unset rating: %@", [TYP_RATING newInstance]);
}
