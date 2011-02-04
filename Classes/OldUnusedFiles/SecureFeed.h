//
//  SecureFeed.h
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
@class FeedAccount;

@interface SecureFeed : Feed {
	FeedAccount * account;
}
@property(nonatomic,retain) FeedAccount * account;

- (id) initWithAccount:(FeedAccount*)account;

@end
