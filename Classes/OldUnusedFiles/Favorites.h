//
//  Favorites.h
//  Untitled
//
//  Created by Robert Stewart on 4/27/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"

@class FeedItem;

@interface Favorites : Feed {
	NSMutableDictionary * map;
}

@property(nonatomic,retain) NSMutableDictionary * map;

@end
