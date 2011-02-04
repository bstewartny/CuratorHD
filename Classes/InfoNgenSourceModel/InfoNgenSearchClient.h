//
//  SearchClient.h
//  InfoNgen-Basic
//
//  Created by Robert Stewart on 2/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchResults.h"
#import "SearchArguments.h"

#define kDefaultInfoNgenServerURL @"http://sa.infongen.com"
 
@class FeedAccount;

@interface InfoNgenSearchClient : NSObject {
	NSString * serverUrl;
	FeedAccount * account;
//	NSString * username;
//	NSString * password;
}
@property(nonatomic,retain) NSString * serverUrl;
@property(nonatomic,retain) FeedAccount * account;

- (id) initWithServer:(NSString*)url account:(FeedAccount*)account;

//- (NSData *) loadDataFromURLForcingBasicAuth:(NSURL *)url;

- (SearchResults*) search:(SearchArguments*) args;

//- (SearchResults *) search2:(SearchArguments *) args;

//- (NSMutableArray*) getSavedSearchesForUser;

- (NSMutableArray*) getSavedSearchesForAccount:(FeedAccount*)account imageCache:(NSMutableDictionary*)imageCache;

//- (NSString *)urlEncodeValue:(NSString *)str;

@end
