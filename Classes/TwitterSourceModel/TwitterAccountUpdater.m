//
//  TwitterAccountModel.m
//  Untitled
//
//  Created by Robert Stewart on 11/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "TwitterAccountUpdater.h"
#import "Feed.h"
#import "RssFeed.h"
#import "FeedFetcher.h"
#import "FeedAccount.h"
#import <CoreData/CoreData.h>
#import "FeedItem.h"
#import "RssFeed.h"
#import "RssFeedItem.h"

@implementation TwitterAccountUpdater

- (id) initWithAccount:(FeedAccount*)account
{
	if([super initWithAccount:account])
	{
		client=[[TwitterClient alloc] init];
		self.iterations=[NSArray arrayWithObjects:[NSNumber numberWithInt:100],[NSNumber numberWithInt:500],nil];
	}
	return self;
}

- (NSArray*) remoteFeedList
{
	NSMutableArray * feeds=[[[NSMutableArray alloc] init] autorelease];
	
	TempFeed * feed;
	
	/*feed=[TempFeed new];
	feed.url=@"http://twitter.com/statuses/home_timeline.json";
	feed.name=@"Home Timeline";
	feed.feedType=@"01TwitterFeed";
	feed.feedCategory=@"_twitter_home";
	feed.image=[UIImage imageNamed:@"home_icon.png"];
	
	[feeds addObject:feed];
	
	[feed release];
	*/
	feed=[TempFeed new];
	
	feed.url=@"http://twitter.com/statuses/home_timeline.json";
	//feed.url=@"http://twitter.com/statuses/friends_timeline.json";
	feed.name=@"Twitter Timeline";
	feed.feedType=@"02TwitterFeed";
	[feed setSingleCategory:@"_twitter_home"];
	feed.image=[UIImage imageNamed:@"gray_twitter.png"];
	feed.imageName=@"gray_twitter.png";
	feed.highlightedImageName=@"green_twitter.png";
	
	[feeds addObject:feed];
	
	[feed release];
	
	feed=[TempFeed new];
	feed.url=@"http://twitter.com/favorites.json";
	feed.name=@"Favorites";
	feed.feedType=@"03TwitterFeed";
	[feed setSingleCategory:@"_twitter_favorites"];
	feed.image=[UIImage imageNamed:@"starred.png"];
	feed.imageName=@"starred.png";
	
	[feeds addObject:feed];
	
	[feed release];
	
	feed=[TempFeed new];
	feed.url=@"http://api.twitter.com/1/statuses/mentions.json";
	
	if([client.screenName length]>0)
	{
		feed.name=[NSString stringWithFormat:@"@%@",client.screenName];
	}
	else 
	{
		feed.name=@"Mentions";
	}

	feed.feedType=@"04TwitterFeed";
	 [feed setSingleCategory:@"_twitter_mentions"];
	feed.image=[UIImage imageNamed:@"person_icon.gif"];
	feed.imageName=@"person_icon.gif";
	
	[feeds addObject:feed];
	
	[feed release];
	
	feed=[TempFeed new];
	feed.url=@"http://twitter.com/direct_messages.json";
	feed.name=@"Direct Messages";
	feed.feedType=@"05TwitterFeed";
	[feed setSingleCategory:@"_twitter_direct"];
	feed.image=[UIImage imageNamed:@"letter_icon.gif"];
	feed.imageName=@"letter_icon.gif";
	
	[feeds addObject:feed];
	
	[feed release];
	
	NSArray * lists=[client getLists];
	
	NSLog(@"Got %d lists from twitter",[lists count]);
	
	int ordinal=6;
	
	for(NSDictionary * list in lists)
	{
		NSString * listName=[list objectForKey:@"name"];
		NSString * listId=[list objectForKey:@"id"];
		
		feed=[TempFeed new];
		
		feed.url=[NSString stringWithFormat:@"http://api.twitter.com/1/%@/lists/%@/statuses.json",[client screenName],listId];//[client getUrlForType:GoogleReaderFeedTypeTaggedItems tag:tag];
		feed.name=listName;
		
		if(ordinal<10)
		{
			feed.feedType=[NSString stringWithFormat:@"0%dTwitterFeed",ordinal];
		}
		else 
		{
			feed.feedType=[NSString stringWithFormat:@"%dTwitterFeed",ordinal];
		}
		
		[feed setSingleCategory:@"_twitter_list"];
		ordinal++;
		feed.image=[UIImage imageNamed:@"gray_folderclosed.png"];
		feed.imageName=@"gray_folderclosed.png";
		feed.highlightedImageName=@"green_folderopen.png";
		
		[feeds addObject:feed];
		
		[feed release];
	}
	
	return feeds;
}

- (BOOL) updateFeedListWithContext:(NSManagedObjectContext*)moc
{
	/*if(![self isAccountValid])
	{
		return NO;
	}*/
	
	BOOL updated=NO;
	
	NSMutableDictionary * map=[NSMutableDictionary new];
	
	AccountUpdatableFeedFetcher * feedFetcher=[[AccountUpdatableFeedFetcher alloc] init];
	
	feedFetcher.accountName=self.account.name;
	feedFetcher.managedObjectContext=moc;
	
	[feedFetcher performFetch];
	
	int feedCount=[feedFetcher count];
	
	NSLog(@"Got %d existing local feeds for account: %@",feedCount,self.account.name);
	
	for(int i=0;i<feedCount;i++)
	{
		RssFeed * feed=[feedFetcher itemAtIndex:i];
		[map setObject:feed forKey:[feed url]];
	}
	
	[feedFetcher release];
	feedFetcher=nil;
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateStatus"
	 object:@"Updating Twitter..."];
	
	NSArray * remoteFeeds=[self remoteFeedList];
	
	NSLog(@"Got %d remote feeds for account: %@",[remoteFeeds count],self.account.name);
	
	FeedAccount * contextAccount=(FeedAccount *)[moc objectWithID:self.account.objectID];
	
	NSMutableDictionary * remote_map=[NSMutableDictionary new];
	
	for(TempFeed * feed in remoteFeeds)
	{
		[remote_map setObject:feed forKey:[feed url]];
		
		RssFeed * existingFeed=[map objectForKey:[feed url]];
		
		if(existingFeed!=nil)
		{
			// see if name changed or feedType changed...
			if(![Feed haveSameProperties:existingFeed b:feed])
			{
				existingFeed.name=[feed name];
				existingFeed.image=[feed image];
				existingFeed.imageName=[feed imageName];
				existingFeed.highlightedImageName=[feed highlightedImageName];
				
				existingFeed.htmlUrl=[feed htmlUrl];
				existingFeed.feedId=[feed feedId];
				existingFeed.feedType=[feed feedType];
				[existingFeed setFeedCategories:[feed feedCategory]];
				
				[existingFeed save];
				
				updated=YES;
			}
		}
		else 
		{
			NSLog(@"Adding new feed: %@",[feed name]);
			
			// add new one...
			RssFeed * newFeed= [NSEntityDescription insertNewObjectForEntityForName:@"RssFeed" inManagedObjectContext:moc];
			
			newFeed.name=[feed name];
			newFeed.feedType=[feed feedType];
			[newFeed setFeedCategories:[feed feedCategory]];
			
			newFeed.url=[feed url];
			newFeed.image=[feed image];
			newFeed.imageName=[feed imageName];
			newFeed.highlightedImageName=[feed highlightedImageName];
			
			newFeed.htmlUrl=[feed htmlUrl];
			newFeed.feedId=[feed feedId];
			
			newFeed.account=contextAccount;
			
			[map setObject:[newFeed url] forKey:[newFeed url]];
			
			updated=YES;
		}
	}
	
	for(NSString * url in [map allKeys])
	{
		if([remote_map objectForKey:url]==nil)
		{
			NSLog(@"Deleting feed that no longer exists remotely: %@",url);
			RssFeed * localFeed=[map objectForKey:url];
			[moc deleteObject:localFeed];
			updated=YES;
		}
	}
	
	[remote_map release];
	[map release];
	
	// save object context
	NSError * error=nil;
	if(![moc save:&error])
	{
		if(error)
		{
			NSLog(@"Failed to save in TwitterAccountUpdater.updateFeedListWithContext: %@",[error userInfo]);
		}
	}
	
	return updated;	
}

- (NSArray*) getMostRecentItems:(RssFeed*)feed maxItems:(int)maxItems
{
	NSLog(@"TwitterAccountUpdater.getMostRecentItems: %d",maxItems);
	
	if([feed isSingleCategory:@"_twitter_home"])
	{
		return [self getMostRecentHomeTimeline:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_friends"])
	{
		return [self getMostRecentFriendsTimeline:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_favorites"])
	{
		return [self getMostRecentFavorites:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_direct"])
	{
		return [self getMostRecentDirectMessages:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_list"])
	{
		return [self getMostRecentListItems:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_mentions"])
	{
		return [self getMostRecentMentions:feed maxItems:maxItems];
	}
	return nil;
}

- (NSArray*) getMoreOldItems:(RssFeed *)feed maxItems:(int)maxItems
{
	NSLog(@"TwitterAccountUpdater.getMoreOldItems: %d",maxItems);
	if([feed isSingleCategory:@"_twitter_home"])
	{
		return [self getMoreOldHomeTimeline:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_friends"])
	{
		return [self getMoreOldFriendsTimeline:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_favorites"])
	{
		return [self getMoreOldFavorites:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_direct"])
	{
		return [self getMoreOldDirectMessages:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_list"])
	{
		return [self getMoreOldListItems:feed maxItems:maxItems];
	}
	if([feed isSingleCategory:@"_twitter_mentions"])
	{
		return [self getMoreOldMentions:feed maxItems:maxItems];
	}
	return nil;
}



- (NSArray*) getMostRecentMentions:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMostRecentMentions:maxItems sinceId:[self getSinceIdForFeed:feed]];
}

- (NSArray*) getMostRecentListItems:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMostRecentListItemsByUrl:feed.url maxItems:maxItems sinceId:[self getSinceIdForFeed:feed]];
}

- (NSArray*) getMostRecentHomeTimeline:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMostRecentHomeTimeline:maxItems sinceId:[self getSinceIdForFeed:feed]];
}

- (NSArray*) getMostRecentFriendsTimeline:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMostRecentFriendsTimeline:maxItems sinceId:[self getSinceIdForFeed:feed]];
}

- (NSArray*) getMostRecentDirectMessages:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMostRecentDirectMessages:maxItems sinceId:[self getSinceIdForFeed:feed]];
}

- (NSArray*) getMostRecentFavorites:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMostRecentFavorites:maxItems sinceId:[self getSinceIdForFeed:feed]];
}


- (NSArray*) getMoreOldMentions:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMoreOldMentions:maxItems maxId:[self getMaxIdForFeed:feed]];
}

- (NSArray*) getMoreOldListItems:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMoreOldListItemsByUrl:feed.url maxItems:maxItems maxId:[self getMaxIdForFeed:feed]];
}

- (NSArray*) getMoreOldHomeTimeline:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMoreOldHomeTimeline:maxItems maxId:[self getMaxIdForFeed:feed]];
}

- (NSArray*) getMoreOldFriendsTimeline:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMoreOldFriendsTimeline:maxItems maxId:[self getMaxIdForFeed:feed]];
}

- (NSArray*) getMoreOldDirectMessages:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMoreOldDirectMessages:maxItems maxId:[self getMaxIdForFeed:feed]];
}

- (NSArray*) getMoreOldFavorites:(RssFeed*)feed maxItems:(int)maxItems
{
	return [client getMoreOldFavorites:maxItems maxId:[self getMaxIdForFeed:feed]];
}



- (NSString*) getMaxIdForFeed:(RssFeed*)feed
{
	NSLog(@"getMaxIdForFeed");
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];// autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"RssFeedItem" 
											  inManagedObjectContext:[feed managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setFetchBatchSize:0];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:
								@"feed == %@", feed]];
	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" 
																						   ascending:YES] autorelease]]];
	[fetchRequest setFetchLimit:1];
	
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"uid"]];
	
	NSArray * results=[[feed managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	
	if([results count]>0)
	{
		RssFeedItem * item=[results objectAtIndex:0];
		NSLog(@"Got maxId of %@ for feed: %@",item.uid,feed.url);
		return item.uid;
	}
	else 
	{
		NSLog(@"Failed to get maxId for feed: %@",feed.url);
		return nil;
	}
}

- (NSString*) getSinceIdForFeed:(RssFeed*)feed
{
	NSLog(@"getSinceIdForFeed");
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];// autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"RssFeedItem" 
											  inManagedObjectContext:[feed managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setFetchBatchSize:0];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:
									@"feed == %@", feed]];
		
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" 
																									  ascending:NO] autorelease]]];
	[fetchRequest setFetchLimit:1];
	
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"uid"]];
		
	NSArray * results=[[feed managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	
	if([results count]>0)
	{
		RssFeedItem * item=[results objectAtIndex:0];
		NSLog(@"Got sinceId of %@ for feed: %@",item.uid,feed.url);
		return item.uid;
	}
	else 
	{
		NSLog(@"Failed to get sinceId for feed: %@",feed.url);
		return nil;
	}
}

- (BOOL) isAccountValid
{
	return [client isAuthorized];
}

- (void) authorize
{
	if(![self isAccountValid])
	{
		NSLog(@"calling promptAuthorization");
		[client promptAuthorization];
		NSLog(@"done calling promptAuthorization");
	}
}

- (void) dealloc
{
	[client release];
	client=nil;
	[super dealloc];
}

@end
