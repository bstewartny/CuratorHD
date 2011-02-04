//
//  OfflineCache.m
//  Untitled
//
//  Created by Robert Stewart on 4/28/10.
//  Copyright 2010 InfoNgen. All rights reserved.
//

#import "OfflineCache.h"


@implementation OfflineCache
@synthesize cache;

- (id) init
{
	if([super init])
	{
		self.cache=[[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[cache release];
	[super dealloc];
}

- (NSString*) getHTML:(NSString*)url
{
	return [self.cache objectForKey:url];
}

- (void) cacheHTML:(NSString*)url
{
	// make sure not already cached...
	
	// load url to hidden web view control...
	
	// run readability script to get extracted story text from web page
	
	// replace any images with embedded image data for that image
	
	// save extracted story text HTML to cache 
		
}

@end
