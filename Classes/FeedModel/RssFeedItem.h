//
//  RssFeedItem.h
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

@class RssFeed;

@interface RssFeedItem : FeedItem {

}
@property(nonatomic,retain) RssFeed * feed;

@end
