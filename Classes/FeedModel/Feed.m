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

- (int) itemCount
{
	NSLog(@"Using naive implementation for itemCount, consider override in subclass...");
	// naive implementation - optimize in subclasses
	return [[self items] count];
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

@end
