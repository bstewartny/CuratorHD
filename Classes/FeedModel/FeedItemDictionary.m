//
//  Favorites.m
//  Untitled
//
//  Created by Robert Stewart on 4/27/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//
#import "FeedItemDictionary.h"
#import "FeedItem.h"
#import "ItemFetcher.h"
#import <CoreData/CoreData.h>

@implementation FeedItemDictionary

- (id) init
{
	if ([super init]) 
	{
		map=[[NSMutableDictionary alloc] init];
		array=[[NSMutableArray alloc] init];
	}
	return self;
}

- (int) count
{
	return [[self items] count];
	//return [array count];
}

- (BOOL) containsItem:(FeedItem*)item
{
	if(item==nil) return NO;
	
	NSURL * key = [[item objectID] URIRepresentation];
	
	return ([map objectForKey:key]!=nil);
}

- (void) removeItem:(FeedItem*)item
{
	if(item==nil) return;
	
	NSURL * key = [[item objectID] URIRepresentation];
	
	[map removeObjectForKey:key];
	[array removeObject:key];
}

- (void) removeItemAtIndex:(int)index
{
	if(index<[array count])
	{
		NSURL * key=[array objectAtIndex:index];
	
		[map removeObjectForKey:key];
		[array removeObjectAtIndex:index];
	}
}

- (FeedItem*) itemAtIndex:(int)index
{
	if(index<[array count])
	{
		NSURL * key=[array objectAtIndex:index];
	
		return (FeedItem*)[self getObjectForURL:key];
	}
	else 
	{
		return nil;
	}
}

- (void) addItem:(FeedItem*)item
{
	NSURL * key = [[item objectID] URIRepresentation];
	
	if(![map objectForKey:key])
	{
		[array addObject:key];
		[map setObject:key forKey:key];
	}
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

- (NSArray*) items
{
	NSMutableArray * tmp=[NSMutableArray new];
	
	NSMutableArray * toRemove=[NSMutableArray new];
	
	for(NSURL * key in array)
	{
		NSManagedObject * obj=[self getObjectForURL:key];
		
		if(obj)
		{
			[tmp addObject:obj];
			 
		}
		else 
		{
			[toRemove addObject:key];
		}
	}
	
	for(NSURL * key in toRemove)
	{
		[array removeObject:key];
		[map removeObjectForKey:key];
	}
	
	
	[toRemove release];
	return [tmp autorelease];
}

- (ItemFetcher*) itemFetcher
{
	FeedItemDictionaryFetcher * fetcher=[[FeedItemDictionaryFetcher alloc] init];
	fetcher.dictionary=self;
	return [fetcher autorelease];
}

- (void) removeAllItems
{
	[array removeAllObjects];
	[map removeAllObjects];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		map=[[NSMutableDictionary alloc] init];
		array=[[decoder decodeObjectForKey:@"array"] retain];
		for (NSURL * key in array )
		{
			[map setObject:key forKey:key];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:array forKey:@"array"];
}

-(void) dealloc
{
	[map release];
	[array release];
	[super dealloc];
}
@end
