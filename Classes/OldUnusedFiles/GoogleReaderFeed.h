//
//  GoogleReaderFeed.h
//  Untitled
//
//  Created by Robert Stewart on 5/20/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecureFeed.h"
#import "GoogleReaderClient.h"

@class FeedAccount;

@interface GoogleReaderFeed : SecureFeed {
	NSString * tag;
	GoogleReaderFeedType feedType;
}
@property(nonatomic,retain) NSString * tag;

- (id) initWithAccount:(FeedAccount*)account type:(GoogleReaderFeedType)readerFeedType tag:(NSString*)tagName;

@end
