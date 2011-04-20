//
//  ImageFetcher.m
//  Curator
//
//  Created by Robert Stewart on 3/24/11.
//  Copyright 2011 InfoNgen. All rights reserved.
//

#import "ImageFetcher.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@implementation ImageFetcher

- (NSDictionary*) fetchImages:(NSArray*)urls
{
	NSMutableDictionary * images=[[[NSMutableDictionary alloc] init] autorelease];
	NSOperationQueue * queue=[[NSOperationQueue alloc] init];
	
	[queue setMaxConcurrentOperationCount:4];
	
	for(NSString * url in urls)
	{
		NSInvocationOperation * op=[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchImage:) object:[NSArray arrayWithObjects:images,url,nil]];
		
		[queue addOperation:op];
		
		[op release];
	}
	
	[queue waitUntilAllOperationsAreFinished];
	
	[queue release];
	
	return images;  
}

- (void) fetchImage:(NSArray*)args
{
	[self fetchImageImpl:[args objectAtIndex:0] url:[args objectAtIndex:1]];
}

- (void) fetchImageImpl:(NSMutableDictionary*)images url:(NSString*)url
{
	@synchronized(images)
	{
		if([images objectForKey:url]!=nil)
		{
			// already have image for url
			return;
		}
	}
	
	// use local cache if available
	NSURL * URL = [NSURL URLWithString:url];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:URL];
	
	[request setDownloadCache:[ASIDownloadCache sharedCache]];
	[request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	[request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
	
	[request startSynchronous];
	
	NSError *error = [request error];
	
	if (!error) 
	{
		if([request didUseCachedResponse])
		{
			NSLog(@"Got image from cache: %@",url);
		}
		else 
		{
			NSLog(@"Did NOT get image from cache: %@",url);
		}

		NSData * data=[request responseData];
		
		if(data)
		{
			UIImage * img=[UIImage imageWithData:data];
			if(img)
			{
				NSLog(@"Got image for url: %@", url);
				@synchronized(images)
				{
					[images setObject:img forKey:url];
				}
			}
			else {
				NSLog(@"failed to get image from data");
			}

		}
		else {
			NSLog(@"data is null");
		}

	}
	else 
	{
		NSLog(@"Fetching image url failed: %@: %@",url,[error userInfo]);
	}
}


@end
