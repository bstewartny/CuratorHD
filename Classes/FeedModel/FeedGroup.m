//
//  FeedGroup.m
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FeedGroup.h"
#import "Feed.h"
#import "FeedItem.h"
#import "ItemFilter.h"
#import "FeedFetcher.h"

@implementation FeedGroup
@synthesize name,image,editable; // feeds,editable;

- (ItemFetcher*)feedFetcher
{
	// override in sub-class
}

/*
- (id) init
{
	if([super init])
	{
		feeds=[[NSMutableArray alloc] init];
		queue=[[NSOperationQueue alloc] init];
		
		[queue setMaxConcurrentOperationCount:4];
	}
	return self;
}

- (void) doCancelUpdate
{
	NSLog(@"FeedGroup.doCancelUpdate");
	[queue cancelAllOperations];
}

- (void) updateWithFilter:(ItemFilter*)filter
{
	updateFilter=filter;
	
	if(queue==nil)
	{
		queue=[[NSOperationQueue alloc] init];
		
		[queue setMaxConcurrentOperationCount:4];
	}
	
	for (Feed * feed in feeds)
	{
		if(updateCancelled) return;
		
		NSInvocationOperation * op=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateFeed:) object:feed];
		 
		[queue addOperation:op];
		
		[op release];
	}
	
	if(updateCancelled) return;
	
	[queue waitUntilAllOperationsAreFinished];
}

- (void) updateFeed:(Feed*)feed
{
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateStatus"
	 object:[NSString stringWithFormat:@"Updating \"%@\"...",feed.name]];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateStart"
	 object:feed];
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[feed updateWithFilter:updateFilter];
	
	[pool drain];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:@"UpdateComplete"
	 object:feed];	
}

- (void) addItems:(NSArray*)newItems withFilter:(ItemFilter*)filter
{
}

- (NSArray*) getNewItems
{
	return nil;
}

- (BOOL) containsItem:(FeedItem*)item
{
	return NO;
}

- (void) removeItem:(FeedItem*)item
{	 
}

- (void) addItem:(FeedItem*)item
{	
}

- (NSArray*) items
{
	NSMutableArray * tmp=[NSMutableArray new];
	
	ItemFilter * filter=[[ItemFilter alloc] init];
	
	for(Feed * feed in self.feeds)
	{
		for(FeedItem * item in feed.items)
		{
			if([filter isNewItem:item])
			{
				[tmp addObject:item];
				[filter rememberItem:item];
			}
		}
	}
	
	[filter release];
	
	// resort items
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	
	[tmp sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	[sortDescriptor release];
	
	return [tmp autorelease];
}

- (void) setItems:(NSArray*)items
{
	// do nothing... we cant set items at the group level
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:description forKey:@"description"];
	[encoder encodeObject:feeds forKey:@"feeds"];
	[encoder encodeObject:lastUpdated forKey:@"lastUpdated"];
	[encoder encodeObject:image forKey:@"image"];
	
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.name=[decoder decodeObjectForKey:@"name"];
		self.description=[decoder decodeObjectForKey:@"description"];
		self.feeds=[decoder decodeObjectForKey:@"feeds"];
		self.lastUpdated=[decoder decodeObjectForKey:@"lastUpdated"];
		self.image=[decoder decodeObjectForKey:@"image"];
		
	}
	return self;
}

-(id)copyWithZone:(NSZone*)zone
{
	FeedGroup * copy=[super copyWithZone:zone];
	 
	copy.feeds=[self.feeds copy];
	
	return copy;
}
*/
- (void) dealloc
{
	[name release];
	[image release];
	[super dealloc];
}
@end


@implementation NewsletterFeedGroup 

- (ItemFetcher*)feedFetcher
{
	
	return [[[NewsletterFetcher alloc] init] autorelease];
}

@end

@implementation FolderFeedGroup 

- (ItemFetcher*)feedFetcher
{
	return [[[FolderFetcher alloc] init] autorelease];
}

@end




