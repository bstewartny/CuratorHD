//
//  Folder.h
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedFeed.h"

@class FolderItem;
@class FeedItem;

@interface Folder : OrderedFeed {
	
}
@property(nonatomic,retain) NSNumber * isFavorite;
 
- (FolderItem*) addItem;
- (FolderItem*) addFeedItem:(FeedItem*)item;
+ (Folder*) createInContext:(NSManagedObjectContext*)moc;

@end
