//
//  FeedItemBody.h
//  Untitled
//
//  Created by Robert Stewart on 6/28/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLitePersistentObject.h"

@interface FeedItemBody : SQLitePersistentObject {
	NSString * key;
	NSString * body;
}
@property(nonatomic,retain) NSString * key;
@property(nonatomic,retain) NSString * body;

@end
