//
//  CppWrapper.h
//  Tags
//
//  Created by DB on 4/6/16.
//  Copyright © 2016 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CppWrapper : NSObject

//+ (void)storeStartEndIdxs(NSMutableArray* startIdxs, NSMutableArray* endIdxs);

//+(void) updateStartIdxs:(NSMutableArray*)startIdxs endIdxs:(NSMutableArray*)endIdxs;

-(void) clearHistory;

-(void) updateStartIdxs:(NSMutableArray*)startIdxs endIdxs:(NSMutableArray*)endIdxs
			 historyLen:(int)useHistoryLen Lmin:(double)Lmin Lmax:(double)Lmax;

-(void) pushX:(int)x Y:(int)y Z:(int)z;

@end
