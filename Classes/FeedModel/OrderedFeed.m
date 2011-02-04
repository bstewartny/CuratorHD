//
//  OrderedFeed.m
//  Untitled
//
//  Created by Robert Stewart on 8/6/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "OrderedFeed.h"

@implementation OrderedFeed
@dynamic items,displayOrder;

- (NSArray*) sortedItems
{
	// get in display order	
	return [[self itemFetcher] items];
}




/*
- (NSArray *)itemsUsingFetchPredicate:(NSPredicate *)fetchPredicate
{
	return [[self.items filteredSetUsingPredicate:fetchPredicate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES ]     ]];
	 
}

- (NSArray *)itemsWithDisplayOrder:(int)value
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"displayOrder == %i", value];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (NSArray *)itemsWithNonTemporaryDisplayOrder
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"displayOrder >= 0"];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (NSArray *)itemsWithDisplayOrderGreaterThanOrEqualTo:(int)value
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"displayOrder >= %i", value];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (NSArray *)itemsWithDisplayOrderBetween:(int)lowValue and:(int)highValue
{
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"displayOrder >= %i && displayOrder <= %i", lowValue, highValue];
	
	return [self itemsUsingFetchPredicate:fetchPredicate];
}

- (int)renumberDisplayOrdersOfItems:(NSArray *)array startingAt:(int)value
{
	int currentViewPosition = value;
	
	int count = 0;
	
	if( array && ([array count] > 0) )
	{
		for( count = 0; count < [array count]; count++ )
		{
			NSManagedObject *currentObject = [array objectAtIndex:count];
			[currentObject setValue:[NSNumber numberWithInt:currentViewPosition] forKey:@"displayOrder"];
			currentViewPosition++;
		}
	}
	
	return currentViewPosition;
}

- (void)renumberDisplayOrders
{
	NSArray *startItems = [self itemsWithDisplayOrder:startViewPosition];
	
	NSArray *existingItems = [self itemsWithNonTemporaryDisplayOrder];
	
	NSArray *endItems = [self itemsWithDisplayOrder:endViewPosition];
	
	int currentDisplayOrder = 0;
	
	if( startItems && ([startItems count] > 0) )
		currentDisplayOrder = [self renumberDisplayOrdersOfItems:startItems startingAt:currentDisplayOrder];
	
	if( existingItems && ([existingItems count] > 0) )
		currentDisplayOrder = [self renumberDisplayOrdersOfItems:existingItems startingAt:currentDisplayOrder];
	
	if( endItems && ([endItems count] > 0) )
		currentDisplayOrder = [self renumberDisplayOrdersOfItems:endItems startingAt:currentDisplayOrder];
}*/

@end
