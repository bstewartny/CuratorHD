//
//  Folder.m
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "Folder.h"
#import "ItemFetcher.h"
#import "FolderItem.h"

@implementation Folder
@dynamic isFavorite;

+ (Folder*) createInContext:(NSManagedObjectContext*)moc
{
	Folder * newsletter = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:moc];
	return newsletter;
}




- (ItemFetcher*) itemFetcher
{
	FolderItemFetcher * itemFetcher=[[FolderItemFetcher alloc] init];
	itemFetcher.folder=self;
	//itemFetcher.folderName=self.name;
	
	return [itemFetcher autorelease];
}
- (BOOL) editable
{
	return YES;
}

- (FolderItem*) addItem
{
	FolderItem * newItem = [NSEntityDescription insertNewObjectForEntityForName:@"FolderItem" inManagedObjectContext:[self managedObjectContext]];
	
	newItem.folder=self;
	
	int numItems=[self entityCount:@"FolderItem" predicate:[NSPredicate predicateWithFormat:@"folder==%@",self]];
	
	//int numItems=[self.items count];
	
	NSLog(@"Adding item with displayOrder: %d",numItems);
	
	newItem.displayOrder=[NSNumber numberWithInt:numItems];
	
	return newItem;
}

- (FolderItem*) addFeedItem:(FeedItem*)item
{
	FolderItem * newItem=[self addItem];
	[newItem copyAttributes:item];
	return newItem;
}

@end
