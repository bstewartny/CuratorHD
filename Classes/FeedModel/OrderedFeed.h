//
//  OrderedFeed.h
//  Untitled
//
//  Created by Robert Stewart on 8/6/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"

@interface OrderedFeed : Feed {

}
@property(nonatomic,retain) NSSet * items;
@property(nonatomic,retain) NSNumber * displayOrder;

- (NSArray*) sortedItems;
/*
- (NSArray*) itemsWithDisplayOrder:(int)value;
- (NSArray*) itemsWithDisplayOrderGreaterThanOrEqualTo:(int)value;
- (NSArray*) itemsWithDisplayOrderBetween:(int)lowValue and:(int)highValue;
- (int) renumberDisplayOrdersOfItems:(NSArray*)array startingAt:(int)value;

- (void)renumberDisplayOrders;
*/

@end
