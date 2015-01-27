//
//  TypManager.h
//  Tags
//
//  Created by DB on 1/22/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Typ.h"

@interface TypManager : NSObject

// -so this class basically just needs to make sure that changes to types
// get persisted
// -it should probably also let you

@end

NSArray* defaultTypItems();
NSArray* getAllTypItems();
void saveTypItems(NSArray* typItems);
