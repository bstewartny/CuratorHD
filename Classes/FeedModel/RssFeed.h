//
//  RssFeed.h
//  Untitled
//
//  Created by Robert Stewart on 6/11/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
@class FeedAccount;
@class ItemFetcher;

@interface RssFeed : Feed  {
}
@property(nonatomic,retain) NSSet * items;
@property(nonatomic,retain) NSString * lastUpdateHash;
@property(nonatomic,retain) FeedAccount * account;

- (ItemFetcher*) feedFetcher;
- (NSDate*) maxDate;
 
@end
