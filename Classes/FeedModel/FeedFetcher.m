//
//  FeedFetcher.m
//  Untitled
//
//  Created by Robert Stewart on 8/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//
#import "ItemFetcher.h"
#import "FeedFetcher.h"
#import "RssFeedItem.h"
#import "RssFeed.h"

// get all accounts
@implementation AccountFetcher
/*
- (NSManagedObject*) newItem
{
	NSManagedObject * newObj= [NSEntityDescription insertNewObjectForEntityForName:@"FeedAccount" inManagedObjectContext:[self managedObjectContext]];
	
	return newObj;
}*/
/*
- (void) setManagedObjectAttributes:(id)item managedObject:(NSManagedObject*)obj
{
	[obj setName:[item name]];
	[obj setUsername:[item username]];
	[obj setPassword:[item password]];
}*/

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	fetchedResultsController=[self createFetchedResultsController:@"FeedAccount"  predicate:nil sortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"sortName" 
																																									  ascending:YES] autorelease]]];

	[fetchedResultsController setDelegate:self];
	
	return fetchedResultsController;
}    
@end

@implementation CategoryFeedFetcher
@synthesize feedCategory;

- (void) markAllAsRead
{
	NSLog(@"CategoryFeedFetcher.markAllAsRead");
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(ANY feed.feedCategory.name==%@) AND feed.account.name == %@ AND isRead==0", feedCategory,accountName];
	
	NSManagedObjectContext * moc=[self managedObjectContext];
	
	NSFetchRequest * fetchRequest=[[NSFetchRequest alloc] init];
	
	[fetchRequest setPredicate:predicate];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"RssFeedItem"
										inManagedObjectContext:moc]];
	
	[fetchRequest setFetchBatchSize:0];
	
	NSArray * unreadItems=[moc executeFetchRequest:fetchRequest  error:nil];				
	
	BOOL needSave=NO;
	
	if([unreadItems count]>0)
	{
		NSLog(@"Marking %d items as read",[unreadItems count]);
		for(RssFeedItem * item in unreadItems)
		{
			item.isRead=[NSNumber numberWithBool:YES];
		}
	}
	
	predicate = [NSPredicate predicateWithFormat:
				 @"(ANY feedCategory.name==%@) AND account.name == %@  AND unreadCount>0", feedCategory,accountName];
	
	[fetchRequest release];
	
	fetchRequest=[[NSFetchRequest alloc] init];
	
	[fetchRequest setPredicate:predicate];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"RssFeed"
										inManagedObjectContext:moc]];
	
	[fetchRequest setFetchBatchSize:0];
	
	NSArray * unreadFeeds=[moc executeFetchRequest:fetchRequest  error:nil];	
	
	if([unreadFeeds count]>0)
	{
		for(RssFeed * feed in unreadFeeds)
		{
			feed.unreadCount=0;
		}
		needSave=YES;
	}

	[fetchRequest release];
	
	if(needSave)
	{
		NSError * error=nil;
		
		if(![moc save:&error])
		{
			NSLog(@"Failed to save changes in FeedFetcher.markAllAsRead: %@",[error userInfo]);
		}
	}
}


- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(ANY feedCategory.name==%@) AND account.name == %@", feedCategory,accountName];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"feedType" 
																   ascending:YES];
	
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" 
																	ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor2,nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"RssFeed"  predicate:predicate sortDescriptors:sortDescriptors];
	
	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release];
	[sortDescriptor2 release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    
- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super initWithCoder:decoder])
	{
		self.feedCategory=[decoder decodeObjectForKey:@"feedCategory"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:feedCategory forKey:@"feedCategory"];
}
- (void) dealloc
{
	[feedCategory release];
	[super dealloc];
}

@end



// get all feeds for account
@implementation AccountFeedFetcher  
@synthesize accountName;



- (void) markAllAsRead
{
	NSLog(@"AccountFeedFetcher.markAllAsRead");
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"feed.account.name == %@ AND isRead==0", accountName];
	
	NSManagedObjectContext * moc=[self managedObjectContext];
	
	NSFetchRequest * fetchRequest=[[NSFetchRequest alloc] init];
	
	[fetchRequest setPredicate:predicate];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"RssFeedItem"
							   inManagedObjectContext:moc]];
	
	[fetchRequest setFetchBatchSize:0];
					
	NSArray * unreadItems=[moc executeFetchRequest:fetchRequest  error:nil];				
	
	BOOL needSave=NO;
	
	if([unreadItems count]>0)
	{
		NSLog(@"Marking %d items as read",[unreadItems count]);
		for(RssFeedItem * item in unreadItems)
		{
			item.isRead=[NSNumber numberWithBool:YES];
		}
		needSave=YES;
	}
	
	predicate = [NSPredicate predicateWithFormat:
				 @"account.name == %@ AND unreadCount>0", accountName];
	
	[fetchRequest release];
	
	fetchRequest=[[NSFetchRequest alloc] init];
	
	[fetchRequest setPredicate:predicate];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"RssFeed"
										inManagedObjectContext:moc]];
	
	[fetchRequest setFetchBatchSize:0];
	
	NSArray * unreadFeeds=[moc executeFetchRequest:fetchRequest  error:nil];	
	
	if([unreadFeeds count]>0)
	{
		for(RssFeed * feed in unreadFeeds)
		{
			feed.unreadCount=0;
		}
		needSave=YES;
	}
	
	[fetchRequest release];
	
	if(needSave)
	{
		NSError * error=nil;
		
		if(![moc save:&error])
		{
			NSLog(@"Failed to save changes in FeedFetcher.markAllAsRead: %@",[error userInfo]);
		}
	}
}

/*
- (NSManagedObject*) newItem
{
	NSManagedObject * newObj= [NSEntityDescription insertNewObjectForEntityForName:@"RssFeed" inManagedObjectContext:[self managedObjectContext]];
	
	[newObj setAccount:[self accountObject]];
	return newObj;
}*/

- (NSManagedObject*) accountObject
{
	return [self fetchSingleObject:@"FeedAccount" predicate:[NSPredicate predicateWithFormat:
														 @"name == %@", accountName]];
}

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	
	NSArray * topLevelCategories=[NSArray arrayWithObjects:@"_top",@"_category",@"_all",@"_starred",@"_shared",@"_none",@"_notes",@"_twitter_home",@"_twitter_friends",@"_twitter_favorites",@"_twitter_direct",@"_twitter_list",@"_twitter_mentions",nil];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"(account.name == %@) AND (ANY feedCategory.name IN %@)", accountName,topLevelCategories] ;
	
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"feedType" 
																   ascending:YES];
	
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" 
																   ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor2,nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"RssFeed"  predicate:predicate sortDescriptors:sortDescriptors];

	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release];
	[sortDescriptor2 release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    
- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.accountName=[decoder decodeObjectForKey:@"accountName"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:accountName forKey:@"accountName"];
}
- (void) dealloc
{
	[accountName release];
	[super dealloc];
}

@end

@implementation AccountUpdatableFeedFetcher

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"account.name == %@", accountName];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"feedType" 
																   ascending:YES];
	
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" 
																	ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptor2,nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"RssFeed"  predicate:predicate sortDescriptors:sortDescriptors];
	
	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release];
	[sortDescriptor2 release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    

@end


 

// get all folders
@implementation FolderFetcher 
 /*
- (NSManagedObject*) newItem
{
	NSManagedObject * newObj= [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:[self managedObjectContext]];
	
	return newObj;
}*/
/*
- (void) setManagedObjectAttributes:(id)item managedObject:(NSManagedObject*)obj
{
	[obj setName:[item name]];
}*/

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" 
																   ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"Folder"  predicate:nil sortDescriptors:sortDescriptors];

	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release], sortDescriptor = nil;
	[sortDescriptors release], sortDescriptors = nil;
	
	return fetchedResultsController;
}    

@end

// get all newsletters
@implementation NewsletterFetcher  
/*
- (NSManagedObject*) newItem
{
	NSManagedObject * newObj= [NSEntityDescription insertNewObjectForEntityForName:@"Newsletter" inManagedObjectContext:[self managedObjectContext]];
	
	return newObj;
}*/
/*
- (void) setManagedObjectAttributes:(id)item managedObject:(NSManagedObject*)obj
{
	[obj setName:[item name]];
}*/

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" 
																   ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"Newsletter"  predicate:nil sortDescriptors:sortDescriptors];

	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release], sortDescriptor = nil;
	[sortDescriptors release], sortDescriptors = nil;
	
	return fetchedResultsController;
}    

@end

// get sections for newsletter
@implementation NewsletterSectionFetcher 
@synthesize newsletter;
/*
- (NSManagedObject*) newItem
{
	NSManagedObject * newObj= [NSEntityDescription insertNewObjectForEntityForName:@"NewsletterSection" inManagedObjectContext:[self managedObjectContext]];
	
	
	[newObj setNewsletter:newsletter];
	
	return newObj;
}*/
/*
- (void) setManagedObjectAttributes:(id)item managedObject:(NSManagedObject*)obj
{
	[obj setName:[item name]];
}*/

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"newsletter == %@", newsletter];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" 
																   ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"NewsletterSection"  predicate:predicate sortDescriptors:sortDescriptors];

	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release], sortDescriptor = nil;
	[sortDescriptors release], sortDescriptors = nil;
	
	return fetchedResultsController;
}   
- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		NSURL * uri=[decoder decodeObjectForKey:@"uri"];
		
		self.newsletter=[self getObjectForURL:uri];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	NSURL * uri=[[newsletter  objectID] URIRepresentation];
	
	[encoder encodeObject:uri forKey:@"uri"];
}
- (void) dealloc
{
	[newsletter release];
	[super dealloc];
}

@end




