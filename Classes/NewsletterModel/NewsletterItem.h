//
//  NewsletterItem.h
//  Untitled
//
//  Created by Robert Stewart on 8/3/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

@class NewsletterSection;

@interface NewsletterItem : FeedItem	{

}
@property(nonatomic,retain) NewsletterSection * section;
@property(nonatomic,retain) NSNumber * displayOrder;
@end
