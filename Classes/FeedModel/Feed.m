#import "Feed.h"
#import "FeedItem.h"
#import "ItemFilter.h"
#import "ItemFetcher.h"
#import "FeedCategory.h"


@implementation TempFeedCategory
@synthesize name;

- (void) dealloc
{
	[name release];
	[super dealloc];
}

@end


@implementation TempFeed
@synthesize name,feedType,url,image,htmlUrl,feedId,feedCategory,imageName,highlightedImageName;


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

- (void) setSingleCategory:(NSString*)category
{
	TempFeedCategory * newCategory=[[TempFeedCategory alloc] init];
		
	newCategory.name=category;
	
	self.feedCategory=[NSSet setWithObject:newCategory];
	
	[newCategory release];
}

- (BOOL) isSingleCategory:(NSString*)category
{
	if([self.feedCategory count]==1)
	{
		if([[self.feedCategory anyObject] isEqualToString:category])
		{
			return YES;
		}
	}
	return NO;
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
	[imageName release];
	[highlightedImageName release];
	[super dealloc];
}

@end

@implementation Feed
@dynamic lastUpdated,summary,name,feedType,url,image,htmlUrl,feedId,unreadCount,feedCategory,imageName,highlightedImageName; //,image,itemFetcher;

+ (BOOL) haveSameProperties:(Feed*)a b:(Feed*)b
{
	if((![a.name isEqualToString:[b name]]) ||
	   (![a.feedType isEqualToString:[b feedType]]) ||
	   (![Feed haveSameCategoryNames:[a feedCategory] b:[b feedCategory]]))
   {
	   return NO;
   }
   else	
   {
	   return YES;
   }	   
}
	   
+ (BOOL) haveSameCategoryNames:(NSSet*)a b:(NSSet*)b
{
   if([a count]!=[b count]) return NO;
   for(id * c in a)
   {
	   BOOL found=NO;
	   for(id * d in b)
	   {
		   if([[c name] isEqualToString:[d name]])
		   {
			   found=YES;
			   break;
		   }
	   }
	   if(!found)
	   {
		   return NO;
	   }
   }
   return YES;
}

- (void) setFeedCategories:(NSSet*)categories
{
	NSMutableArray * newCategoryNames=[[NSMutableArray alloc] init];
	
	for(FeedCategory * category in categories)
	{
		NSString * categoryName=[category name];
		if(![self hasFeedCategoryName:categoryName])
		{
			[newCategoryNames addObject:categoryName];
		}
	}
	
	if([newCategoryNames count]>0)
	{
		NSMutableSet * newSet=[NSMutableSet setWithSet:[self feedCategory]];
		
		for(NSString * categoryName in newCategoryNames)
		{
			FeedCategory * newCategory=[NSEntityDescription insertNewObjectForEntityForName:@"FeedCategory" inManagedObjectContext:[self managedObjectContext]];
	
			newCategory.name=categoryName;
			
			[newSet addObject:newCategory];
		}
		
		self.feedCategory=newSet;
		
	}
	
	[newCategoryNames release];
}

- (void) updateUnreadCount
{
	NSLog(@"Feed.updateUnreadCount - you need to implement this in subclass!!!");
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

- (BOOL) isCategory
{
	return [self isSingleCategory:@"_category"];
}

- (BOOL) isAllItems
{
	return [self isSingleCategory:@"_all"];
}

- (void) setSingleCategory:(NSString*)category
{
	FeedCategory * newCategory=[NSEntityDescription insertNewObjectForEntityForName:@"FeedCategory" inManagedObjectContext:[self managedObjectContext]];
	
	newCategory.name=category;
	
	self.feedCategory=[NSSet setWithObject:newCategory];
}

- (BOOL) isSingleCategory:(NSString*)category
{
	if([self.feedCategory count]==1)
	{
		if([[[self.feedCategory anyObject] name ] isEqualToString:category])
		{
			return YES;
		}
	}
	return NO;
}

- (BOOL) hasFeedCategoryName:(NSString*)category
{
	for(FeedCategory * category in self.feedCategory)
	{
		if([[category name] isEqualToString:category])
		{
			return YES;
		}
	}
	return NO;
}
- (void) save
{
	////NSLog(@"Feed.save");
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
	//NSLog(@"Feed.currentUnreadCount");
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
