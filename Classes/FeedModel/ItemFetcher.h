//
//  ItemFetcher.h
//  Untitled
//
//  Created by Robert Stewart on 8/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RssFeed;
@class Folder;
@class Newsletter;
@class NewsletterSection;
@class FeedItemDictionary;
@protocol ItemFetcherDelegate
@optional

- (void) willChangeItems;
- (void) didInsertItemAtIndex:(int)index;
- (void) didDeleteItemAtIndex:(int)index;
- (void) didUpdateItemAtIndex:(int)index;
- (void) didMoveItemAtIndex:(int)index newIndex:(int)newIndex;
- (void) didChangeItems;

@end

@interface ItemFetcher : NSObject <NSCoding> {
	id<ItemFetcherDelegate> delegate;
	NSManagedObjectContext * managedObjectContext;
	NSFetchedResultsController * fetchedResultsController;
}
@property(nonatomic,retain) NSManagedObjectContext * managedObjectContext;
@property(nonatomic,assign) id<ItemFetcherDelegate> delegate;

- (void) performFetch;

- (id) itemAtIndex:(int)index;

- (NSArray*) items;

- (int) count;

- (void) deleteItemAtIndex:(int)index;

- (void) addItem:(id)item;

- (void) moveItemFromIndex:(int)fromIndex toIndex:(int)toIndex;

- (void) deleteAllItems;

- (void) save;

@end

@interface FeedItemFetcher : ItemFetcher
{
	RssFeed * feed;
	//NSString * feedName;
	//NSString * feedUrl;
	//NSString * feedType;
}
@property(nonatomic,retain) RssFeed * feed;
//@property(nonatomic,retain) NSString * feedUrl;
//@property(nonatomic,retain) NSString * feedType;

@end

@interface FolderItemFetcher : ItemFetcher
{
	Folder * folder;
	//NSString * folderName;
}
@property(nonatomic,retain) Folder * folder;
@end

@interface NewsletterItemFetcher : ItemFetcher
{
	NewsletterSection * section;
	//NSString * newsletterName;
	//NSString * sectionName;
}
@property(nonatomic,retain) NewsletterSection * section;
//@property(nonatomic,retain) NSString * sectionName;
@end

@interface FeedItemDictionaryFetcher:ItemFetcher
{
	FeedItemDictionary  * dictionary;
}
@property(nonatomic,retain) FeedItemDictionary  * dictionary;
@end
@interface ArrayFetcher:ItemFetcher
{
	NSMutableArray * array;
}
@property(nonatomic,retain) NSMutableArray * array;

@end

@interface CategoryItemFetcher : ItemFetcher {
	NSString * accountName;
	NSString * feedCategory;
}

@property(nonatomic,retain) NSString * accountName;
@property(nonatomic,retain) NSString * feedCategory;

@end

@interface SharedItemFetcher : ItemFetcher {
	NSString * accountName;
}

@property(nonatomic,retain) NSString * accountName;

@end

@interface StarredItemFetcher : ItemFetcher {
	NSString * accountName;
}

@property(nonatomic,retain) NSString * accountName;

@end

@interface AccountItemFetcher : ItemFetcher {
	NSString * accountName;
	NSString * feedType;
}

@property(nonatomic,retain) NSString * accountName;
@property(nonatomic,retain) NSString * feedType;


@end