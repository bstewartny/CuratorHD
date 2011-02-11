//
//  NewsletterSection.m
//  Untitled
//
//  Created by Robert Stewart on 2/25/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "NewsletterSection.h"
#import "FeedItem.h"
#import "ItemFetcher.h"
#import "NewsletterItem.h"
#import "Newsletter.h"

@implementation NewsletterSection

@dynamic newsletter;

- (ItemFetcher*) itemFetcher
{
	NewsletterItemFetcher * itemFetcher=[[NewsletterItemFetcher alloc] init];
	itemFetcher.section=self;
	//itemFetcher.newsletterName=self.newsletter.name;
	//itemFetcher.sectionName=self.name;
	
	return [itemFetcher autorelease];
}

- (int) itemCount
{
	return [self entityCount:@"NewsletterItem" predicate:[NSPredicate predicateWithFormat:@"section==%@",self]];
}

- (BOOL) editable
{
	return YES;
}

- (NewsletterItem*) addItem
{
	NewsletterItem * newItem = [NSEntityDescription insertNewObjectForEntityForName:@"NewsletterItem" inManagedObjectContext:[self managedObjectContext]];
	
	newItem.section=self;
	
	//int numItems=[self.items count];
	int numItems=[self entityCount:@"NewsletterItem" predicate:[NSPredicate predicateWithFormat:@"section==%@",self]];
	
	NSLog(@"Adding item with displayOrder: %d",numItems);
	
	newItem.displayOrder=[NSNumber numberWithInt:numItems];
	
	return newItem;
}

- (NewsletterItem*) addFeedItem:(FeedItem*)item
{
	NewsletterItem * newItem=[self addItem];
	[newItem copyAttributes:item];
	
	int maxSynopsisLength=[[[UIApplication sharedApplication] delegate] maxNewsletterSynopsisLength];
	
	if(maxSynopsisLength>0)
	{
		// generate normalized synopsis...
		if (newItem.synopsis==nil || [newItem.synopsis length]==0 || ([newItem.synopsis length]<maxSynopsisLength))
		{
			newItem.synopsis=[newItem.origSynopsis flattenHTML];
		}
		
		if([newItem.synopsis length]>maxSynopsisLength)
		{
			newItem.synopsis=[[newItem.synopsis substringToIndex:maxSynopsisLength] stringByAppendingString:@"..."];
		}
	}
	else 
	{
		newItem.synopsis=nil;
	}
	
	return newItem;
}


@end
