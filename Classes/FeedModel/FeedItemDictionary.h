//
//  Favorites.h
//  Untitled
//
//  Created by Robert Stewart on 4/27/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"

@class FeedItem;

@interface FeedItemDictionary : NSObject <NSCoding>{
	NSMutableDictionary * map;
	NSMutableArray * array;
}

- (int) count;

- (BOOL) containsItem:(FeedItem*)item;

- (void) addItem:(FeedItem*)item;

- (void) removeItem:(FeedItem*)item;

- (void) removeItemAtIndex:(int)index;

- (FeedItem*) itemAtIndex:(int)index;

- (NSArray*) items;

- (void) removeAllItems;

- (ItemFetcher*) itemFetcher;

@end
