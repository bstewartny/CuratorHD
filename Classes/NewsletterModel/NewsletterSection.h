//
//  NewsletterSection.h
//  Untitled
//
//  Created by Robert Stewart on 2/25/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedFeed.h"

@class FeedItem;
@class NewsletterItem;
@class Newsletter;

@interface NewsletterSection : OrderedFeed {
}
@property(nonatomic,retain) Newsletter * newsletter;
 
- (NSArray*) sortedItems;
- (NewsletterItem *) addItem;

@end
