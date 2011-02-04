//
//  Feed.m
//  Untitled
//
//  Created by Robert Stewart on 5/20/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "Feed.h"
#import "FeedItem.h"
#import "ItemFilter.h"
#import "ItemFetcher.h"

@implementation TempFeed
@synthesize name,feedType,url,image,htmlUrl,feedId,feedCategory;


- (void) save
{
}
- (void) delete
{
}
- (void) markAllAsRead
{
}
- (void) deleteOlderThan:(int)days
{
}
- (void) deleteReadItems
{
}

- (void) dealloc
{
	[name release];
	[feedType release];
	[feedCategory release];
	[url release];
	[image release];
	[htmlUrl release];
	[feedId	 release];
	[super dealloc];
}

@end

@implementation Feed
@dynamic lastUpdated,summary,name,feedType,url,image,htmlUrl,feedId,unreadCount,feedCategory; //,image,itemFetcher;

- (void) updateUnreadCount
{
	NSLog(@"Feed.updateUnreadCount");
}

- (int) entityCount:(NSString*)entityName predicate:(NSPredicate*)predicate
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSManagedObjectContext * moc=[self managedObjectContext];
	[request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
	
	if(predicate!=nil)
	{
		[request setPredicate:predicate];
	}
	
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
- (void) save
{
	NSLog(@"Feed.save");
	NSError * error=nil;
	NSManagedObjectContext * moc=[self managedObjectContext];
	if(![moc save:&error])
	{
		if(error)
		{
			NSLog(@"Error in Feed.save: %@",[error userInfo]);
		}
	}
}

- (void) delete	
{
	[[self managedObjectContext] deleteObject:self];
}

- (ItemFetcher*) itemFetcher
{
}

- (BOOL) editable
{
	return NO;
}

- (NSNumber*) currentUnreadCount
{
	return [self unreadCount];
}


- (void) markAllAsRead
{
}
- (void) deleteOlderThan:(int)days
{
}
- (void) deleteReadItems
{
	
}

/*
+ (UIImage*) getFaviconImageFromUrl:(NSString*)url
{
	NSURL * u=[NSURL URLWithString:url];
	
	NSString * faviconUrl=[NSString stringWithFormat:@"http://%@/favicon.ico"];
	
	return [Feed getImageFromUrl:faviconUrl];
}

+(UIImage*) getImageFromUrl:(NSString*)url
{
	NSLog(@"getImageFromUrl: %@",url);
	return nil;
}

+(UIImage*) getFeedImageForItem:(FeedItem*)item
{
	if(item.originUrl && [item.originUrl length]>0)
	{
		UIImage * img=[Feed getFaviconImageFromUrl:item.originUrl];
		
		if(img)
		{
			return img;
		}
	}
	if(item.url && [item.url length]>0)
	{
		if(![item.url isEqualToString:item.originUrl])
		{
			UIImage * img=[Feed getFaviconImageFromUrl:item.originUrl];
		
			if(img)
			{
				return img;
			}
		}
	}
	return nil;
}
*/
@end
