//
//  FeedItemBody.m
//  Untitled
//
//  Created by Robert Stewart on 6/28/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "FeedItemBody.h"


@implementation FeedItemBody
@synthesize key,body;

+(NSArray *)indices
{
	NSArray *index1 = [NSArray arrayWithObject:@"key"];
	return [NSArray arrayWithObjects:index1, nil];
}

- (void) dealloc
{
	[key release];
	[body release];
	[super dealloc];
}
@end
