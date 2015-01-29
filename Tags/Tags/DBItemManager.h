//
//  DBItemManager.h
//  Tags
//
//  Created by DB on 1/28/15.
//  Copyright (c) 2015 D Blalock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Typ;
@class DBTagItem;

@interface DBItemManager : NSObject

Class classForTyp(Typ* typ);
DBTagItem* createTagItemForTypWithParent(Typ* typ, DBTagItem* parent);
DBTagItem* createTagItemForTyp(Typ* typ);

@end
