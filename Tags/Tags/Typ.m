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

#define DEFAULT_DEFAULT @(-1)
#define TYP_DEFAULT_MUTABLE	([MutableTyp typWithName:@"TypDefaultMutable" parents:nil default:@""])
#define TYP_DEFAULT	([Typ typWithName:@"TypDefault" parents:nil default:@""])
#define TYP_BOOL	([Typ typWithName:@"TypBool"])
#define TYP_RATING	([Typ typWithName:@"TypRating"])
#define TYP_COUNT	([Typ typWithName:@"TypCount"])
#define TYP_AMOUNT	([Typ typWithName:@"TypAmount"])
#define TYP_STRING	([Typ typWithName:@"TypString" parents:nil default:@""])

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
@property(strong, nonatomic) NSUUID* ID;
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
		_parents = [NSSet setWithArray:parents];
		
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
	NSMutableString* s = [[self getFullName] mutableCopy];
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

-(typ_id_t) getUniqueID {
	return self.ID.UUIDString;
}

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

// -------------------------------
// instantiation
// -------------------------------

-(TypInstance) new {
	id obj = [self getDefaultValue];
	if ([obj isKindOfClass:[NSMutableDictionary class]]) {
		obj[@"__typ__"] = self;
	}
	return obj;
}

// ================================================================
#pragma mark Basic Types
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

@end

// ================================================================
#pragma mark Testing
// ================================================================

void testTyp() {
	MutableTyp* exer = [MutableTyp typWithName:@"exercise"];
	TypInstance emptyExer = [exer new];
	NSLog(@"exer with no fields: %@", exer);
	NSLog(@"exer class: %@", NSStringFromClass([exer class]));
	[exer addField:@"name" typ:TYP_STRING];
	NSLog(@"exer with name field: %@", exer);
	
	NSLog(@"emptyExer: %@", emptyExer);
	
	TypInstance genericExer = [exer new];
	NSLog(@"genericExer, no name: %@", genericExer);
	genericExer[@"name"] = @"generic exercise";
	NSLog(@"genericExer, no name: %@", genericExer);
	
	Typ* male = [Typ typWithName:@"male"];
	Typ* bro = [Typ typWithName:@"bro" parents:@[male]];
	MutableTyp* lift = [MutableTyp typWithName:@"lift" parents:@[bro, exer]];
	
	NSLog(@"%@", lift);
	
	[lift addFields:@{@"reps": TYP_COUNT, @"failure": TYP_BOOL}];
	TypInstance squats = [lift new];
	squats[@"name"] = @"squats";
	squats[@"reps"] = @(2);
	
	NSLog(@"%@", squats);
	
	NSLog(@"new, unset rating: %@", [TYP_RATING new]);
}
