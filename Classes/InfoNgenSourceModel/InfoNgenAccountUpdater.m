//
//  InfoNgenAccountUpdater.m
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "InfoNgenAccountUpdater.h"
#import "InfoNgenSearchClient.h"
#import "RssFeed.h"
#import <CoreData/CoreData.h>
#import "FeedItem.h"
#import "TouchXML.h"
#import "FeedAccount.h"
#import "FeedFetcher.h"
#import "ItemFilter.h"
#import "RssFeedItem.h"
#import "UrlUtils.h"
#import "InfoNgenLoginTicket.h"
#import "MarkupStripper.h"

@implementation InfoNgenAccountUpdater


- (BOOL) isAccountValid
{
	//NSLog(@"InfoNgenAccountUpdater.isAccountValid");
	
	if(_isAccountValid)
	{
		return YES;
	}
	NSLog(@"InfoNgenAccountUpdater.isAccountValid");
	InfoNgenLoginTicket * ticket=[[InfoNgenLoginTicket alloc] initWithAccount:self.account useCachedCookie:NO];
	
	if([ticket.ticket length]==0)
	{
		[ticket release];
		NSLog(@"No ticket found, therefore assume ticket is invalid...");
		_isAccountValid=NO;
		return NO;
	}
	else 
	{
		[ticket release];
		NSLog(@"Got non-null ticket from Infongen, assume account is valid...");
		_isAccountValid=YES;
		return YES;
	}
}

- (BOOL) updateFeedListWithContext:(NSManagedObjectContext*)moc
{
	BOOL updated=NO;
	// get all items from remote db
	
	// get all saved searches from local db
	NSMutableDictionary * map=[NSMutableDictionary new];
	
	AccountUpdatableFeedFetcher * feedFetcher=[[AccountUpdatableFeedFetcher alloc] init];
	
	feedFetcher.accountName=self.account.name;
	feedFetcher.managedObjectContext=moc;
	
	[feedFetcher performFetch];
	
	int feedCount=[feedFetcher count];
	
	for(int i=0;i<feedCount;i++)
	{
		RssFeed * feed=[feedFetcher itemAtIndex:i];
		[map setObject:feed forKey:[feed url]];
	}
	
	[feedFetcher release];
	feedFetcher=nil;
	
	
	//NSArray * existingFeeds=[self.account.feeds allObjects];
	//NSArray * existingFeeds=[[self.account feedFetcher] items];
	
	//for(RssFeed * feed in existingFeeds)
	//{
	//	[map setObject:feed forKey:[feed url]];
	//}
	
	InfoNgenSearchClient * client=[[InfoNgenSearchClient alloc] initWithServer:kDefaultInfoNgenServerURL account:self.account];
	
	NSMutableDictionary * imageCache=[[[UIApplication sharedApplication] delegate] feedImageCache];
	
	NSArray * feeds=[client getSavedSearchesForAccount:self.account imageCache:imageCache];
	
	[client release];
	
	FeedAccount * contextAccount=(FeedAccount *)[moc objectWithID:self.account.objectID];
	
	// for each item in remote list NOT in local, add to local
	
	// TODO: for each item in local list NOT in remote, delete from local
	
	for(id feed in feeds)
	{
		RssFeed * existingFeed=[map objectForKey:[feed url]];
		if(existingFeed==nil)
		{
			// add new one...
			RssFeed * newFeed= [NSEntityDescription insertNewObjectForEntityForName:@"RssFeed" inManagedObjectContext:moc];
			
			newFeed.name=[feed name];
			newFeed.feedType=[feed feedType];
			newFeed.feedCategory=[feed feedCategory];
			newFeed.url=[feed url];
			newFeed.image=[feed image];
			
			newFeed.account=contextAccount;
			
			[map setObject:newFeed forKey:[newFeed url]];
			
			updated=YES;
		}
		else 
		{
			if(![existingFeed.name isEqualToString:[feed name]])
			{
				existingFeed.name=[feed name];
				[existingFeed save];
				
				updated=YES;
			}
		}
	}
	
	[map release];
	
	// save object context
	NSError * error=nil;
	if(![moc save:&error])
	{
		if(error)
		{
			NSLog(@"Failed to save in InfoNgenAccountUpdater.updateFeedListWithContext: %@",[error userInfo]);
		}
	}
	
	return updated;
}

- (NSArray*) getMoreOldItems:(RssFeed *)feed maxItems:(int)maxItems;
{
	return [self getMostRecentItems:feed maxItems:maxItems];
}

- (NSArray*) getMostRecentItems:(RssFeed*)feed maxItems:(int)maxItems
{
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateStatus"
	 object:[NSString stringWithFormat:@"Updating \"%@\"...",feed.name]];

	// if feed was updated less than 5 minutes ago, dont update again...
	// we do this because updating lots of InfoNgen RSS feeds is very slow compared to twitter/facebook/googlereader,
	// and user many refresh those feeds more often...
	if(feed.lastUpdated) 
	{
		int delta=[feed.lastUpdated timeIntervalSinceNow];
		delta*=-1;
		NSLog(@"delta=%d",delta);
		
		if(delta <= (5 * 60))
		{
			NSLog(@"Feed was updated less than 5 minutes ago...");
			return nil;
		}
	}
	
	NSData * data = [feed getRssData];
	
	if(data==nil) return nil;
	
	CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
	
	if(xmlParser==nil) return nil;
	
	// Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
	NSArray * itemNodes = [xmlParser nodesForXPath:@"rss/channel/item" error:nil];
	
	if(itemNodes==nil || [itemNodes count]==0) return nil;
	
	NSMutableArray * results=[[[NSMutableArray alloc] init] autorelease];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[formatter setLocale:enUS];
	[enUS release];
	[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZ"];  
	
	// css wrapping items from infongen RSS service - this will be removed in next release,
	// but for now we need to remove it so text renders with proper font size in embedded browser, otherwise it is too small...
	NSString * cssPrefix=@"<div style='font-family: Arial, Helvetica, sans-serif; font-size: 13px; padding: 0 10px;'><div>";
	
	MarkupStripper * stripper=[[[MarkupStripper alloc] init] autorelease];
	
	
	// Loop through the resultNodes to access each items actual data
	for (CXMLElement *itemNode in itemNodes) 
	{
		TempFeedItem * tmp=[[TempFeedItem alloc] init];
		
		@try 
		{
			tmp.headline=[stripper stripMarkup:[itemNode elementValue:@"title"]];
			
			tmp.url=[itemNode elementValue:@"link"];
			
			tmp.date = [formatter dateFromString:[itemNode elementValue:@"pubDate"]]; /*e.g. @"Thu, 11 Sep 2008 12:34:12 GMT" */
			
			NSString * synopsis=[itemNode elementValue:@"description"];
			
			// strip off style applied in rss service...
			// <div style='font-family: Arial, Helvetica, sans-serif; font-size: 13px; padding: 0 10px;'><div>   </div></div>
			if([synopsis hasPrefix:cssPrefix])
			{
				synopsis=[synopsis substringFromIndex:[cssPrefix length]];
				
				if([synopsis hasSuffix:@"</div></div>"])
				{
					synopsis=[synopsis substringToIndex:([synopsis length] - 12)];
				}
			}
			
			tmp.origSynopsis=synopsis;
			
			tmp.origin=[UrlUtils hostFromUrl:tmp.url];
			
			tmp.originId=tmp.origin;
			tmp.originUrl=tmp.url;
			
			[results addObject:tmp];
		}
		@catch (NSException * e) 
		{
			NSLog(@"Error parsing item from feed: %@",[e description]);
		}
		@finally 
		{
			[tmp release];
		}
	}
	
	[formatter release];
	
	return results;
}

@end
