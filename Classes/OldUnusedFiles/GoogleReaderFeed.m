//
//  GoogleReaderFeed.m
//  Untitled
//
//  Created by Robert Stewart on 5/20/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "GoogleReaderFeed.h"
#import "GoogleReaderClient.h"
#import "FeedAccount.h"
#import "FeedItem.h"

@implementation GoogleReaderFeed
@synthesize tag;

- (NSInteger) maxItems
{
	return 100;
}

- (id) initWithAccount:(FeedAccount*)account type:(GoogleReaderFeedType)readerFeedType tag:(NSString*)tagName
{
	if ([super initWithAccount:account]) 
	{
		self.tag=tagName;
		feedType=readerFeedType;
	}
	return self;
}

- (NSArray*) getNewItemsWithFilter:(ItemFilter*)filter
{
	GoogleReaderClient * client=[[GoogleReaderClient alloc] initWithAccount:self.account];
	NSArray * items= [client getItems:feedType tag:tag filter:filter];	
	[client release];
	return items;
}

- (void) resolveFeedImages:(NSMutableDictionary*)imageCache
{
	NSLog(@"resolveFeedImages");
	for(FeedItem * item in self.items)
	{
		if(item && item.originId && [item.originId length]>0)
		{
			UIImage * img=[imageCache objectForKey:item.originId];
			if(img==nil)
			{
				img=[GoogleReaderClient getFaviconForItem:item];
				
				if(img==nil)
				{
					img=[Feed getFeedImageForItem:item];
				}
				if(img)
				{
					NSLog(@"setting image in cache for originid: %@",item.originId);
					[imageCache setObject:img forKey:item.originId];
				}
			}
		}
	}
}

- (void) updateWithFilter:(ItemFilter*)filter;
{
	NSArray * newItems=[self getNewItemsWithFilter:filter];
	[self addItems:newItems withFilter:filter];
	
	[lastUpdated release];
	lastUpdated=[[NSDate alloc] init];
}

- (NSArray*) getNewItems
{
	return [self getNewItemWithFilter:nil];
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:tag forKey:@"tag"];
	[encoder encodeInt:(int)feedType forKey:@"feedType"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super initWithCoder:decoder])
	{
		self.tag=[decoder decodeObjectForKey:@"tag"];
		feedType=[decoder decodeIntForKey:@"feedType"];
	}
	return self;
}

- (void) dealloc
{
	[tag release];
	[super dealloc];
}
@end
