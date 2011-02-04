//
//  NewsletterAPI.h
//  Untitled
//
//  Created by Robert Stewart on 4/12/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UrlParams;

@interface NewsletterClient : NSObject {
	NSString * baseURI;
	NSString * ticket;
	NSString * username;
	NSString * password;
	//NSMutableDictionary * metaNameCache;
}

@property(nonatomic,retain) NSString * baseURI;
@property(nonatomic,retain) NSString * username;
@property(nonatomic,retain) NSString * password;
@property(nonatomic,retain) NSString * ticket;
//@property(nonatomic,retain) NSMutableDictionary * metaNameCache;

- (NSString *) loginWithUsername:(NSString*)username password:(NSString*)password;

- (NSArray*) getSavedSearches;

- (NSArray*) getNewsletters;

//- (BOOL) addMessageToNewsletter:(NSString*)newsletterID searchID:(NSString*)searchID ....;

//- (BOOL) deleteMessageFromNewsletter:(NSString*)newsletterID searchID:(NSString*)searchID ....;

//- (BOOL) deleteNewsletter:(NSString*)newsletterID;

//- (NSArray*) getNewsletterSections:(NSString*)newsletterID;

//- (NSArray*) getNewsletterItems:(NSString*)newsletterID searchID:(NSString*)searchID;

//- (BOOL) addSearchToNewsletter:(NSString*)newsletterID searchID:(NSString*)searchID;

//- (NSObject*) getNewsletter:(NSString*)newsletterID;

//- (BOOL) reorderMessages:(NSString*)newsletterID searchID:(NSString*)searchID messages:(NSArray*)messages;

//- (NSArray*) search:(NSString*)searchID query:(NSString*)query pageNumber:(int)pageNumber pageSize:(int)pageSize;

//- (NSDictionary*) resolveMetaValues:(NSArray*)keyValuePairs;

//- (NSArray*) getMetaNames;

- (NSData*) postData:(NSString*)relativeURI params:(UrlParams*)params;
- (NSData*) getData:(NSString*)relativeURI;
//- (void) ResolveMetaNames:(NSArray*)metadata useRemoteIfNotInCache:(BOOL)useRemote;

@end
