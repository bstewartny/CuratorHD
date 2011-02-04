//
//  AccountUpdater.h
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FeedAccount;
@class RssFeed;
@class NSManagedObjectContext;
@interface AccountUpdater : NSObject {
	FeedAccount * account;
	NSArray * iterations;
}

@property(nonatomic,retain) FeedAccount * account;
@property(nonatomic,retain) NSArray* iterations;
- (id) initWithAccount:(FeedAccount*)account;

- (BOOL) updateFeedListWithContext:(NSManagedObjectContext*)moc;

- (BOOL) updateFeed:(RssFeed*)feed withContext:(NSManagedObjectContext*)moc;
- (BOOL) backFillFeed:(RssFeed*)feed withContext:(NSManagedObjectContext*)moc;

- (NSArray*) getMostRecentItems:(RssFeed*)feed maxItems:(int)maxItems;

- (NSArray*) getMoreOldItems:(RssFeed *)feed maxItems:(int)maxItems;

//- (int) numIterations;
//- (int) maxItemsForIteration:(int)iteration;

- (void) willUpdateFeeds:(NSManagedObjectContext*)moc;
- (BOOL) isAccountValid;

- (void) authorize;

@end

