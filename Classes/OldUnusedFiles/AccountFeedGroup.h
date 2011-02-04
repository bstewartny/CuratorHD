//
//  AccountFeedGroup.h
//  Untitled
//
//  Created by Robert Stewart on 6/10/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedGroup.h"
@class FeedAccount;

@interface AccountFeedGroup : FeedGroup {
	FeedAccount * account;
}
 
@property(nonatomic,retain) FeedAccount * account;

- (NSArray *) getFeedsForAccount;

@end
