#import "AccountUpdater.h"
#import "MD5.h"
#import <CoreData/CoreData.h>
#import "RssFeed.h"
#import "ItemFilter.h"
#import "RssFeedItem.h"

@implementation AccountUpdater
@synthesize account,iterations;

- (id) initWithAccount:(FeedAccount*)account
{
	if([super init])
	{
		self.account=account;
		self.iterations=[NSArray arrayWithObjects:[NSNumber numberWithInt:20],nil];
	}
	return self;
}

- (void) willUpdateFeeds:(NSManagedObjectContext*)moc  forCategory:(NSString*)category
{
}

- (BOOL) isAccountValid
{
	NSLog(@"AccountUpdater.isAccountValid");
	return YES;
}

- (NSArray*) getMostRecentItems:(RssFeed*)feed maxItems:(int)maxItems
{
	// implement in subclass
	return nil;
}

- (NSArray*) getMoreOldItems:(RssFeed *)feed maxItems:(int)maxItems
{
	// implement in subclass
	return nil;
}


- (BOOL) updateFeedListWithContext:(NSManagedObjectContext*)moc;
{
	// implement in subclass
	return NO;
}

- (BOOL) updateFeed:(RssFeed*)feed withContext:(NSManagedObjectContext*)moc
{
	if(![self isAccountValid])
	{
		return NO;
	}
	//NSLog(@"updateFeed:%@",feed.name);
	
	BOOL updated=NO;
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	ItemFilter * filter=nil;
	
	int numNewItems=0;
	BOOL requiresUpdateUnreadCount=NO;
	
	//int maxItemsList[]={1,20};
	//NSLog(@"Doing %d iterations",[iterations count]);
	for(int i=0;i<[iterations count];i++)
	{
		int maxItems=[[iterations objectAtIndex:i] intValue];
		//NSLog(@"doing iteration for maxItems=%d",maxItems);
		
		NSArray * items=[self getMostRecentItems:feed maxItems:maxItems];
		
		//NSLog(@"got %d most recent items",[items count]);
		
		if([items count]>0)
		{
			if(filter==nil)
			{
				filter=[ItemFilter new];
				[self fillItemFilterForFeed:feed filter:filter];
			}
			
			for(id item in items)
			{
				if(![filter isNewItem:item])
				{
					// TODO: see if item was updated - if read status changed, mark as read, if moved to starred/shared status change that too...
					if ([filter isUpdated:item]) 
					{
						// change updated item
						
						FeedItem * existingItem=[filter getItem:item];
						if(existingItem)
						{
							// only mark as read, dont unmark local items...
							if(![existingItem.isRead boolValue])
							{
								if([[item isRead] boolValue])
								{
									existingItem.isRead=[item isRead];
								}
							}
							
							existingItem.isShared=[item isShared];
							existingItem.isStarred=[item isStarred];
							
							requiresUpdateUnreadCount=YES;
						}
					}
					continue;
				}
				else 
				{
					[filter rememberItem:item];
				}
				
				RssFeedItem * newItem=[NSEntityDescription insertNewObjectForEntityForName:@"RssFeedItem" inManagedObjectContext:moc];
				
				[newItem copyAttributes:item];
				
				newItem.feed=feed;
				
				numNewItems++;
				requiresUpdateUnreadCount=YES;
			}
			
			if(numNewItems==[items count])
			{
				//NSLog(@"Added %d new items from feed, fetching more items...",numNewItems);
				// get more...
				continue;
			}
			else 
			{
				break;
			}
		}
		else 
		{
			break;
		}
	}
	
	[filter release];
	NSError * error=nil;
	
		if(![moc save:&error])
		{
			if(error)
			{
				NSLog(@"Error saving in AccountUpdater.updateFeed:withContext: %@",[error userInfo]);
			}
		}
		
		[moc refreshObject:feed mergeChanges:YES];
	if(requiresUpdateUnreadCount)
	{
		
		
		//NSLog(@"updating feed unread count");
		// update feed unread count
		feed.lastUpdated=[NSDate date];
		[feed updateUnreadCount];
		[feed save];
	}
	
	[pool drain];
	
	return requiresUpdateUnreadCount;
}

- (BOOL) backFillFeed:(RssFeed*)feed withContext:(NSManagedObjectContext*)moc
{
	if(![self isAccountValid])
	{
		return NO;
	}
	
	BOOL updated=NO;
	
	NSAutoreleasePool * pool=[[NSAutoreleasePool alloc] init];
	
	ItemFilter * filter=nil;
	
	int numNewItems=0;
	BOOL requiresUpdateUnreadCount=NO;
	
	for(int i=0;i<[iterations count];i++)
	{
		int maxItems=[[iterations objectAtIndex:i] intValue];
		
		NSArray * items=[self getMoreOldItems:feed maxItems:maxItems];
		
		if([items count]>0)
		{
			if(filter==nil)
			{
				filter=[ItemFilter new];
				[self fillItemFilterForFeed:feed filter:filter];
			}
			
			for(id item in items)
			{
				if(![filter isNewItem:item])
				{
					// TODO: see if item was updated - if read status changed, mark as read, if moved to starred/shared status change that too...
					if ([filter isUpdated:item]) 
					{
						// change updated item
						
						FeedItem * existingItem=[filter getItem:item];
						if(existingItem)
						{
							// only mark as read, dont unmark local items...
							if(![existingItem.isRead boolValue])
							{
								if([[item isRead] boolValue])
								{
									existingItem.isRead=[item isRead];
								}
							}
							
							existingItem.isShared=[item isShared];
							existingItem.isStarred=[item isStarred];
							
							requiresUpdateUnreadCount=YES;
						}
					}
					continue;
				}
				else 
				{
					[filter rememberItem:item];
				}
				
				RssFeedItem * newItem=[NSEntityDescription insertNewObjectForEntityForName:@"RssFeedItem" inManagedObjectContext:moc];
				
				[newItem copyAttributes:item];
				
				newItem.feed=feed;
				
				numNewItems++;
				requiresUpdateUnreadCount=YES;
			}
			
			if(numNewItems==[items count])
			{
				//NSLog(@"Added %d new items from feed, fetching more items...",numNewItems);
				// get more...
				continue;
			}
			else 
			{
				break;
			}
		}
		else 
		{
			break;
		}
	}
	
	[filter release];
	NSError * error=nil;
	
		if(![moc save:&error])
		{
			if(error)
			{
				NSLog(@"Error saving in AccountUpdater.updateFeed:withContext: %@",[error userInfo]);
			}
		}
		
		[moc refreshObject:feed mergeChanges:YES];
	if(requiresUpdateUnreadCount)
	{
		
		//NSLog(@"updating feed unread count");
		// update feed unread count
		feed.lastUpdated=[NSDate date];
		[feed updateUnreadCount];
		[feed save];
	}
	
	[pool drain];
	
	return requiresUpdateUnreadCount;
}

- (void) authorize
{
	
}

- (BOOL) isDataSameAsLastTime:(RssFeed*)feed data:(NSData*)data
{
	if([feed respondsToSelector:@selector(lastUpdateHash)])
	{
		NSString * md5=[data md5];
		
		if(md5 && [md5 length]>0)
		{
			
			if(feed.lastUpdateHash && [feed.lastUpdateHash length]>0)
			{
				if([md5 isEqualToString:feed.lastUpdateHash])
				{
					NSLog(@"Feed data has not changed... skipping update processing...");
					return YES;
				}
				else 
				{
					feed.lastUpdateHash=md5;
				}
			}
			else 
			{
				feed.lastUpdateHash=md5;
			}
		}
	}
	return NO;
}

- (void) fillItemFilterForFeed:(RssFeed*)feed filter:(ItemFilter*)filter
{
	// just select headline + url
	NSFetchRequest * request=[[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity=[NSEntityDescription entityForName:@"RssFeedItem" inManagedObjectContext:[feed managedObjectContext]];
	
	[request setEntity:entity];
	
	NSDictionary *entityProperties = [entity propertiesByName];
	
	[request setIncludesSubentities:NO];
	
	[request setPropertiesToFetch:[NSArray arrayWithObjects:[entityProperties objectForKey:@"url"],[entityProperties objectForKey:@"headline"],[entityProperties objectForKey:@"isRead"],[entityProperties objectForKey:@"isStarred"],[entityProperties objectForKey:@"isShared"],nil]];
	
	[request setPredicate:[NSPredicate predicateWithFormat: @"feed == %@", feed]];
	
	NSArray * items = [[feed managedObjectContext] executeFetchRequest:request error:nil];
	
	for(id item in items)
	{
		[filter rememberItem:item];
	}
	
	[request release];
	
}

- (void) dealloc
{
	[iterations release];
	[account release];
	[super dealloc];
} 
@end
