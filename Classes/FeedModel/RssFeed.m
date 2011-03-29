#import "RssFeed.h"
#import "ItemFilter.h"
#import "FeedItem.h"
#import "Base64.h"
#import "TouchXML.h"
#import "FeedAccount.h"
#import "ItemFetcher.h"
#import "FeedFetcher.h"

@implementation RssFeed
@dynamic items,account,lastUpdateHash,unreadCount;

- (int) itemCount
{
	// naive implementation - optimize in subclasses
	if([self isCategory])
	{
		return [self entityCount:@"RssFeedItem" predicate:[NSPredicate predicateWithFormat:@"(feed.account.name==%@) AND (ANY feed.feedCategory.name==%@)",self.account.name,self.name]];
		
	}
	else
	{
		if([self isAllItems])
		{
			return [self entityCount:@"RssFeedItem" predicate:[NSPredicate predicateWithFormat:@"feed.account.name==%@",self.account.name]];  
		}
		else
		{
			return [self entityCount:@"RssFeedItem" predicate:[NSPredicate predicateWithFormat:@"feed==%@",self]];  
		}
	}
}


+ (NSDate*) maxDateWithAccountName:(NSString*)accountName forCategory:(NSString*)category withManagedObjectContext:(NSManagedObjectContext*)moc
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:[NSEntityDescription entityForName:@"RssFeedItem" inManagedObjectContext:moc]];
	
	if(category)
	{
		NSPredicate *predicate = [NSPredicate predicateWithFormat:
								  @"feed.account.name == %@ AND (ANY feed.feedCategory.name==%@)", accountName,category];
		
		[request setPredicate:predicate];
	}
	else 
	{
		[request setPredicate:[NSPredicate predicateWithFormat:@"feed.account.name==%@",accountName]];
	}

	
	[request setFetchBatchSize:0];
	[request setFetchLimit:1];
	
	[request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
	
	[request setPropertiesToFetch:[NSArray arrayWithObject:@"date"]];
	
	NSError *error;
	
	NSArray * results=[moc executeFetchRequest:request error:&error];
	
	NSDate * date=nil;
	
	if([results count]>0)
	{
		FeedItem * item=[results objectAtIndex:0];
		if(item)
		{
			date=item.date; //[item.date autorelease];
		}
	}
	
	[request release];
	
	return date;
}

- (NSDate*) maxDate
{
	return [RssFeed maxDateWithAccountName:self.account.name forCategory:nil withManagedObjectContext:[self managedObjectContext]];
}

- (NSNumber *) currentUnreadCount
{
	if([self isCategory])
	{
		int count=[self entityCount:@"RssFeedItem" predicate:[NSPredicate predicateWithFormat:@"(isRead==0) AND (feed.account.name==%@) AND (ANY feed.feedCategory.name==%@)",self.account.name,self.name]];
		
		return [NSNumber numberWithInt:count];
	}
	else
	{
		if([self isAllItems])
		{
			int count=[self entityCount:@"RssFeedItem" predicate:[NSPredicate predicateWithFormat:@"(isRead==0) AND (feed.account.name==%@)",self.account.name]];  
			return [NSNumber numberWithInt:count];
		}
		else
		{
			return [self unreadCount];
		}
	}
}

- (void) markAllAsRead
{
	//NSLog(@"markAllAsRead");
	
	NSManagedObjectContext * moc=[self managedObjectContext];
	
	int num_marked=0;
	
	ItemFetcher * fetcher=[self itemFetcher];
	
	for(FeedItem * item in [fetcher items])
	{
		if(![item.isRead boolValue])
		{
			item.isRead=[NSNumber numberWithBool:YES];
			num_marked++;
		}	
	}
	
	self.unreadCount=0;
	
	NSError * error=nil;

	if(![moc save:&error])
	{
		//NSLog(@"Failed to save changes in RssFeed.markAllAsRead: %@",[error userInfo]);
	}
}

- (void) deleteOlderThan:(int)days
{
	//NSLog(@"deleteOlderThan: %d",days);
	
	int seconds=days * 60 * 60 * 24;
	
	NSDate * date=[NSDate date];
	
	NSManagedObjectContext * moc=[self managedObjectContext];
	
	ItemFetcher * fetcher=[self itemFetcher];
	
	int num_deleted=0;
	
	for(FeedItem * item in [fetcher items])
	{
		if(fabs([item.date timeIntervalSinceDate:date]) > seconds)
		{
			[moc deleteObject:item];
			num_deleted++;
		}
	}
	
	//NSLog(@"Deleted %d items from feed",num_deleted);
	
	if(num_deleted>0)
	{
		[self updateUnreadCount];
		
		NSError * error=nil;
	
		if(![moc save:&error])
		{
			//NSLog(@"Failed to save changes: %@",[error userInfo]);
		}
	}
}
- (void) deleteReadItems
{
	//NSLog(@"deleteReadItems");
	NSManagedObjectContext * moc=[self managedObjectContext];
	
	ItemFetcher * fetcher=[self itemFetcher];
	
	int num_deleted=0;
	
	for(FeedItem * item in [fetcher items])
	{
		if([item.isRead boolValue])
		{
			[moc deleteObject:item];
			num_deleted++;
		}
	}
	
	//NSLog(@"Deleted %d items from feed",num_deleted);
	
	if(num_deleted>0)
	{
		[self updateUnreadCount];
		
		NSError * error=nil;
		
		if(![moc save:&error])
		{
			//NSLog(@"Failed to save changes: %@",[error userInfo]);
		}
	}
}

- (void) updateUnreadCount
{
	//NSLog(@"RssFeed.updateUnreadCount");
	// get number of items with isRead=NO from this feed...
	
	int count=[self entityCount:@"RssFeedItem" predicate:[NSPredicate predicateWithFormat:@"(isRead==0) AND (feed==%@)",self]];
	
	//NSLog(@"Got %d as unread count for feed",count);
	
	if(count!=[self.unreadCount intValue])
	{
		self.unreadCount=[NSNumber numberWithInt:count];
	}
}

- (NSData*) getRssData
{
	if(self.url==nil) return;
	
	NSLog(@"%@",self.url);
	
	// attempt to avoid leaking NSData from response?
	[[NSURLCache sharedURLCache] removeAllCachedResponses];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:90.0];
	// use FF user agent so server is ok with us...
	//[request setValue: @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.16) Gecko/20080702 Firefox/2.0.0.16 (gzip)" forHTTPHeaderField: @"User-Agent"];
	[request addValue:@"InfoNgen Curator HD (gzip)" forHTTPHeaderField:@"User-Agent"];
	[request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	// for InfoNgen RSS output...
	[request addValue:@"false" forHTTPHeaderField:@"GenerateRIXML"];
	
	if(self.account)
	{
		if (self.account.username!=nil && self.account.password!=nil && [self.account.username length]>0)
		{
			NSString *authString = [Base64 encode:[[NSString stringWithFormat:@"%@:%@",self.account.username,self.account.password] dataUsingEncoding:NSUTF8StringEncoding]]; 
			[request setValue:[NSString stringWithFormat:@"Basic %@", authString] forHTTPHeaderField:@"Authorization"];
		}
	}
	
	return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

- (ItemFetcher*) feedFetcher
{
	if([self isCategory])
	{
		CategoryFeedFetcher * feedFetcher=[[CategoryFeedFetcher alloc] init];
		feedFetcher.accountName=self.account.name;
		feedFetcher.feedCategory=self.name;
		return [feedFetcher autorelease];
	}
	else 
	{
		return nil;
	}
}

- (ItemFetcher*) itemFetcher
{
	if([self.url hasPrefix:@"category://"])
	{
		CategoryItemFetcher * itemFetcher = [[CategoryItemFetcher alloc] init];
		
		itemFetcher.accountName=self.account.name;
		itemFetcher.feedCategory=[self.url substringFromIndex:11];//   self.name;
		
		return [itemFetcher autorelease]; 
	}
	
	if([self isCategory])
	{
		CategoryItemFetcher * itemFetcher = [[CategoryItemFetcher alloc] init];
		
		itemFetcher.accountName=self.account.name;
		itemFetcher.feedCategory=self.name;
		
		return [itemFetcher autorelease]; 
	}
	
	
	if([self isAllItems])
	{
		AccountItemFetcher * itemFetcher = [[AccountItemFetcher alloc] init];
		
		itemFetcher.accountName=self.account.name;
		itemFetcher.feedType=@"RssFeed";// HACK
		
		return [itemFetcher autorelease]; 
	}
	
	// get items for feed name/url/type/account
	FeedItemFetcher * itemFetcher=[[FeedItemFetcher alloc] init];
	itemFetcher.feed=self;
		
	return [itemFetcher autorelease];
}

@end
