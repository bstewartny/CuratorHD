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

@interface SearchClient : NSObject {
	NSString * serverUrl;
	NSString * username;
	NSString * password;
}
@property(nonatomic,retain) NSString * serverUrl;
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;

- (id) initWithServer:(NSString*)url withUsername:(NSString*)theusername withPassword:(NSString*) thepassword;
- (NSData *) loadDataFromURLForcingBasicAuth:(NSURL *)url;

- (SearchResults*) search:(SearchArguments*) args;
- (SearchResults *) search2:(SearchArguments *) args;
- (NSMutableArray*) getSavedSearchesForUser;
- (NSString *)urlEncodeValue:(NSString *)str;

@end
