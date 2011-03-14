#import "GoogleAccountUpdater.h"
#import "FeedItem.h"
#import "Feed.h"
#import <CoreData/CoreData.h>
#import "ItemFilter.h"
#import "GoogleReaderClient.h"
#import "FeedAccount.h"
#import "RssFeed.h"
#import "RssFeedItem.h"
#import "TouchXML.h"
#import "FeedFetcher.h"
#import "MD5.h"
#import "Folder.h"
#import "FolderItem.h"
#import "JSON.h"
#import "MarkupStripper.h"
#import "UrlUtils.h"
#define kUseGoogleAppEngine NO

@implementation GoogleAccountUpdater

@synthesize client;

- (id) initWithAccount:(FeedAccount*)account
{
	if([super initWithAccount:account])
	{
		client=[[GoogleReaderClient alloc] initWithUsername:account.username password:account.password];
		readingListFeedCache=nil;
		self.iterations=[NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:20],nil];
	}
	return self;
}

- (void) willUpdateFeeds:(NSManagedObjectContext*)moc
{
	[self fillReadingListFeedCache:moc];
}

- (BOOL) isAccountValid
{
	//NSLog(@"GoogleAccountUpdater.isAccountValid");
	return ([client isValid]);
}

- (NSArray*) remoteFeedList
{
	NSMutableArray * feeds=[[[NSMutableArray alloc] init] autorelease];
	
	TempFeed * feed;
	
	// get all subscribed feeds
	NSMutableDictionary * imageCache=[[[UIApplication sharedApplication] delegate] feedImageCache];
	
	feed=[TempFeed new];
	feed.url=[client getUrlForType:GoogleReaderFeedTypeAllItems tag:nil];
	feed.name=@"All Google Reader Items";
	feed.feedType=@"01GoogleFeed";
	feed.feedCategory=@"_all";
	feed.image=[UIImage imageNamed:@"32-googlreader.png"];
	
	[feeds addObject:feed];
	
	[feed release];
	// get users starred items
	feed=[TempFeed new];
	feed.url=[client getUrlForType:GoogleReaderFeedTypeStarredItems tag:nil];
	feed.name=@"Starred Items";
	feed.feedType=@"02GoogleFeed";
	feed.feedCategory=@"_starred";
	feed.image=[UIImage imageNamed:@"28-star.png"];
	
	[feeds addObject:feed];
	
	[feed release];
	
	// get users shared items
	feed=[TempFeed new];
	feed.url=[client getUrlForType:GoogleReaderFeedTypeSharedItems tag:nil];
	feed.name=@"Your Shared Items";
	feed.feedType=@"03GoogleFeed";
	feed.feedCategory=@"_shared";
	feed.image=[UIImage imageNamed:@"yourshared.gif"];
	
	[feeds addObject:feed];
	
	[feed release];
	
	// get users notes (created items)
	feed=[TempFeed new];
	feed.url=[client getUrlForType:GoogleReaderFeedTypeNotes tag:nil];
	feed.name=@"Your Notes";
	feed.feedType=@"04GoogleFeed";
	feed.feedCategory=@"_notes";
	feed.image=[UIImage imageNamed:@"notes.png"];
	
	[feeds addObject:feed];
	
	[feed release];
	
	// get users friend's shared items
	feed=[TempFeed new];
	feed.url=[client getUrlForType:GoogleReaderFeedTypeFollowingItems tag:nil];
	feed.name=@"People You Follow";
	feed.feedType=@"05GoogleFeed";
	feed.feedCategory=@"_shared";
	feed.image=[UIImage imageNamed:@"shared.gif"];
	
	[feeds addObject:feed];
	
	[feed release];
	
	// get users tags/folders
	NSArray * tags=[client getTags];
	
	int ordinal=6;
	
	for(NSString * tag in tags)
	{
		feed=[TempFeed new];
		
		feed.url=[client getUrlForType:GoogleReaderFeedTypeTaggedItems tag:tag];
		feed.name=tag;
		if(ordinal<10)
		{
			feed.feedType=[NSString stringWithFormat:@"0%dGoogleFeed",ordinal];
		}
		else 
		{
			feed.feedType=[NSString stringWithFormat:@"%dGoogleFeed",ordinal];
		}

		feed.feedCategory=@"_category";
		ordinal++;
		feed.image=[UIImage imageNamed:@"32-folderclosed.png"];
	
		[feeds addObject:feed];
		
		[feed release];
		
		// add "all items"feed for this category
		
		feed=[TempFeed new];
		feed.url=[NSString stringWithFormat:@"category://%@",tag];//[client getUrlForType:GoogleReaderFeedTypeTaggedItems tag:tag];
		feed.name=[NSString stringWithFormat:@"All %@ Items",tag];
		feed.feedType=@"0"; // for sorting...
		feed.feedCategory=[NSString stringWithFormat:@"|%@|",tag];
		
		feed.image=[UIImage imageNamed:@"32-folderclosed.png"];
		
		[feeds addObject:feed];
		
		[feed release];
	}
	
	NSArray * subscribed_feeds=[client getSubscriptionList:imageCache];
	
	for(id * subscribed_feed in subscribed_feeds)
	{
		[feeds addObject:subscribed_feed];
	}
	
	[subscribed_feeds release];

	return feeds;
}

- (void) fillReadingListFeedCache:(NSManagedObjectContext*)moc
{	
	[readingListFeedCache release];
	
	readingListFeedCache=[[NSMutableDictionary alloc] init];
	// get reading list, put items into dictionary keyed by origin id (the feed id of each item)
	// this will then contain the most recent items from reading list organized by feed id
	// we will then use that as a temporary cache when fetching latest items by feed, as an optimization instead of reading each atom feed each time we update...
	
	TempFeed * readingListFeed=[[TempFeed alloc] init];
	
	readingListFeed.url=[client getUrlForType:GoogleReaderFeedTypeAllItems tag:nil];
	
	// we only want new unread items
	int localItemCount=[self numberOfItemsForAccount:moc];
	
	int max=200;//1000;
	
	// if this is first run (db has no items), then get most recent items even if already read...
	if(localItemCount>0)
	{
		// not initial load, only load recent unread items...
		
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"UpdateStatus"
		 object:@"Fetching unread items"];
		
		readingListFeed.url=[readingListFeed.url stringByAppendingFormat:@"?xt=user/-/state/com.google/read&"];
	}
	else 
	{
		// initial load, load recent items regardless of read/unread status...
		
		// dont load 1000 items, because its quite expensive...
		max=200;
		
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:@"UpdateStatus"
		 object:@"Fetching recent items"];
	}
	
	readingListFeed.name=@"AllItems";
	
	NSDate * minDate=[RssFeed maxDateWithAccountName:self.account.name withManagedObjectContext:moc];
	
	NSArray * items=[self getMostRecentReaderItems:readingListFeed maxItems:max minDate:minDate];
	
	NSLog(@"Got %d recent unread items from reading list",[items count]);
	
	for(FeedItem * item in items)
	{
		NSString * feedId=item.originId;
		if(feedId)
		{
			NSMutableArray * recentFeedItems=[readingListFeedCache objectForKey:feedId];
			if(recentFeedItems==nil)
			{
				recentFeedItems=[[NSMutableArray alloc] init];
				
				[readingListFeedCache setObject:recentFeedItems forKey:feedId];
				
				[recentFeedItems release];
			}
			[recentFeedItems addObject:item];
		}
		else 
		{
			NSLog(@"Feed items does not have originId!!!");
		}
	}
	
	[readingListFeed release];
}

- (int) numberOfItemsForAccount:(NSManagedObjectContext*)moc
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"RssFeedItem" inManagedObjectContext:moc]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"feed.account.name==%@",self.account.name]];
	 
	NSError *err;
	
	NSUInteger count = [moc countForFetchRequest:request error:&err];
	if(count == NSNotFound) 
	{
		NSLog(@"countForFetchRequest returned NSNotFound");
		//Handle error
		count=0;
	}
	
	[request release];
	return count;
	
}

- (int) getAppEngineItems:(NSManagedObjectContext*)moc
{
	int num_new_items=0;
	// get items user clipped from the web from GAE 
	NSArray * items = [client getClippedItemsWithFilter:nil];
	
	if([items count]>0)
	{
		// does user have "Read Later" folder?
		Folder * readLaterFolder=[self getReadLaterFolder:moc];
		
		ItemFilter * filter=[[ItemFilter alloc] init];
		
		for(FolderItem * item in readLaterFolder.items)
		{
			[filter rememberItem:item];
		}
		
		for(FeedItem * item in items)
		{
			if([filter isNewItem:item])
			{
				NSLog(@"got new GAE item: %@",[item url]);
				[filter rememberItem:item];
				
				[readLaterFolder addFeedItem:item];
				num_new_items++;
			}
		}
		
		[filter release];
		
		[readLaterFolder save];
	}
	return num_new_items;
}
- (Folder*) getReadLaterFolder:(NSManagedObjectContext*)moc
{
	Folder * readLaterFolder=nil;
	FolderFetcher * folderFetcher=[[FolderFetcher alloc] init];
	
	for(Folder  * folder in folderFetcher.items)
	{
		if([folder.name isEqualToString:@"Read Later"])
		{
			readLaterFolder= folder;
			break;
		}
	}
	
	if(readLaterFolder==nil)
	{
		// no such folder, create it...
		readLaterFolder=[Folder createInContext:moc];
		readLaterFolder.name=@"Read Later";
		readLaterFolder.image=[UIImage imageNamed:@"32-folderclosed.png"];
		[readLaterFolder save];
	}
	
	[folderFetcher release];
	return readLaterFolder;
	
}
- (int) updateReadStatus:(NSManagedObjectContext*)moc
{
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateStatus"
	 object:@"Updating read status"];
	
	NSLog(@"Begining updateReadStatus");
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"RssFeedItem" 
											  inManagedObjectContext:moc];
	
	NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
	NSMutableDictionary * updatedFeeds=[[NSMutableDictionary alloc] init];
	NSFetchRequest * request=[[NSFetchRequest alloc] init];
	
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"isRead==0 AND feed.account.name==%@",self.account.name]];
	[request setPropertiesToFetch:[NSArray arrayWithObjects:@"uid",@"headline",@"isRead",nil]];
	
	NSArray * localUnreadItems=[moc executeFetchRequest:request error:nil];
	
	int num_updated=0;
	
	if([localUnreadItems count]>0)
	{
		NSLog(@"Got %d local unread items from local database",[localUnreadItems count]);
		// TODO: if local unread item count is small, it may be faster/cheaper to check individual items rather than
		// download entire set of unread item ids...
		for(RssFeedItem *unreadItem in localUnreadItems)
		{
			[dict setObject:unreadItem forKey:unreadItem.uid];
		}
		
		int max = 200; 
		
		NSArray * remoteReadIds=[client getReadIds:max];
		
		NSLog(@"Got %d remote read item ids from Google",[remoteReadIds count]);
		
		for(NSString * remoteReadId in remoteReadIds)
		{
			RssFeedItem * unreadItem=[dict objectForKey:remoteReadId];
			if(unreadItem)
			{
				//NSLog(@"Marking local item as read: %@",remoteReadId);
			
				unreadItem.isRead=[NSNumber numberWithBool:YES];
				
				// remember to update this feeds unread count below...
				if ([updatedFeeds objectForKey:unreadItem.feed.url]==nil) 
				{
					[updatedFeeds setObject:unreadItem.feed forKey:unreadItem.feed.url];
				}
				
				num_updated++;
			}
		}
	}
	
	// find local items NOT marked as read by remote ids...
	/*for(RssFeedItem *unreadItem in localUnreadItems)
	{
		if(![unreadItem.isRead boolValue])
		{
			NSLog(@"Failed to mark local item as read: %@: %@",unreadItem.headline,unreadItem.uid);
		}
	}*/
	
	NSLog(@"Updated %d items setting isRead=YES",num_updated);
	
	if(num_updated>0)
	{
		for(RssFeed  * updatedFeed in [updatedFeeds allValues])
		{
			//NSLog(@"Updating read count for feed: %@",updatedFeed.url);
			[updatedFeed updateUnreadCount];
		}
		
		NSError * error=nil;
		
		//NSLog(@"Saving object context...");
		if(![moc save:&error])
		{
			if(error)
			{
				NSLog(@"Failed to save in GoogleAccountUpdater.updateReadStatus: %@",[error userInfo]);
			}
		}
	}
	
	[updatedFeeds release];
	
	[request release];
	[dict release];
	
	NSLog(@"Ending updateReadStatus");
	
	return num_updated;
}
				
- (BOOL) updateFeedListWithContext:(NSManagedObjectContext*)moc
{
	/*if(![self isAccountValid])
	{
		return NO;
	}*/
	
	BOOL updated=NO;
	
	if(kUseGoogleAppEngine)
	{
		if([self getAppEngineItems:moc]>0)
		{
			updated=YES;
		}
	}
	
	if([self updateReadStatus:moc]>0)
	{
		updated=YES;
	}
	
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
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateStatus"
	 object:@"Updating subscriptions..."];
	
	NSArray * remoteFeeds=[self remoteFeedList];
	
	FeedAccount * contextAccount=(FeedAccount *)[moc objectWithID:self.account.objectID];
	
	NSMutableDictionary * remote_map=[NSMutableDictionary new];
	NSMutableArray * feedsNeedingFavicons=[[[NSMutableArray alloc] init] autorelease];
	BOOL requiresFaviconDownload=NO;
	
	for(TempFeed * feed in remoteFeeds)
	{
		[remote_map setObject:feed forKey:[feed url]];
		
		RssFeed * existingFeed=[map objectForKey:[feed url]];
		
		if(existingFeed!=nil)
		{
			// see if name changed or feedType changed...
			if((![existingFeed.name isEqualToString:[feed name]]) || 
			   (![existingFeed.feedType isEqualToString:[feed feedType]]) ||
			   (![existingFeed.feedCategory isEqualToString:[feed feedCategory]]))
			{
				existingFeed.name=[feed name];
				if(feed.image)
				{
					existingFeed.image=feed.image;
				}
				existingFeed.htmlUrl=[feed htmlUrl];
				existingFeed.feedId=[feed feedId];
				existingFeed.feedType=[feed feedType];
				existingFeed.feedCategory=[feed feedCategory];
				
				[existingFeed save];
				
				updated=YES;
			}
		}
		else 
		{
			// add new one...
			RssFeed * newFeed= [NSEntityDescription insertNewObjectForEntityForName:@"RssFeed" inManagedObjectContext:moc];
			
			newFeed.name=[feed name];
			newFeed.feedType=[feed feedType];
			newFeed.feedCategory=[feed feedCategory];
			
			newFeed.url=[feed url];
			newFeed.image=[feed image];
			
			if(newFeed.image==nil)
			{
				requiresFaviconDownload=YES;
				[feedsNeedingFavicons addObject:newFeed];
			}
			
			newFeed.htmlUrl=[feed htmlUrl];
			newFeed.feedId=[feed feedId];
			
			newFeed.account=contextAccount;
			
			[map setObject:[newFeed url] forKey:[newFeed url]];
			
			updated=YES;
		}
	}
	
	if(requiresFaviconDownload)
	{
		// get favicons
		/*NSLog(@"Queieing favicon downloads to operation queue...");
		
		NSOperationQueue * queue=[[NSOperationQueue alloc] init];
		[queue setMaxConcurrentOperationCount:4];
		int num_queued=0;
		
		for(RssFeed * newFeed in feedsNeedingFavicons)
		{
			if(newFeed.image==nil)
			{
				NSInvocationOperation * op=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getFaviconForFeed:) object:newFeed];
				
				[queue addOperation:op];
				
				[op release];
				num_queued++;
			}
		}
		
		NSLog(@"Queued %d requests to operation queue...",num_queued);
		[queue waitUntilAllOperationsAreFinished];
		[queue release];*/
	}
	
	for(NSString * url in [map allKeys])
	{
		if([remote_map objectForKey:url]==nil)
		{
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
			NSLog(@"Failed to save in GoogleAccountUpdater.updateFeedListWithContext: %@",[error userInfo]);
		}
	}
	
	return updated;
}

- (void) getFaviconForFeed:(RssFeed* )feed
{
	feed.image=[UrlUtils faviconFromUrl:feed.htmlUrl imageCache:nil];
}

- (NSArray*) getMostRecentItems:(RssFeed*)feed maxItems:(int)maxItems
{
	if(feed.url==nil) return nil;
	
	if([feed.feedCategory isEqualToString:@"_all"] ||
	   [feed.feedCategory isEqualToString:@"_category"])
	{
		return nil;
	}
	
	if([feed.feedCategory isEqualToString:@"_starred"] ||
	   [feed.feedCategory isEqualToString:@"_shared"] ||
	   [feed.feedCategory isEqualToString:@"_notes"])
	{
		return [self getMostRecentReaderItems:feed maxItems:maxItems minDate:nil];
	}
	
	if([feed.feedType isEqualToString:@"GoogleAtom"])
	{
		return [self getMostRecentAtomItems:feed maxItems:maxItems];
	}
	else 
	{
		return nil;
	}
}

- (NSArray*) getMoreOldItems:(RssFeed *)feed maxItems:(int)maxItems;
{
	return [self getMostRecentItems:feed maxItems:maxItems];
}

- (NSArray*) getMostRecentAtomItems:(RssFeed*)feed maxItems:(int)maxItems 
{
	//NSLog(@"GoogleAccountUpdater.getMostRecentAtomItems: %@",feed.url);
	if(readingListFeedCache)
	{
		//NSLog(@"Using reading list feed cache...");
		NSArray * recentItems=[readingListFeedCache objectForKey:feed.feedId];
		//NSLog(@"Got %d recent items from reading list cache for feed: %@",[recentItems count],feed.feedId);
		return recentItems;
	}
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateStatus"
	 object:[NSString stringWithFormat:@"Updating \"%@\"...",feed.name]];
	
	NSString * url=[NSString stringWithFormat:@"%@?n=%d",feed.url,maxItems];
	
	NSLog(@"Getting most recent %d items from feed: %@",maxItems,feed.name);
	
	NSData * rawData=[client getData:url];
	
	NSLog(@"Got raw data from feed...");
	
	if([self isDataSameAsLastTime:feed data:rawData])
	{
		NSLog(@"Data is same as last time, skipping processing feed items...");
		return nil;
	}
	
	NSMutableArray * results=[[[NSMutableArray alloc] init] autorelease];
	
	NSString * data=[[[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding] autorelease];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	// <published>2010-08-30T15:33:02Z</published><updated>2010-08-30T15:33:02Z</updated>
	
	[formatter setLocale:enUS];
	[enUS release];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"]; 
	
	if(data)
	{
		NSDictionary *nsdict = [NSDictionary dictionaryWithObjectsAndKeys:
								@"http://www.w3.org/2005/Atom",
								@"atom", 
								nil];
		
		CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:data options:0 error:nil] autorelease];
		
		NSArray * entries=[xmlParser nodesForXPath:@"//atom:entry" namespaceMappings:nsdict error:nil];
		
		MarkupStripper * stripper=[[[MarkupStripper alloc] init] autorelease];
		
		for(CXMLElement * entry in entries)
		{
			TempFeedItem * tmp=[TempFeedItem new];
			
			@try 
			{
				tmp.headline=[stripper stripMarkup:[entry elementValue:@"title"]];
				
				NSArray * links=[entry elementsForName:@"link"];
				
				if(links && [links count]>0)
				{
					tmp.url=[[[links objectAtIndex:0] attributeForName:@"href"] stringValue];
				}
				
				NSArray * categories=[entry elementsForName:@"category"];
				
				/*
				 <category term="user/01817423256027348310/state/com.google/read" scheme="http://www.google.com/reader/" label="read"/>
				 <category term="user/01817423256027348310/state/com.google/reading-list" scheme="http://www.google.com/reader/" label="reading-list"/>
				 <category term="user/01817423256027348310/label/Programming" scheme="http://www.google.com/reader/" label="Programming"/>
				 <category term="summit" scheme="http://forums.construx.com/blogs/stevemcc/archive/tags/summit/default.aspx"/>
				 <category term="Construx Software Executive Summit" scheme="http://forums.construx.com/blogs/stevemcc/archive/tags/Construx+Software+Executive+Summit/default.aspx"/>
				 <category term="Construx" scheme="http://forums.construx.com/blogs/stevemcc/archive/tags/Construx/default.aspx"/>
				 <category term="Construx Software" scheme="http://forums.construx.com/blogs/stevemcc/archive/tags/Construx+Software/default.aspx"/>
				 <category term="Conference" scheme="http://forums.construx.com/blogs/stevemcc/archive/tags/Conference/default.aspx"/>
				 <category term="executive" scheme="http://forums.construx.com/blogs/stevemcc/archive/tags/executive/default.aspx"/>
				*/
				
				for(CXMLElement * category in categories)
				{
					if([[[category attributeForName:@"scheme"] stringValue ] isEqualToString:@"http://www.google.com/reader/"])
					{
						if([[[category attributeForName:@"label"] stringValue ] isEqualToString:@"read"])
						{
							tmp.isRead=[NSNumber numberWithBool:YES];
							continue;
						}
						if([[[category attributeForName:@"label"] stringValue ] isEqualToString:@"starred"])
						{
							tmp.isStarred=[NSNumber numberWithBool:YES];
							continue;
						}
						if([[[category attributeForName:@"label"] stringValue ] isEqualToString:@"broadcast"])
						{
							tmp.isShared=[NSNumber numberWithBool:YES];
							continue;
						}
					}
				}
				
				//<published>2010-08-30T15:33:02Z</published><updated>2010-08-30T15:33:02Z</updated>
				
				NSString * published=[entry elementValue:@"published"];
				
				NSString * updated=[entry elementValue:@"updated"];
				
				if([updated length]>0)
				{
					tmp.date=[formatter dateFromString:updated];
				}
				else 
				{
					tmp.date=[formatter dateFromString:published];
				}

				/*NSString * synopsis=[entry elementValue:@"summary"];
				
				if(synopsis==nil || [synopsis length]==0)
				{
					synopsis=[entry elementValue:@"content"];
				}*/
				
				
				NSString * synopsis=[entry elementValue:@"content"];
				
				if(synopsis==nil || [synopsis length]==0)
				{
					synopsis=[entry elementValue:@"summary"];
				}
				
				tmp.origSynopsis=synopsis; 
				
				tmp.origin=feed.name;
				tmp.originUrl=feed.htmlUrl;
				tmp.originId=feed.feedId;
				
				// get id: <id gr:original-id="1c8bc03b-986a-40b9-ab6d-e8d23056df8a:2758">tag:google.com,2005:reader/item/343ebd86409d8f1d</id>
				
				NSString * uid=[entry elementValue:@"id"];
				
				tmp.uid=uid;
				
				[results addObject:tmp];
			}
			@catch (NSException * e) 
			{
				NSLog(@"Exception parsing result item from response: %@",[e description]);
			}
			@finally 
			{
				[tmp release];
			}
		}
	}
	
	[formatter release];
	
	return results;
}

- (NSArray*) getMostRecentReaderItems:(RssFeed*)feed maxItems:(int)maxItems minDate:(NSDate*)minDate
{
	unsigned long current_seconds=[[NSDate date] timeIntervalSince1970];
	
	NSString * timestamp=[NSString stringWithFormat:@"%D",current_seconds];
	
	NSString * url;
	
	// get largest updated timestamp for items in the database...
	// blatant temporary hack to allow passing in of URL with appended params already...
	if([feed.url hasSuffix:@"&"])
	{
		url=[feed.url stringByAppendingFormat:@"n=%d&ck=%@&client=%@",maxItems,timestamp,kGoogleReaderClientName];
	}
	else 
	{
		url=[feed.url stringByAppendingFormat:@"?n=%d&ck=%@&client=%@",maxItems,timestamp,kGoogleReaderClientName];
	}
	
	//NSDate * maxUpdatedDate=[feed maxDate];
	
	if(minDate)
	{
		unsigned long max_updated_seconds=[minDate timeIntervalSince1970];
		NSString * max_updated_timestamp=[NSString stringWithFormat:@"%D",max_updated_seconds];
		
		url=[url stringByAppendingFormat:@"&ot=%@",max_updated_timestamp];
	}
	
	//NSLog(@"url=%@",url);
	//NSLog(@"Getting most recent %d items from feed: %@",maxItems,feed.name);
	
	NSLog(@"getMostRecentReaderItems: %@",url);
	
	NSData * rawData=[client getData:url];
	
	if([self isDataSameAsLastTime:feed data:rawData])
	{
		NSLog(@"Data is same as last time, skipping processing feed items...");
		return nil;
	}
	
	NSMutableArray * results=[[[NSMutableArray alloc] init] autorelease];
	
	NSDictionary * dict=[[[[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding] autorelease] JSONValue];
	
	if(dict)
	{
		//NSLog(@"json=%@",[dict description]);
		NSArray * items=[dict objectForKey:@"items"];
		
		if(items && [items count]>0)
		{
			MarkupStripper * stripper=[[[MarkupStripper alloc] init] autorelease];
			for(NSDictionary * item in items)
			{
				TempFeedItem * tmp=[[TempFeedItem alloc] init];
				@try 
				{
					tmp.headline=[stripper stripMarkup:[item objectForKey:@"title"]];
					//tmp.headline=[item objectForKey:@"title"];
								  
					if([item objectForKey:@"alternate"])
					{
						tmp.url=[[[item objectForKey:@"alternate"] objectAtIndex:0] objectForKey:@"href"];
					}
					
					NSString * dateString=[item objectForKey:@"published"];
					
					NSTimeInterval seconds=[dateString doubleValue];
					
					NSDate * theDate=[NSDate dateWithTimeIntervalSince1970:seconds];
					
					tmp.date=theDate;
					
					NSArray * categories=[item objectForKey:@"categories"];
					
					BOOL isPost=NO;
					BOOL isLink=NO;
					
					for (NSString * category in categories)
					{
						if ([category hasPrefix:@"user/"]) 
						{
							if([category hasSuffix:@"/state/com.google/read"])
							{
								// item has been read
								tmp.isRead=[NSNumber numberWithBool:YES];
								continue;
							}
							if([category hasSuffix:@"/state/com.google/starred"])
							{
								// item has been read
								tmp.isStarred=[NSNumber numberWithBool:YES];
								continue;
							}
							if([category hasSuffix:@"/state/com.google/broadcast"])
							{
								// item has been read
								tmp.isShared=[NSNumber numberWithBool:YES];
								continue;
							}
							if([category hasSuffix:@"/source/com.google/post"])
							{
								isPost=YES;
								continue;
							}
							if([category hasSuffix:@"/source/com.google/link"])
							{
								isLink=YES;
								continue;
							}
						}
					}
					
					NSString * synopsis;
					
					if([item objectForKey:@"content"])
					{
						//NSLog(@"get content");
						synopsis=[[item objectForKey:@"content"] objectForKey:@"content"];
					}
					else 
					{
						
						//NSLog(@"get summary");
						synopsis=[[item objectForKey:@"summary"] objectForKey:@"content"];
					}
					
					tmp.origSynopsis=synopsis;
					
					//if ([item objectForKey:@"annotations"]) 
					//{
						NSArray * annotations=[item objectForKey:@"annotations"];
						
						if([annotations count]>0)
						{
							NSLog(@"get annotations");
							NSString * notes=[[annotations objectAtIndex:0] objectForKey:@"content"];
							
							if (notes && [notes length]>0) 
							{
								tmp.notes=[stripper stripMarkup:notes]; //[notes flattenHTML];
							}
						}
					//}
					
					//"via":[{"href":"http://www.google.com/reader/public/atom/user/14480565058256660224/state/com.google/broadcast","title":"Scobleizer's shared items"}]
					
					
					//if ([item objectForKey:@"origin"])
					//{
						NSDictionary * origin=[item objectForKey:@"origin"];
						if(origin)
						{
							tmp.origin=[stripper stripMarkup:[origin objectForKey:@"title"]];
							tmp.originUrl=[origin objectForKey:@"htmlUrl"];
							tmp.originId=[origin objectForKey:@"streamId"];
						}
					//}
					
					tmp.uid=[item objectForKey:@"id"];
					
					if(isPost)
					{
						// if headline is missing, use synopsis as headline
						if([tmp.headline length]==0)
						{
							tmp.headline=tmp.origSynopsis;
						}
						// if no source
						if([tmp.origin length]==0)
						{
							tmp.origin=[item objectForKey:@"author"];
						}
					}
					
					[results addObject:tmp];
				}
				@catch (NSException * e) 
				{
					NSLog(@"Exception parsing result item from response: %@",[e description]);
				}
				@finally 
				{
					[tmp release];
				}
			}
		}
	}

	return results;
}
	   
- (void) dealloc
{
	[client release];
	client=nil;
	[readingListFeedCache release];
	readingListFeedCache=nil;
	[super dealloc];
}

@end
