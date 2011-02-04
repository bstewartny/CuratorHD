//
//  CoreDataFeed.h
//  Untitled
//
//  Created by Robert Stewart on 8/2/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ItemFilter;
@class ItemFetcher;

@interface FeedEx : NSObject 
{
	NSString * name;
	NSString * description;
	NSDate * lastUpdated;
	UIImage * image;
	BOOL updateCancelled;
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSDate * lastUpdated;
@property(nonatomic,retain) UIImage * image;
@property(nonatomic,retain) NSString * description;

- (void) updateWithFilter:(ItemFilter*)filter;

- (void) update;

- (void) addItems:(NSArray*)newItems withFilter:(ItemFilter*)filter;

- (void) resolveFeedImages:(NSMutableDictionary*)imageCache;

- (int) unreadCount;

- (NSArray*) getNewItems;

- (ItemFetcher*) itemFetcher;

@end
