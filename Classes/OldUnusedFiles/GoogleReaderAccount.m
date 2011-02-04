//
//  GoogleReaderAccount.m
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "GoogleReaderAccount.h"
#import "GoogleReaderClient.h"
#import "GoogleReaderFeed.h"
#import "GoogleReaderSubscribedFeedsFeedGroup.h"

@implementation GoogleReaderAccount
//@synthesize authToken;

- (BOOL) isValid
{
	NSLog(@"GoogleReaderAccount.isValid");
	
	GoogleReaderClient * google=[[GoogleReaderClient alloc] initWithAccount:self];
	
	BOOL valid=[google isValid];
	
	[google release];
	
	return valid;
}

- (NSArray*) feeds
{
	NSMutableArray * feeds=[[[NSMutableArray alloc] init] autorelease];
	
	GoogleReaderClient * google=[[GoogleReaderClient alloc] initWithAccount:self];
	
	if([google isValid])
	{
		// otherwise, we failed to authenticate google reader credentials...
		
		//GoogleReaderFeed * feed;
		
		TempFeed * feed;
		
		// get all subscribed feeds
		NSMutableDictionary * imageCache=[[[UIApplication sharedApplication] delegate] feedImageCache];
	
		// get all items
		
		feed=[TempFeed new];
		
		feed.url=[google getUrlForType:GoogleReaderFeedTypeAllItems tag:nil];
		
		//feed=[[GoogleReaderFeed alloc] initWithAccount:self type:GoogleReaderFeedTypeAllItems tag:nil];
		
		feed.name=@"All Items";
		//feed.image=[UIImage imageNamed:@"GoogleReader.png"];
		feed.image=[UIImage imageNamed:@"Google-32.png"];
		
		[feeds addObject:feed];
		
		[feed release];
		
		// get users shared items
		
		feed=[TempFeed new];
		feed.url=[google getUrlForType:GoogleReaderFeedTypeSharedItems tag:nil];
		//feed=[[GoogleReaderFeed alloc] initWithAccount:self type:GoogleReaderFeedTypeSharedItems tag:nil];
		
		feed.name=@"Shared Items";
		feed.image=[UIImage imageNamed:@"shared.gif"];
		
		[feeds addObject:feed];
		
		[feed release];
		
		// get users starred items
		
		//feed=[[GoogleReaderFeed alloc] initWithAccount:self type:GoogleReaderFeedTypeStarredItems tag:nil];
		feed=[TempFeed new];
		feed.url=[google getUrlForType:GoogleReaderFeedTypeStarredItems tag:nil];
		
		feed.name=@"Starred Items";
		feed.image=[UIImage imageNamed:@"starred.png"];
		
		[feeds addObject:feed];
		
		[feed release];
		
		// get following items
		//feed=[[GoogleReaderFeed alloc] initWithClient:google type:GoogleReaderFeedTypeFollowingItems tag:nil];
		
		//feed.name=@"Following";
		
		//[tmp addObject:feed];
		
		//[feed release];
		
		// get users tags/folders
		
		NSArray * tags=[google getTags];
		
		for(NSString * tag in tags)
		{
			//feed=[[GoogleReaderFeed alloc] initWithAccount:self type:GoogleReaderFeedTypeTaggedItems tag:tag];
			
			feed=[TempFeed new];
			feed.url=[google getUrlForType:GoogleReaderFeedTypeTaggedItems tag:tag];
			
			
			feed.name=tag;
			feed.image=[UIImage imageNamed:@"tag.gif"];
			[feeds addObject:feed];
			
			[feed release];
		}
		
		NSArray * subscribed_feeds=[google getSubscriptionList:imageCache];
		
		for(id * subscribed_feed in subscribed_feeds)
		{
			[feeds addObject:subscribed_feed];
		}
		
		[subscribed_feeds release];
	}
	
	[google release];
	
	return feeds;
	
	//for(Feed * feed in tmp)
	//{
	//	[feeds addObject:feed];
	//}
	
	//[tmp release];
}

- (void) markAsRead:(FeedItem*)item
{
	NSLog(@"GoogleReaderFeed.markAsRead");
	
	GoogleReaderClient * google=[[GoogleReaderClient alloc] initWithAccount:self];
	
	[google markAsRead:item];
	
	[google release];
}

-(void) dealloc
{
	//[authToken release];
	[super dealloc];
}

@end
