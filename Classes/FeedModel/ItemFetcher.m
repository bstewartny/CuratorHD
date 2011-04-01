//
//  ItemFetcher.m
//  Untitled
//
//  Created by Robert Stewart on 8/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ItemFetcher.h"
#import <CoreData/CoreData.h>
#import "FeedItemDictionary.h"

@implementation ItemFetcher
@synthesize delegate,managedObjectContext;

- (void) performFetch
{
	//NSLog(@"[ItemFetcher performFetch]");
	NSError *error = nil;
	
	[[self fetchedResultsController] performFetch:&error];
	if(error)
	{
		NSLog(@"Failed to retrieve results: %@",[error localizedDescription]);
	}
}

- (void) moveItemFromIndex:(int)fromIndex toIndex:(int)toIndex
{
	NSLog(@"moveItemFromIndex: %d to %d",fromIndex,toIndex);
	// get item at index
	NSArray * a=[self items];
	
	NSMutableArray * tmp=[NSMutableArray arrayWithArray:a];
	
	id item=[tmp objectAtIndex:fromIndex];
	
	[tmp removeObjectAtIndex:fromIndex];
	
	if(toIndex<fromIndex)
	{
		NSLog(@"insert object at index: %d",toIndex);
		[tmp insertObject:item atIndex:toIndex];
	}
	else 
	{
		NSLog(@"insert object at index: %d",(toIndex));
		[tmp insertObject:item atIndex:toIndex];
	}

	// now renumber from 0...
	int displayOrder=0;
	BOOL needsSaved=NO;
	
	for(id item in tmp)
	{
		
		UIBarButtonSystemItemAdd;
		
		if([item respondsToSelector:@selector(displayOrder)])
		{
			NSNumber * currentOrder=[item displayOrder];
			if([currentOrder intValue]!=displayOrder)
			{
				//NSLog(@"Changing displayOrder form %d to %d",[currentOrder intValue],displayOrder);
				[item setDisplayOrder:[NSNumber numberWithInt:displayOrder]];
				needsSaved=YES;
			}
		}
		displayOrder++;
	}
	
	if(needsSaved)
	{
		[self save];
	}
}
/*
- (NSManagedObject*) newItem
{
	NSLog(@"You must implement newItem in sub-class!!!");
}*/

- (NSArray*) items
{
	//NSLog(@"[ItemFetcher items]");
	[self performFetch];
	//return [[self fetchedResultsController] fetchedObjects];
	return [NSArray arrayWithArray:[[self fetchedResultsController] fetchedObjects]];
}
/*
- (void) addItem:(id)item
{
	NSManagedObject * newObj = [self newItem];
	
	// move item props to new obj
	[self setManagedObjectAttributes:item managedObject:newObj];
	
	[self save];
}*/
/*

- (void) addItems:(NSArray*)items
{
	for(id item in items)
	{
		NSManagedObject * newObj = [self newItem];
		
		// move item props to new obj
		[self setManagedObjectAttributes:item managedObject:newObj];
	}
	
	[self save];
}
*//*
- (void) setManagedObjectAttributes:(id)item managedObject:(NSManagedObject*)obj	
{
	[obj setValue:[item headline] forKey:@"headline"];
	[obj setValue:[item date] forKey:@"date"];
	[obj setValue:[item synopsis] forKey:@"synopsis"];
	[obj setValue:[item origSynopsis] forKey:@"origSynopsis"];
	[obj setValue:[item origin] forKey:@"origin"];
	[obj setValue:[item originId] forKey:@"originId"];
	[obj setValue:[item originUrl] forKey:@"originUrl"];
	[obj setValue:[item image] forKey:@"image"];
	[obj setValue:[item imageUrl] forKey:@"imageUrl"];
	[obj setValue:[item notes] forKey:@"notes"];
	[obj setValue:[item url] forKey:@"url"];
}*/

- (id) itemAtIndex:(int)index
{
	NSManagedObject * obj=[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

	return obj;
}

- (int) count
{
	//NSLog(@"[ItemFetcher count]");
	id <NSFetchedResultsSectionInfo> sectionInfo = nil;
	sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:0];
	return [sectionInfo numberOfObjects];
}

- (void) deleteItemAtIndex:(int)index
{
	// Delete the managed object for the given index path
	NSManagedObjectContext *context = [self managedObjectContext];
	[context deleteObject:[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]]];
	[self save];
}

- (void) save
{
	NSManagedObjectContext *context = [self managedObjectContext];
	// Save the context.
	NSError *error = nil;
	if(![context save:&error])
	{
		if(error)
		{
			NSLog(@"Error saving context in ItemFetcher.save: %@",[error userInfo]);
		}
	}
}

- (void) deleteAllItems
{
	NSManagedObjectContext *context = [self managedObjectContext];
	int count=[self count];
	for(int i=0;i<count;i++)
	{
		[context deleteObject:[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]];
	}
	[self save];
}

- (NSManagedObject*) fetchSingleObject:(NSString*)entityName predicate:(NSPredicate*)predicate
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setPredicate:predicate];
	
	NSArray * results=[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];
	
	NSManagedObject * obj=nil;
	
	if([results count]>0)
	{
		obj= [results objectAtIndex:0];
	}
	
	[fetchRequest release], fetchRequest = nil;
	
	return obj;
}

- (NSFetchedResultsController*)createFetchedResultsController:(NSString*)entityName predicate:(NSPredicate*)predicate sortDescriptors:(NSArray*)sortDescriptors 
{
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];// autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName 
											  inManagedObjectContext:[self managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setFetchBatchSize:0];
	
	if(predicate)
	{
		[fetchRequest setPredicate:predicate];
	}	
	
	if(sortDescriptors)
	{
		[fetchRequest setSortDescriptors:sortDescriptors];
	}
	
	return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																   managedObjectContext:[self managedObjectContext] 
																	 sectionNameKeyPath:nil 
																			  cacheName:nil];
}

- (NSFetchedResultsController*)fetchedResultsController 
{
	NSLog(@"You must implement fetchedResultsController in sub-class!!!");
	return nil;
}    

- (NSManagedObjectContext*) managedObjectContext 
{
	if(managedObjectContext==nil)
	{
		managedObjectContext= [[[[UIApplication sharedApplication] delegate] managedObjectContext] retain];
	}
	
	return managedObjectContext;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller 
{
	[delegate willChangeItems];
}

- (void)controller:(NSFetchedResultsController*)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath*)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath*)newIndexPath 
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
			
			[delegate didInsertItemAtIndex:newIndexPath.row];
			break;
		case NSFetchedResultsChangeDelete:
			[delegate didDeleteItemAtIndex:indexPath.row];
			break;
		case NSFetchedResultsChangeUpdate:
			[delegate didUpdateItemAtIndex:indexPath.row];
			break;
		case NSFetchedResultsChangeMove:
			[delegate didMoveItemAtIndex:indexPath.row newIndex:newIndexPath.row];
		break;
	}  
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller 
{
	[delegate didChangeItems];
} 

- (NSManagedObjectID *) getObjectForURL:(NSURL*)url
{
	NSManagedObjectContext * moc=[[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSPersistentStoreCoordinator * psc=[[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
	@try {
		// get item 
		NSManagedObjectID * objid=[psc managedObjectIDForURIRepresentation:url];
		if(objid)
		{
			NSError * error=nil;
			NSManagedObject * obj=[moc existingObjectWithID:objid error:&error];
			
			if(obj)
			{
				return obj;
			}
		}
	}
	@catch (NSException * e) {
		// remove this one from array/map
		
	}
	@finally {
		
	}
	return nil;
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		//[decoder decodeObjectForKey:@"array"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	//[encoder encodeObject:array forKey:@"array"];
}

- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}

@end

@implementation FeedItemFetcher:ItemFetcher
@synthesize feed;
/*
- (NSManagedObject*) newItem
{
	NSManagedObject * newObj= [NSEntityDescription insertNewObjectForEntityForName:@"RssFeedItem" inManagedObjectContext:[self managedObjectContext]];

	[newObj setFeed:self.feed];

	return newObj;
}
*/
- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"feed == %@", feed];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" 
																   ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"RssFeedItem"  predicate:predicate sortDescriptors:sortDescriptors];
	[fetchedResultsController.fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"url",@"headline",@"isRead",@"origin",@"originId",@"date",nil]];
	
	[fetchedResultsController.fetchRequest setFetchLimit:500];
	
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
		
		self.feed=[self getObjectForURL:uri];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	NSURL * uri=[[feed  objectID] URIRepresentation];
	
	[encoder encodeObject:uri forKey:@"uri"];
}

- (void) dealloc
{
	[feed release];
	[super dealloc];
}

@end

@implementation FolderItemFetcher:ItemFetcher
@synthesize folder;
/*
- (NSManagedObject*) newItem
{
	NSManagedObject * newObj= [NSEntityDescription insertNewObjectForEntityForName:@"FolderItem" inManagedObjectContext:[self managedObjectContext]];
	[newObj setFolder:folder];
	
	return newObj;
}*/

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"folder == %@", folder];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" 
																   ascending:YES];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		
	fetchedResultsController=[self createFetchedResultsController:@"FolderItem"  predicate:predicate sortDescriptors:sortDescriptors];

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
		
		self.folder=[self getObjectForURL:uri];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	NSURL * uri=[[folder  objectID] URIRepresentation];

	[encoder encodeObject:uri forKey:@"uri"];
}


- (void) dealloc
{
	[folder release];
	[super dealloc];
}

@end

@implementation NewsletterItemFetcher:ItemFetcher
@synthesize section;
/*
- (NSManagedObject*) newItem
{
	NSManagedObject * newObj= [NSEntityDescription insertNewObjectForEntityForName:@"NewsletterItem" inManagedObjectContext:[self managedObjectContext]];
	
	[newObj	setSection:section];
	
	return newObj;
}*/

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"section == %@", section];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" 
																   ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		
	fetchedResultsController=[self createFetchedResultsController:@"NewsletterItem"  predicate:predicate sortDescriptors:sortDescriptors];

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
		
		self.section=[self getObjectForURL:uri];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	NSURL * uri=[[section  objectID] URIRepresentation];
	
	[encoder encodeObject:uri forKey:@"uri"];
}
- (void) dealloc
{
	[section release];
	[super dealloc];
}

@end

@implementation FeedItemDictionaryFetcher
@synthesize dictionary;

- (void) performFetch
{
}

- (id) itemAtIndex:(int)index
{
	return [dictionary itemAtIndex:index];
}

- (NSArray*) items
{
	return [dictionary items];
}

- (int) count
{
	return [dictionary count];
}

- (void) deleteItemAtIndex:(int)index
{
	[dictionary removeItemAtIndex:index];
}

- (void) addItem:(id)item
{
	[dictionary addObject:item];
}

- (void) deleteAllItems
{
	[dictionary removeAllItems];
}

- (void) save
{
}

- (void) dealloc
{
	[dictionary release];
	[super dealloc];
}

@end


@implementation ArrayFetcher
@synthesize array;

- (void) performFetch
{
}

- (id) itemAtIndex:(int)index
{
	return [array objectAtIndex:index];
}

- (NSArray*) items
{
	return array;
}

- (int) count
{
	return [array count];
}

- (void) deleteItemAtIndex:(int)index
{
	 
	[array removeObjectAtIndex:index];
}

- (void) addItem:(id)item
{
	[array addObject:item];
}

- (void) deleteAllItems
{
	[array removeAllObjects];
}

- (void) save
{
}

- (void) dealloc
{
	[array release];
	[super dealloc];
}
@end

@implementation CategoryItemFetcher
@synthesize accountName,feedCategory;

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"feed.account.name == %@ AND (ANY feed.feedCategory.name==%@)", accountName,feedCategory];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" 
																   ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"RssFeedItem"  predicate:predicate sortDescriptors:sortDescriptors];
	[fetchedResultsController.fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"url",@"headline",@"isRead",@"origin",@"originId",@"date",nil]];
	
	[fetchedResultsController.fetchRequest setFetchLimit:500];
	
	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release], sortDescriptor = nil;
	[sortDescriptors release], sortDescriptors = nil;
	
	return fetchedResultsController;
}    
@implementation SharedItemFetcher
@synthesize accountName;

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"feed.account.name == %@ AND isShared==1", accountName];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" 
																   ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"RssFeedItem"  predicate:predicate sortDescriptors:sortDescriptors];
	[fetchedResultsController.fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"url",@"headline",@"isRead",@"origin",@"originId",@"date",nil]];
	
	[fetchedResultsController.fetchRequest setFetchLimit:500];
	
	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release], sortDescriptor = nil;
	[sortDescriptors release], sortDescriptors = nil;
	
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
@implementation StarredItemFetcher
@synthesize accountName;

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"feed.account.name == %@ AND isStarred==1", accountName];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" 
																   ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"RssFeedItem"  predicate:predicate sortDescriptors:sortDescriptors];
	[fetchedResultsController.fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"url",@"headline",@"isRead",@"origin",@"originId",@"date",nil]];
	
	[fetchedResultsController.fetchRequest setFetchLimit:500];
	
	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release], sortDescriptor = nil;
	[sortDescriptors release], sortDescriptors = nil;
	
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

@implementation AccountItemFetcher
@synthesize accountName,feedType;

- (NSFetchedResultsController*)fetchedResultsController 
{
	if (fetchedResultsController) return fetchedResultsController;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"feed.account.name == %@ AND feed.feedType == %@", accountName,feedType];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" 
																   ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	fetchedResultsController=[self createFetchedResultsController:@"RssFeedItem"  predicate:predicate sortDescriptors:sortDescriptors];
	
	[fetchedResultsController.fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"url",@"headline",@"isRead",@"origin",@"originId",@"date",nil]];
	
	
	[fetchedResultsController.fetchRequest setFetchLimit:500];
	
	[fetchedResultsController setDelegate:self];
	
	[sortDescriptor release], sortDescriptor = nil;
	[sortDescriptors release], sortDescriptors = nil;
	
	return fetchedResultsController;
}    
- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.accountName=[decoder decodeObjectForKey:@"accountName"];
		self.feedType=[decoder decodeObjectForKey:@"feedType"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:accountName forKey:@"accountName"];
	[encoder encodeObject:feedType forKey:@"feedType"];
}

- (void) dealloc
{
	[accountName release];
	[feedType release];
	[super dealloc];
}
@end


