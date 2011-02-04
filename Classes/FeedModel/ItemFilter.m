//
//  ItemFilter.m
//  Untitled
//
//  Created by Robert Stewart on 5/20/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "ItemFilter.h"
#import "FeedItem.h"

@implementation ItemFilter
@synthesize dict,minDate;

- (id) init
{
	if([super init])
	{
		NSMutableDictionary * tmp=[[NSMutableDictionary alloc] init];
		self.dict=tmp;
		[tmp release];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:dict forKey:@"dict"];
	[encoder encodeObject:minDate forKey:@"minDate"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
	if(self==[super init])
	{
		self.dict=[decoder decodeObjectForKey:@"dict"];
		self.minDate=[decoder decodeObjectForKey:@"minDate"];
	}
	return self;
}

- (BOOL) isOldDate:(NSDate*)date
{
	if(self.minDate && date)
	{
		if([date compare:self.minDate]==NSOrderedAscending)
		{
			return YES;
		}
	}
	return NO;
}

- (BOOL) isNewItem:(FeedItem*) item
{
	/*if([self isOldDate:item.date])
	{
		return NO;
	}*/

	if([dict objectForKey:item.key])
	{
		return NO; // we saw this item before
	}
	 	
	return YES;
}
- (BOOL) isUpdated:(FeedItem*) item
{
	FeedItem * existing=[dict objectForKey:item.key];
	if(existing)
	{
		if([item.isRead intValue]==1)
		{
			if([existing.isRead intValue]==0)
			{
				return YES; // item was marked as read on the server
			}
		}
		if([item.isShared intValue]!=[existing.isShared intValue])
		{
			return YES;
		}
		if([item.isStarred intValue]!=[existing.isStarred intValue])
		{
			return YES;
		}
		return NO;
	}
	else 
	{
		return NO;
	}

}
- (FeedItem*) getItem:(FeedItem*) item;
{
	return [dict objectForKey:item.key];
}

- (void) rememberItem:(FeedItem*) item
{
	NSString * key=item.key;
	if(![dict objectForKey:key])
	{
		[dict setObject:item forKey:key];
	}
}

- (void) clear
{
	[self.dict removeAllObjects];
}

- (void) dealloc
{
	[dict release];
	[minDate release];
	[super dealloc];
}

@end
