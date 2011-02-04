//
//  CoreDataFeed.m
//  Untitled
//
//  Created by Robert Stewart on 8/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FeedEx.h"
#import "ItemFilter.h"
#import "ItemFetcher.h"
#import "FeedItemFetcher.h"

@implementation FeedEx

- (void) updateWithFilter:(ItemFilter*)filter;

- (void) update;

- (void) addItems:(NSArray*)newItems withFilter:(ItemFilter*)filter;

- (void) resolveFeedImages:(NSMutableDictionary*)imageCache;

- (int) unreadCount;

- (NSArray*) getNewItems;

- (ItemFetcher*) itemFetcher
{
	FeedItemFetcher * fetcher=[[FeedItemFetcher alloc] init];
	
	fetcher.feedName=self.name;
	fetcher.feedUrl=self.url;
	
	return [fetcher autorelease];
}

@end
