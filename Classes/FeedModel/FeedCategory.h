//
//  FeedCategory.h
//  Curator
//
//  Created by Robert Stewart on 3/28/11.
//  Copyright 2011 InfoNgen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FeedCategory : NSManagedObject {
	
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) NSSet * feeds;


@end
