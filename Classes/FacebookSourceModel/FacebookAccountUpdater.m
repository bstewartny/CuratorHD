//
//  FacebookAccountUpdater.m
//  Untitled
//
//  Created by Robert Stewart on 11/29/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FacebookAccountUpdater.h"
 
#import "Feed.h"
#import "RssFeed.h"
#import "FeedFetcher.h"
#import "FeedAccount.h"
#import <CoreData/CoreData.h>
#import "FeedItem.h"
#import "RssFeed.h"
#import "RssFeedItem.h"

@implementation FacebookAccountUpdater

- (id) initWithAccount:(FeedAccount*)account
{
	if([super initWithAccount:account])
	{
		client=[[FacebookClient alloc] init];
		self.iterations=[NSArray arrayWithObjects:[NSNumber numberWithInt:100],[NSNumber numberWithInt:500],nil];
	}
	return self;
}

- (NSString*) encodeUrlParam:(NSString*)value
{
	NSString *encodedValue = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, NULL, CFSTR(":/?#[]@!$&’()*+,;=\""), kCFStringEncodingUTF8);
	return [encodedValue autorelease];
}

- (NSArray*) remoteFeedList:(NSManagedObjectContext*)moc
{
	NSMutableArray * feeds=[[[NSMutableArray alloc] init] autorelease];
	
	TempFeed * feed;
	
	feed=[TempFeed new];
	feed.url=@"me/feed?fields=id,from,message,name,description,picture,created_time,type,link";
	feed.feedId=@"facebook.feed";
	feed.name=@"Wall";
	feed.feedType=@"01FacebookFeed";
	 
	[feed setSingleCategory:@"_twitter_home"];
	feed.image=[UIImage imageNamed:@"person_icon.gif"];
	
	[feeds addObject:feed];
	
	[feed release];
	
	feed=[TempFeed new];
	feed.url=@"me/home?fields=id,from,message,name,description,picture,created_time,type,link";
	feed.feedId=@"facebook.home";
	feed.name=@"News feed";
	feed.feedType=@"02FacebookFeed";
	
	[feed setSingleCategory:@"_twitter_home"];
	feed.image=[UIImage imageNamed:@"shared.gif"];
	
	[feeds addObject:feed];
	
	[feed release];
	
	// links that friends have posted...
	//feed=[TempFeed new];
	/*
	NSString * link_query=@"select link_id,owner,owner_comment,created_time,title,summary,url,image_urls from link where owner=me() or owner in (select uid2 from friend where uid1=me()) order by created_time desc";

	NSString * user_query=@"select uid,name,pic_square from user where uid in (select owner from #links)";
	
	NSDictionary * query_dict=[NSDictionary dictionaryWithObjectsAndKeys:link_query,@"links",user_query,@"users"];
	
	NSString * query_dict_json=[query_dict JSONRepresentation];
	
	NSString * encoded_query=[self encodeUrlParam:query_dict_json];
	
	NSString * url=[NSString stringWithFormat:@"https://api.facebook.com/method/fql.multiquery?output=JSON&queries=%@",encoded_query];
	
	feed.url=url; //@"me/home?fields=id,from,message,name,description,picture,created_time,type,link";
	feed.feedId=@"facebook.links";
	feed.name=@"Links";
	feed.feedType=@"02FacebookFeed";
	feed.feedCategory=@"_twitter_home";
	feed.image=[UIImage imageNamed:@"shared.gif"];
	
	[feeds addObject:feed];
	
	[feed release];
	
	*/
	/*
	feed=[TempFeed new];
	feed.url=@"me/notes";
	feed.feedId=@"facebook.notes";
	feed.name=@"Notes";
	feed.feedType=@"03FacebookFeed";
	feed.feedCategory=@"_twitter_home";
	feed.image=[UIImage imageNamed:@"notes.png"];
	
	[feeds addObject:feed];
	
	[feed release];
	
	feed=[TempFeed new];
	feed.url=@"me/friends?fields=id,name,picture";
	feed.name=@"Friends";
	feed.feedId=@"facebook.friends";
	feed.feedType=@"04FacebookFeed";
	feed.feedCategory=@"_category";
	feed.image=[UIImage imageNamed:@"shared.gif"];
	
	[feeds addObject:feed];
	
	[feed release];
	*/
	// get friends...
	
	/*if([client isAuthorized])
	{
		 NSDictionary * json=[client.facebook getJsonWithGraphPath:@"me/friends?fields=id,name,picture" andDelegate:self];
							 
		 NSArray * friends = [json objectForKey:@"data"];
		 
		 for(NSDictionary * f in friends)
		 {		 
			 NSString * friend_id=[f objectForKey:@"id"];
			 NSString * name=[f objectForKey:@"name"];
			 NSString * picture_url=[f objectForKey:@"picture"];
			 
			 feed=[TempFeed new];
			 feed.url=[NSString stringWithFormat:@"%@/feed?fields=id,from,message,name,description,picture,created_time,type,link",friend_id];
			 feed.feedId=friend_id;
			 feed.name=name;
			 feed.feedType=@"facebook.friend";
			 feed.feedCategory=@"|Friends|";
			 feed.htmlUrl=picture_url;
			 //feed.image=[UIImage imageNamed:@"person_icon.gif"];
			 
			 [feeds addObject:feed];
			 
			 [feed release];
		 }
	}*/
	
	return feeds;
}

- (BOOL) updateFeedListWithContext:(NSManagedObjectContext*)moc
{
	if(![self isAccountValid])
	{
		return NO;
	}

	didUpdateFeedList=YES;
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
	 object:@"Updating Facebook..."];
	
	NSArray * remoteFeeds=[self remoteFeedList:moc];
	
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
			newFeed.htmlUrl=[feed htmlUrl];
			newFeed.feedId=[feed feedId];
			
			newFeed.account=contextAccount;
			
			if([newFeed.feedType isEqualToString:@"facebook.friend"])
			{
				NSString * picture_url=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",newFeed.feedId];
				
				UIImage * img=nil;
				
				if(feed.htmlUrl)
				{	
					// this is the direct picture id, try this first...
					newFeed.image=[[[UIApplication sharedApplication] delegate] getImageFromCache:picture_url usingUrl:feed.htmlUrl];
				}
				else 
				{
					newFeed.image=[[[UIApplication sharedApplication] delegate] getImageFromCache:picture_url];
				}
			}
			
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
	
	if(didUpdateFeedList)
	{
		// dont update friends during account update
		if([feed.feedType isEqualToString:@"facebook.friend"])
		{
			return nil;
		}
	}
	
	if([feed.feedId isEqualToString:@"facebook.links"])
	{
		
		return [client getLinkItems:maxItems url:feed.url];
	}
	else
	{
		return [client getMostRecentItems:maxItems maxTimestamp:[self getMaxTimestampForFeed:feed] graphPath:feed.url];
	}
}

- (NSArray*) getMoreOldItems:(RssFeed *)feed maxItems:(int)maxItems
{
	NSLog(@"TwitterAccountUpdater.getMoreOldItems: %d",maxItems);
	
	if(didUpdateFeedList)
	{
		// dont update friends during account update
		if([feed.feedType isEqualToString:@"facebook.friend"])
		{
			return nil;
		}
	}
	
	return [client getMoreOldItems:maxItems minTimestamp:[self getMinTimestampForFeed:feed] graphPath:feed.url];
}

- (NSString*) getMaxTimestampForFeed:(RssFeed*)feed
{
	NSLog(@"getMaxTimestampForFeed");
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"RssFeedItem" 
											  inManagedObjectContext:[feed managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setFetchBatchSize:0];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"feed == %@", feed]];
	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" 
																						   ascending:NO] autorelease]]];
	[fetchRequest setFetchLimit:1];
	
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"date"]];
	
	NSArray * results=[[feed managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	
	if([results count]>0)
	{
		RssFeedItem * item=[results objectAtIndex:0];
		
		long unix_time=(long)[item.date timeIntervalSince1970];
		
		NSString * unix_timestamp=[NSString stringWithFormat:@"%ld",unix_time];
		NSLog(@"Got max timestamp of %@ for feed: %@",unix_timestamp,feed.url);
		
		return unix_timestamp;
	}
	else 
	{
		NSLog(@"Failed to get max timestamp for feed: %@",feed.url);
		return nil;
	}
}

- (NSString*) getMinTimestampForFeed:(RssFeed*)feed
{
	NSLog(@"getMinTimestampForFeed");
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];// autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"RssFeedItem" 
											  inManagedObjectContext:[feed managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setFetchBatchSize:0];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"feed == %@", feed]];
	
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" 
																						   ascending:YES] autorelease]]];
	[fetchRequest setFetchLimit:1];
	
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"date"]];
	
	NSArray * results=[[feed managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	
	if([results count]>0)
	{
		RssFeedItem * item=[results objectAtIndex:0];
		
		long unix_time=(long)[item.date timeIntervalSince1970];
		
		NSString * unix_timestamp=[NSString stringWithFormat:@"%ld",unix_time];
		
		NSLog(@"Got min timestamp of %@ for feed: %@",unix_timestamp,feed.url);
		
		return unix_timestamp;
	}
	else 
	{
		NSLog(@"Failed to get min timestamp for feed: %@",feed.url);
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
