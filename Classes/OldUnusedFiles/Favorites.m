//
//  Favorites.m
//  Untitled
//
//  Created by Robert Stewart on 4/27/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "Favorites.h"
#import "FeedItem.h"

@implementation Favorites
@synthesize map;

- (id) init
{
	if ([super init]) 
	{
		self.map=[[NSMutableDictionary alloc] init];
		self.name=@"Favorites";
	}
	return self;
}

- (BOOL) containsItem:(FeedItem*)item
{
	if(item==nil) return NO;
	if(items==nil) return NO;
	return ([self.map objectForKey:item.key]!=nil);
}

- (void) removeItem:(FeedItem*)item
{
	if(item==nil) return;
	if(items==nil) return;
	[self.map removeObjectForKey:item.key];
	[self.items removeObject:item];
}

- (void) addItem:(FeedItem*)item
{
	if(![self.map objectForKey:item.key])
	{
		[self.items addObject:item];
		[self.map setObject:item forKey:item.key];
	}
}

- (void) removeAllItems
{
	[self.items removeAllObjects];
	[self.map removeAllObjects];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super initWithCoder:decoder])
	{
		self.map=[[NSMutableDictionary alloc] init];
		for (FeedItem * item in self.items)
		{
			[self.map setObject:item forKey:item.key];
		}
	}
	return self;
}

-(void) dealloc
{
	[map release];
	[super dealloc];
}
@end
