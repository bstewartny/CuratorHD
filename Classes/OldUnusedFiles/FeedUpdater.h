//
//  FeedUpdater.h
//  Untitled
//
//  Created by Robert Stewart on 8/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FeedUpdater : NSObject {

}

- (void) updateAllFeedsAsync
{
	// get all feeds
	
	// for each feed put into operation queue
	
}

- (void) updateFeed:(Feed*)feed
{
	// get local fetcher
	FeedItemFetcher * localFetcher=[[FeedItemFetcher alloc] init];
	
	// get remote fetcher based on type
	
	// google account feed
	
	// google atom feed
	
	// infongen feed
	

}



- (void) updateFeed:(ItemFetcher*)localFetcher remoteFetcher:(ItemFetcher*)remoteFetcher;

@end
