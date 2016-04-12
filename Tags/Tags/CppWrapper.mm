//
//  CppWrapper.m
//  Tags
//
//  Created by DB on 4/6/16.
//  Copyright © 2016 D Blalock. All rights reserved.
//

#import "CppWrapper.h"

#include <vector>
//#include "Pattern.hpp"

#include "flock_batch.hpp"

using std::vector;

@interface CppWrapper () {
	BatchFlockLearner<double, 3, 512>* _learner;
}

@end

@implementation CppWrapper

- (instancetype)init {
	if (self = [super init]) {
		_learner = new BatchFlockLearner<double, 3, 512>();
	}
	return self;
}

- (void)dealloc {
	delete _learner;
}

//// TODO replace with real impl
//static inline void updateStartEndIdxs(vector<int>& startIdxs,
//									  vector<int>& endIdxs) {
//	startIdxs.clear();
//	endIdxs.clear();
//	
//	startIdxs.push_back(15);
//	endIdxs.push_back(50);
//	
//	startIdxs.push_back(60);
//	endIdxs.push_back(95);
//}

-(void) clearHistory {
	_learner->clear();
}

-(void) updateStartIdxs:(NSMutableArray*)startIdxs endIdxs:(NSMutableArray*)endIdxs
			 historyLen:(int)useHistoryLen Lmin:(double)Lmin Lmax:(double)Lmax {
	[startIdxs removeAllObjects];
	[endIdxs removeAllObjects];
	
	// get start and end idxs from cpp
//	vector<int> startIdxsVect;
//	vector<int> endIdxsVect;
//	updateStartEndIdxs(startIdxsVect, endIdxsVect);

	_learner->learn(useHistoryLen, Lmin, Lmax);
//	_learner->dummyLearn();
	vector<int64_t> startIdxsVect = _learner->getStartIdxs();
	vector<int64_t> endIdxsVect = _learner->getEndIdxs();
	
	for (int i = 0; i < startIdxsVect.size(); i++) {
		[startIdxs addObject:@(startIdxsVect[i])];
		[endIdxs addObject:@(endIdxsVect[i])];
//		NSLog(@"CppWrapper: start, end = %d, %d", startIdxsVect[i], endIdxsVect[i]);
	}
	
	
//	for (int i = 0;)
	
//	[startIdxs addObjectsFromArray:@[@(10), @(40)]];
//	[endIdxs addObjectsFromArray:@[@(30), @(80)]];
}

-(void) pushX:(int)x Y:(int)y Z:(int)z {
	// hacky conversion to gs; shouldn't be necessary, but good for debug
	_learner->push_back(0, x / 64.0);
	_learner->push_back(1, y / 64.0);
	_learner->push_back(2, z / 64.0);
}

@end
