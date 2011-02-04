//
//  FeedUpdater.m
//  Untitled
//
//  Created by Robert Stewart on 8/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FeedUpdater.h"

@implementation FeedUpdater

- (void) updateFeed:(ItemFetcher*)localFetcher remoteFetcher:(ItemFetcher*)remoteFetcher
{
	// make copy of items for thread safety
	ItemFilter * filter=[[ItemFilter alloc] init];
	
	[localFetcher performFetch];
	
	NSArray * localItems=[localFetcher fetchedItems];
	
	for(FeedItem * item in localItems)
	{
		if ([filter isNewItem:item]) 
		{
			[filter rememberItem:item]
		}
	}
	
	[remoteFetcher performFetch];
	
	NSArray * remoteItems=[remoteFetcher fetchedItems];
	
	NSMutableArray * newItems=[NSMutableArray new];
	
	for(FeedItem * item in remoteItems)
	{
		if (![filter isNewItem:item]) 
		{
			continue;
		}
		else
		{
			[newItems addObject:item];
			[filter rememberItem:item];
		}
	}
	
	[filter release];
	
	// add new items
	[localFetcher addItems:newItems];
	
	[newItems release];
}

@end
