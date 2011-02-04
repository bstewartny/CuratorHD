//
//  GoogleReaderSubscribedFeedsFeedGroup.m
//  Untitled
//
//  Created by Robert Stewart on 7/7/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "GoogleReaderSubscribedFeedsFeedGroup.h"
#import "ItemFilter.h"

@implementation GoogleReaderSubscribedFeedsFeedGroup



- (void) updateWithFilter:(ItemFilter*)filter
{
	NSLog(@"GoogleReaderSubscribedFeedsFeedGroup:updateWithFilter");
	// we dont want to update all subscribed feeds from the top level because it can be too slow to update all feeds...
	
	/*for (Feed * feed in feeds)
	{
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"UpdateStatus"
		 object:[NSString stringWithFormat:@"Updating \"%@\"...",feed.name]];
		[feed updateWithFilter:filter];
	}*/
}
@end
