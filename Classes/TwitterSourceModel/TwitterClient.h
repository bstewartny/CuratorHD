//
//  TwitterClient.h
//  Untitled
//
//  Created by Robert Stewart on 11/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHKTwitter.h"

@interface TwitterClient : SHKTwitter {
	NSData * responseData;
	NSString * userId;
	NSString * screenName;
	NSString * username;
	NSString * password;
	id verifyDelegate;
}
@property(nonatomic,retain) NSString * userId;
@property(nonatomic,retain) NSString * screenName;
@property(nonatomic,assign) id verifyDelegate;
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;
- (NSArray*) getLists;
- (NSArray*) getMostRecentListItems:(NSString*)list maxItems:(int)maxItems sinceId:(NSString*)sinceId;
- (NSArray*) getMostRecentListItemsByUrl:(NSString*)url maxItems:(int)maxItems sinceId:(NSString*)sinceId;
- (NSArray*) getMostRecentMentions:(int)maxItems sinceId:(NSString*)sinceId;
- (NSArray*) getMostRecentHomeTimeline:(int)maxItems sinceId:(NSString*)sinceId;
- (NSArray*) getMostRecentFriendsTimeline:(int)maxItems sinceId:(NSString*)sinceId;
- (NSArray*) getMostRecentDirectMessages:(int)maxItems sinceId:(NSString*)sinceId;
- (NSArray*) getMostRecentFavorites:(int)maxItems sinceId:(NSString*)sinceId;

- (NSArray*) getMoreOldListItems:(NSString*)list maxItems:(int)maxItems maxId:(NSString*)maxId;
- (NSArray*) getMoreOldListItemsByUrl:(NSString*)url maxItems:(int)maxItems maxId:(NSString*)maxId;
- (NSArray*) getMoreOldMentions:(int)maxItems maxId:(NSString*)maxId;
- (NSArray*) getMoreOldHomeTimeline:(int)maxItems maxId:(NSString*)maxId;
- (NSArray*) getMoreOldFriendsTimeline:(int)maxItems maxId:(NSString*)v;
- (NSArray*) getMoreOldDirectMessages:(int)maxItems maxId:(NSString*)maxId;
- (NSArray*) getMoreOldFavorites:(int)maxItems maxId:(NSString*)maxId;



- (void) addToFavorites:(NSString*)tweetId;
- (void) retweet:(NSString*)tweetId;


@end
