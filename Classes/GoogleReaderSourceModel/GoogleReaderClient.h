//
//  GoogleReaderClient.h
//  Untitled
//
//  Created by Robert Stewart on 5/18/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#define kGoogleReaderClientName @"InfoNgen-iPad/0.1"
#define kGoogleReaderMaxNumberOfItems 50

#import <Foundation/Foundation.h>
@class ItemFilter;
//@class FeedAccount;
@class FeedItem;
typedef enum {
	GoogleReaderFeedTypeAllItems = 0,
	GoogleReaderFeedTypeSharedItems,
	GoogleReaderFeedTypeStarredItems,
	GoogleReaderFeedTypeTaggedItems,
	GoogleReaderFeedTypeFriendsSharedItems,
	GoogleReaderFeedTypeFollowingItems,
	GoogleReaderFeedTypeNotes
} GoogleReaderFeedType;

@interface GoogleReaderClient : NSObject {
	
	//FeedAccount * account;
	NSString * username;
	NSString * password;
}
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;
//@property(nonatomic,retain) NSString * token;
//@property(nonatomic,retain) NSString * auth;
//@property(nonatomic,retain) FeedAccount * account;


- (BOOL) isValid;

//- (id) initWithAccount:(FeedAccount*)account;
- (id) initWithUsername:(NSString*)username password:(NSString*)password;

- (id) initWithUsername:(NSString*)username password:(NSString*)password useCachedAuth:(BOOL)useCachedAuth;

- (NSArray*) getSubscriptionList:(NSMutableDictionary*)imageCache;

- (NSArray*) getTags;

//- (NSArray*) getFeedUnreadCounts;

- (NSArray*) getItems:(GoogleReaderFeedType)feedType tag:(NSString*)tag filter:(ItemFilter*)filter;

- (NSArray*) getFollowingItems:(ItemFilter*)filter;

- (NSArray*) getSharedItems:(ItemFilter*)filter;

- (NSArray*) getStarredItems:(ItemFilter*)filter;
- (NSArray*) getNotes:(ItemFilter*)filter;

- (NSArray*) getAllItems:(ItemFilter*)filter;

- (NSArray*) getTaggedItems:(NSString*)tag filter:(ItemFilter*)filter;

- (void) markAsRead:(FeedItem*)item;

@end
